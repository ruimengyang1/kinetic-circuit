extends Node2D

# Pressure and optical circuits are continuously evaluated from visible world
# contact. Neither stores a puzzle-completed flag or checks an object's ID.
signal changed(on: bool)
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
		shape.radius = 16
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
				if occupied: angle = wrapf(angle + rotation_rate * delta, -PI, PI)
				_update_beam()
		"fan":
			spool = move_toward(spool, 1.0 if active else 0.0, delta * 6)
			if active:
				for worker in get_tree().get_nodes_in_group("player"):
					if Rect2(global_position + rect.position, rect.size).has_point(worker.global_position):
						worker.velocity.y = maxf(-220, worker.velocity.y - 1700 * delta)
						worker.jump_cut_available = false
						worker.attack_time = 0
						worker.coyote_time = 0
	queue_redraw()

func beam_origin() -> Vector2: return global_position - Vector2(0, 152)

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
	if beam_hit != null and beam_hit.is_in_group("player"):
		beam_hit.take_damage(start)
	for sensor in get_tree().get_nodes_in_group("laser_sensors"):
		sensor.set_power(sensor == receiver)

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
			draw_rect(Rect2(floor_at + Vector2(-33, -6), Vector2(66, 10)), Color("101b29"))
			draw_rect(Rect2(floor_at + Vector2(-30, -3), Vector2(60, 5)), Color("46737b"))
			for i in 5:
				var x := -23 + i * 12
				var spin := clock * (2 + spool * 22) + i
				draw_line(floor_at + Vector2(x, -1), floor_at + Vector2(x + sin(spin) * 6, -3 - cos(spin) * 4), Color("a9f4dd") if active else Color("6b8f95"), 2)
			if spool > 0:
				for i in 20:
					var x := -28 + fmod(i * 17.0, 56)
					var y := rect.end.y - fmod(clock * 170 + i * 23, rect.size.y)
					draw_line(Vector2(x, y), Vector2(x + sin(clock * 4 + i) * 3, y - 9 * spool), Color("9de7dc", spool * 0.55), 1)
				draw_line(Vector2(-32, rect.end.y - 14), Vector2(-32, rect.position.y), Color("75c9c6", 0.17), 1)
				draw_line(Vector2(32, rect.end.y - 14), Vector2(32, rect.position.y), Color("75c9c6", 0.17), 1)
				for i in 3:
					var y := rect.end.y - 28 - fmod(clock * 75 + i * 65, rect.size.y - 30)
					draw_line(Vector2(-6, y + 6), Vector2(0, y), Color("a9f4dd", spool * 0.42), 1)
					draw_line(Vector2(0, y), Vector2(6, y + 6), Color("a9f4dd", spool * 0.42), 1)
		"rotator":
			draw_rect(Rect2(-31, 1, 62, 7), Color("101b29"))
			draw_rect(Rect2(-28, 1 if occupied else -2, 56, 5), Color("a9f4dd") if occupied else Color("edb374"))
			draw_line(Vector2(-22, 0), Vector2(-22, -152), Color("517a87"), 4)
			draw_line(Vector2(-22, -152), Vector2(0, -152), Color("517a87"), 4)
			var origin := Vector2(0, -152)
			draw_circle(origin, 15, Color("101b29"))
			draw_arc(origin, 13, 0, TAU, 24, Color("edb374"), 2)
			draw_line(origin, origin + Vector2.from_angle(angle) * 13, Color("fff1b3"), 3)
			# The small lead diamond is a mechanical dial mark, not a solution
			# label. It visualizes approximately one withdrawal delay ahead.
			var lead := origin + Vector2.from_angle(angle + rotation_rate * 0.80) * 20
			draw_rect(Rect2(lead - Vector2(2, 2), Vector2(4, 4)), Color("a9f4dd"), false, 1)
			if occupied: draw_arc(origin, 18, angle - 0.4, angle + 0.4, 8, Color("a9f4dd"), 2)
			if beam_end != Vector2.ZERO:
				var endpoint := beam_end - global_position
				draw_line(origin, endpoint, Color("f76f77", 0.22), 7)
				draw_line(origin, endpoint, Color("ff7d85"), 3)
				draw_line(origin, endpoint, Color("ffe4be"), 1)
				draw_circle(endpoint, 3 + sin(clock * 27), Color("fff1b3"))
		"sensor":
			draw_circle(Vector2.ZERO, 18, Color("101b29"))
			draw_arc(Vector2.ZERO, 16, 0, TAU, 20, Color("a9f4dd") if active else Color("dba66a"), 2)
			draw_circle(Vector2.ZERO, 10, Color("3d686e") if active else Color("334b5c"))
			draw_circle(Vector2.ZERO, 5, Color("d4ffda") if active else Color("ffb074"))
			if active: draw_arc(Vector2.ZERO, 20 + sin(clock * 7) * 2, 0, TAU, 24, Color("a9f4dd", 0.3), 1)
