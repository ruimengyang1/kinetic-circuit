extends Node2D

# Pressure and optical circuits are continuously evaluated from visible world
# contact. Neither stores a puzzle-completed flag or checks an object's ID.
signal changed(on: bool)
signal exposed
var kind := "button"
var rect := Rect2()
var active := false
var suspended := false
var mass := 0.0
var required_mass := 2.0
var spool := 0.0
var clock := 0.0
var angle := deg_to_rad(-115)
var rotation_rate := deg_to_rad(28)
var sweep_min := deg_to_rad(-52)
var sweep_max := deg_to_rad(32)
var optical_radius := 30.0
var near_alignment := false
var approach_glow := 0.0
var withdrawal_lead := 0.0
var has_stop_preview := false
var entry_time := 0.0
const AIR_ENTRY := 0.18
var flow_top := 0.0
var flow_blocked := false
var exposure_time := 0.0
var covered_by_heavy := false
var previous_cover: Object
var cover_distance := 0.0
var cover_warned := false
var illuminated := false
var heat_time := 0.0
const HEAT_COAST := 0.28
var beam_end := Vector2.ZERO
var beam_hit: Object
var occupied := false
var targets: Array[Node2D] = []
var wind: AudioStreamPlayer

func configure(type: String, area: Rect2) -> void:
	kind = type
	position = area.get_center()
	rect = Rect2(-area.size / 2, area.size)

func _ready() -> void:
	add_to_group("demo_machines")
	z_index = 3
	if kind == "rotator": process_physics_priority = 8
	elif kind == "button" or kind == "fan": process_physics_priority = -6
	if kind == "sensor":
		add_to_group("laser_sensors")
		var area := Area2D.new()
		area.collision_layer = 64
		area.collision_mask = 0
		area.set_meta("sensor_owner", self)
		var collision := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = optical_radius
		collision.shape = shape
		area.add_child(collision)
		add_child(area)

func set_power(on: bool) -> void:
	if active == on: return
	active = on
	for target in targets: target.set_power(on)
	changed.emit(on)
	if wind != null:
		if active: wind.play()
		else: wind.stop()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if suspended: return
	clock += delta
	match kind:
		"button", "rotator":
			mass = 0
			var contact := Rect2(global_position + rect.position, rect.size)
			for object in get_tree().get_nodes_in_group("foundry_heavy"):
				if contact.intersects(object.weight_rect()): mass += object.plate_mass()
			occupied = mass >= required_mass
			if kind == "button": set_power(occupied)
			else:
				set_power(occupied)
				if occupied:
					angle += rotation_rate * delta
					if angle >= sweep_max or angle <= sweep_min:
						angle = clampf(angle, sweep_min, sweep_max)
						rotation_rate *= -1
				exposure_time = maxf(0, exposure_time - delta)
				_update_beam()
		"laser":
			# A stationary emitter uses exactly the same optical obstruction and
			# damage rules, with no misleading inactive occupancy pedal.
			exposure_time = maxf(0, exposure_time - delta)
			_update_beam()
		"fan":
			spool = move_toward(spool, 1.0 if active else 0.0, delta * 6)
			_update_airflow()
			var inside := false
			if active:
				for worker in get_tree().get_nodes_in_group("player"):
					var column := Rect2(Vector2(global_position.x + rect.position.x, flow_top), Vector2(rect.size.x, global_position.y + rect.end.y - flow_top))
					if worker.active and column.has_point(worker.global_position) and not flow_blocked:
						inside = true
						entry_time = minf(AIR_ENTRY, entry_time + delta)
						worker.velocity.y = maxf(-220, worker.velocity.y - 1700 * spool * (entry_time / AIR_ENTRY) * delta)
						worker.jump_cut_available = false
						worker.attack_time = 0
						worker.coyote_time = 0
			if not inside: entry_time = 0
			if wind != null: wind.volume_db = -27 if flow_blocked else -21 + spool * 3
		"sensor":
			# A heat-driven winch coasts through a brief beam crossing. This
			# prevents its own passing lift from chattering on/off, but still
			# cools quickly when the angle is genuinely wrong.
			heat_time = maxf(0, heat_time - delta)
			if heat_time <= 0: set_power(false)
	queue_redraw()

var mast_height := 152.0
func beam_origin() -> Vector2: return global_position - Vector2(0, mast_height)

func _update_airflow() -> void:
	# A narrow physical nozzle supplies the wider plume. A solid panel or heavy
	# body across that nozzle blocks the jet; no object identity or switch lookup.
	var nozzle := global_position + Vector2(0, rect.end.y - 1)
	var end := global_position + Vector2(0, rect.position.y)
	var ray := PhysicsRayQueryParameters2D.create(nozzle, end, 1)
	ray.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(ray)
	flow_top = end.y if hit.is_empty() else maxf(end.y, hit.position.y)
	if not hit.is_empty() and hit.position == Vector2.ZERO: flow_top = nozzle.y
	flow_blocked = flow_top >= nozzle.y - 40

func _update_beam() -> void:
	var start := beam_origin()
	var end := start + Vector2.from_angle(angle) * 800
	var ray := PhysicsRayQueryParameters2D.create(start, end, 1 | 2 | 64)
	ray.collide_with_areas = true
	var hit := get_world_2d().direct_space_state.intersect_ray(ray)
	beam_hit = null if hit.is_empty() else hit.collider
	beam_end = end if hit.is_empty() else hit.position
	var receiver: Node2D
	if beam_hit != null and beam_hit.has_meta("sensor_owner"):
		receiver = beam_hit.get_meta("sensor_owner")
	var blocked: bool = beam_hit != null and beam_hit.is_in_group("foundry_heavy")
	# A rolling blocker can expose a longer dangerous segment while still
	# intercepting the far end. Warn for that extension as well as full removal.
	var distance_now := start.distance_to(beam_end)
	var extended: bool = previous_cover != null and (beam_hit != previous_cover or distance_now > cover_distance + 18)
	if extended and not cover_warned:
		exposure_time = 0.70
		cover_warned = true
		exposed.emit()
	if blocked and beam_hit != previous_cover:
		previous_cover = beam_hit
		cover_distance = distance_now
		cover_warned = false
	elif not blocked: previous_cover = null
	covered_by_heavy = blocked
	if beam_hit != null and beam_hit.is_in_group("player") and exposure_time <= 0:
		beam_hit.take_damage(start)
	near_alignment = false
	withdrawal_lead = 0
	has_stop_preview = false
	if occupied:
		var pedal := Rect2(global_position + rect.position, rect.size)
		for object in get_tree().get_nodes_in_group("foundry_can"):
			if pedal.intersects(object.weight_rect()):
				var remaining: float = object.withdrawal_delay(pedal)
				if is_finite(remaining):
					withdrawal_lead = remaining
					has_stop_preview = true
	var predicted := predicted_angle(withdrawal_lead)
	for sensor in get_tree().get_nodes_in_group("laser_sensors"):
		sensor.illuminated = sensor == receiver
		if sensor.illuminated:
			sensor.heat_time = HEAT_COAST
			sensor.set_power(true)
		var goal: float = (sensor.global_position - start).angle()
		var tolerance := asin(minf(0.95, sensor.optical_radius / start.distance_to(sensor.global_position)))
		var gap := absf(angle_difference(predicted, goal))
		if gap < tolerance: near_alignment = true
		sensor.approach_glow = clampf(1 - maxf(0, gap - tolerance) / deg_to_rad(12), 0, 1)

func predicted_angle(seconds: float) -> float:
	var span := sweep_max - sweep_min
	var phase := fposmod(angle - sweep_min + rotation_rate * seconds, span * 2)
	return sweep_min + (phase if phase <= span else span * 2 - phase)

func _draw() -> void:
	match kind:
		"button":
			var top := rect.position.y + (4 if active else 0)
			draw_rect(Rect2(rect.position + Vector2(-3, 6), rect.size + Vector2(6, 1)), Color("101b29"))
			draw_rect(Rect2(Vector2(rect.position.x, top), Vector2(rect.size.x, 5)), Color("a9f4dd") if active else Color("edb374"))
			for x in range(int(rect.position.x + 4), int(rect.end.x), 10):
				draw_rect(Rect2(x, top + 1, 4, 1), Color("496b69"))
		"fan":
			var floor_at := Vector2(0, rect.end.y)
			var half_width := rect.size.x / 2
			draw_rect(Rect2(floor_at + Vector2(-half_width - 3, -6), Vector2(rect.size.x + 6, 10)), Color("101b29"))
			draw_rect(Rect2(floor_at + Vector2(-half_width + 3, -3), Vector2(rect.size.x - 6, 5)), Color("46737b"))
			for i in maxi(5, int(rect.size.x / 12)):
				var x := -half_width + 10 + i * 12
				var spin := clock * (2 + spool * 22) + i
				draw_line(floor_at + Vector2(x, -1), floor_at + Vector2(x + sin(spin) * 6, -3 - cos(spin) * 4), Color("a9f4dd") if active else Color("6b8f95"), 2)
			# The nozzle stays visibly running even when its outlet is obstructed.
			draw_rect(Rect2(-8, rect.end.y - 5, 16, 4), Color("ffb074") if flow_blocked else Color("a9f4dd"))
			if spool > 0 and not flow_blocked:
				var local_top := flow_top - global_position.y
				var height := maxf(1, rect.end.y - local_top)
				for i in 20:
					var x := -half_width + 5 + fmod(i * 17.0, rect.size.x - 10)
					var y := rect.end.y - fmod(clock * 170 + i * 23, height)
					draw_line(Vector2(x, y), Vector2(x + sin(clock * 4 + i) * 3, y - 9 * spool), Color("9de7dc", spool * 0.55), 1)
				draw_line(Vector2(-half_width + 1, rect.end.y - 14), Vector2(-half_width + 1, local_top), Color("75c9c6", 0.17), 1)
				draw_line(Vector2(half_width - 1, rect.end.y - 14), Vector2(half_width - 1, local_top), Color("75c9c6", 0.17), 1)
				for i in 3:
					var y := rect.end.y - 8 - fmod(clock * 75 + i * 65, maxf(1, height - 16))
					draw_line(Vector2(-6, y + 6), Vector2(0, y), Color("a9f4dd", spool * 0.42), 1)
					draw_line(Vector2(0, y), Vector2(6, y + 6), Color("a9f4dd", spool * 0.42), 1)
			elif spool > 0:
				# The dormant shaft stays legible while a solid blocks its mouth.
				# Same physical nozzle/column, no extra switch or promise of power.
				for side in [-1, 1]:
					for y in range(int(rect.position.y), int(rect.end.y - 20), 16):
						draw_line(Vector2(side * (half_width - 2), y), Vector2(side * (half_width - 2), y + 6), Color("75c9c6", 0.23), 1)
				for side in [-1, 1]:
					var at := Vector2(side * (12 + fmod(clock * 20, 12)), rect.end.y - 6)
					draw_line(at, at + Vector2(side * 5, -4), Color("ffb074", 0.55), 2)
		"rotator", "laser":
			if kind == "rotator":
				# Draw the real weight footprint: a broad parking choice must look
				# broad, rather than behaving like an invisible extended button.
				draw_rect(Rect2(rect.position.x - 3, 1, rect.size.x + 6, 7), Color("101b29"))
				draw_rect(Rect2(rect.position.x, 1 if occupied else -2, rect.size.x, 5), Color("a9f4dd") if occupied else Color("edb374"))
				for x in range(int(rect.position.x + 5), int(rect.end.x), 12):
					draw_line(Vector2(x, 2), Vector2(x + 5, 5), Color("496b69"), 1)
				draw_line(Vector2(-22, 0), Vector2(-22, -mast_height), Color("517a87"), 4)
				draw_line(Vector2(-22, -mast_height), Vector2(0, -mast_height), Color("517a87"), 4)
			else:
				draw_line(Vector2(0, 10), Vector2(0, -mast_height), Color("517a87"), 5)
			var origin := Vector2(0, -mast_height)
			for sensor in get_tree().get_nodes_in_group("laser_sensors"):
				var goal: float = (sensor.global_position - beam_origin()).angle()
				var tolerance := asin(minf(0.95, sensor.optical_radius / beam_origin().distance_to(sensor.global_position)))
				draw_arc(origin, 26, goal - tolerance, goal + tolerance, 16, Color("a9f4dd", 0.9), 4)
			draw_circle(origin, 15, Color("101b29"))
			draw_arc(origin, 13, 0, TAU, 24, Color("edb374"), 2)
			draw_line(origin, origin + Vector2.from_angle(angle) * 13, Color("fff1b3"), 3)
			# The small lead diamond is a mechanical dial mark, not a solution
			# label. It visualizes approximately one withdrawal delay ahead.
			var lead := origin + Vector2.from_angle(predicted_angle(withdrawal_lead)) * 20
			if occupied and has_stop_preview: draw_rect(Rect2(lead - Vector2(3, 3), Vector2(6, 6)), Color("fff1b3") if near_alignment else Color("a9f4dd"), false, 2 if near_alignment else 1)
			if occupied: draw_arc(origin, 18, angle - 0.4, angle + 0.4, 8, Color("a9f4dd"), 2)
			if beam_end != Vector2.ZERO:
				var endpoint := beam_end - global_position
				if covered_by_heavy:
					# Dashed projection is information, never an active damage ray.
					# It shows the space currently protected by the real blocker.
					var ray := PhysicsRayQueryParameters2D.create(beam_end + Vector2.from_angle(angle) * 2, beam_origin() + Vector2.from_angle(angle) * 800, 1)
					if beam_hit is CollisionObject2D: ray.exclude = [beam_hit.get_rid()]
					var hit := get_world_2d().direct_space_state.intersect_ray(ray)
					var far: Vector2 = beam_origin() + Vector2.from_angle(angle) * 800 if hit.is_empty() else hit.position
					var length := beam_end.distance_to(far)
					for offset in range(8, int(length), 16):
						var at := endpoint + Vector2.from_angle(angle) * offset
						draw_line(at, at + Vector2.from_angle(angle) * minf(6, length - offset), Color("ff7d85", 0.40), 1)
				var beam_color := Color("fff1b3") if exposure_time > 0 else Color("ff7d85")
				if beam_hit != null and is_instance_valid(beam_hit) and beam_hit.has_meta("sensor_owner"): beam_color = Color("a9f4dd")
				draw_line(origin, endpoint, Color(beam_color, 0.22), 7)
				draw_line(origin, endpoint, beam_color, 3)
				draw_line(origin, endpoint, Color("ffe4be"), 1)
				draw_circle(endpoint, 3 + sin(clock * 27), Color("fff1b3"))
		"sensor":
			# A large heat collector winds a visible cable, rather than a colored key.
			draw_circle(Vector2.ZERO, optical_radius + 2, Color("101b29"))
			if approach_glow > 0 and not active:
				draw_arc(Vector2.ZERO, optical_radius + 3, 0, TAU, 32, Color("a9f4dd", approach_glow * 0.45), 2)
			draw_arc(Vector2.ZERO, optical_radius, 0, TAU, 32, Color("a9f4dd") if active else Color("dba66a"), 3)
			for i in 8:
				var at := Vector2.from_angle(i * TAU / 8 + (clock * 2 if active else 0.0))
				draw_line(at * 10, at * (optical_radius - 5), Color("d4ffda") if active else Color("926b4e"), 3)
			draw_circle(Vector2.ZERO, 9, Color("d4ffda") if active else Color("ffb074"))
			if active: draw_arc(Vector2.ZERO, optical_radius + 4 + sin(clock * 7) * 2, 0, TAU, 32, Color("a9f4dd", 0.5), 2)
			if active and not illuminated: draw_arc(Vector2.ZERO, optical_radius - 3, -PI / 2, -PI / 2 + TAU * heat_time / HEAT_COAST, 24, Color("fff1b3"), 2)
