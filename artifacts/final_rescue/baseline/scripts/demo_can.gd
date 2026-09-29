extends CharacterBody2D

# One stationary search and one committed distance budget in every room.
signal telegraphed
signal direction_locked(side: int)
signal committed
signal impacted(receiver: Node2D, momentum: float)
signal wall_impacted(at: Vector2)

const ANTICIPATION := 0.50
const LOCK_REMAINING := 0.12
const CHARGE_SPEED := 300.0
const ACCELERATION_TIME := 0.06
const CHARGE_DISTANCE := 248.0
const CHARGE_TIME := CHARGE_DISTANCE / CHARGE_SPEED + ACCELERATION_TIME * 0.175
const RECOVERY := 0.32
const STAGGER := 0.28
var state := "idle"
var state_time := 0.0
var facing := 1
var intent_locked := false
var cooldown := 0.25
var suspended := false
var rail_left := 24.0
var rail_right := 616.0
var squash := 0.0
var clock := 0.0
var charge_age := 0.0
var charge_origin := 0.0
var charge_left := 0.0
var recoil := 0.0
var lock_flash := 0.0
var hit_receivers: Array[Node2D] = []

func _ready() -> void:
	add_to_group("foundry_can")
	add_to_group("foundry_heavy")
	collision_layer = 16
	collision_mask = 1
	floor_snap_length = 4
	platform_floor_layers = 1
	platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_DO_NOTHING
	z_index = 5
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

func _physics_process(delta: float) -> void:
	if suspended: return
	var previous_surface := strike_surface_y()
	var previous_x := position.x
	clock += delta
	state_time = maxf(0, state_time - delta)
	squash = maxf(0, squash - delta)
	lock_flash = maxf(0, lock_flash - delta)
	recoil = move_toward(recoil, 0, delta * 75)
	cooldown = maxf(0, cooldown - delta)
	var worker := get_tree().get_first_node_in_group("player") as Node2D
	velocity.x = 0
	var receiver: Node2D
	var motion := 0.0
	match state:
		"idle":
			intent_locked = false
			if worker != null and worker.active and is_on_floor():
				var dx := worker.global_position.x - global_position.x
				if absf(dx) > 28 and absf(dx) < 310 and absf(worker.global_position.y - global_position.y) < 52:
					facing = 1 if dx > 0 else -1
					if cooldown <= 0:
						state = "windup"
						state_time = ANTICIPATION
						telegraphed.emit()
		"windup":
			if worker != null and absf(worker.global_position.x - global_position.x) > 8:
				facing = 1 if worker.global_position.x > global_position.x else -1
			if state_time <= 0:
				state = "lock"
				state_time = LOCK_REMAINING
				intent_locked = true
				lock_flash = LOCK_REMAINING
				direction_locked.emit(facing)
		"lock":
			if state_time <= 0:
				state = "charging"
				charge_age = 0
				charge_origin = position.x
				charge_left = CHARGE_DISTANCE
				state_time = CHARGE_TIME
				hit_receivers.clear()
				committed.emit()
		"charging":
			var old_age := charge_age
			charge_age += delta
			motion = minf(charge_left, _travel_at(charge_age) - _travel_at(old_age))
			for object in get_tree().get_nodes_in_group("force_receivers"):
				if object in hit_receivers or not object.impact_enabled(): continue
				var bounds: Rect2 = object.impact_rect()
				if bounds.position.y >= global_position.y + 12 or bounds.end.y <= global_position.y - 12: continue
				var edge := bounds.position.x - 12 if facing > 0 else bounds.end.x + 12
				var ahead := (edge - global_position.x) * facing
				if ahead >= -0.2 and ahead <= motion + 0.08:
					motion = maxf(0, ahead)
					receiver = object
			velocity.x = facing * motion / delta
		"impact":
			state = "recover"
			state_time = RECOVERY
		"recover", "stagger":
			if state_time <= 0:
				state = "idle"
				cooldown = 0
	velocity.y = minf(velocity.y + 650 * delta, 420)
	move_and_slide()
	if state == "charging":
		charge_left = maxf(0, CHARGE_DISTANCE - absf(position.x - charge_origin))
		if receiver != null and absf(position.x - (receiver.impact_rect().position.x - 12 if facing > 0 else receiver.impact_rect().end.x + 12)) < 0.25:
			hit_receivers.append(receiver)
			var response: float = receiver.receive_impact(facing * CHARGE_SPEED, self)
			impacted.emit(receiver, facing * CHARGE_SPEED)
			if response * facing <= 0: _recover()
		var at_forward_bound := position.x <= rail_left + 0.1 if facing < 0 else position.x >= rail_right - 0.1
		if state == "charging" and (charge_left <= 0.01 or is_on_wall() or at_forward_bound):
			if is_on_wall(): wall_impacted.emit(position)
			_recover()
	# Room bounds have visible collision bumpers; this clamp is only a guard.
	position.x = clampf(position.x, rail_left, rail_right)
	var bounced: bool = worker != null and worker.try_can_rebound(self, previous_surface, delta, previous_x)
	if worker != null and worker.active and not bounced and state in ["idle", "windup", "lock", "charging"]:
		if impact_rect().intersects(Rect2(worker.global_position - Vector2(6, 9), Vector2(12, 18))):
			if worker.global_position.y + 9 > global_position.y - 8:
				worker.take_damage(global_position)
	queue_redraw()

func _travel_at(age: float) -> float:
	var ramp := minf(age, ACCELERATION_TIME)
	return CHARGE_SPEED * (0.65 * ramp + 0.175 * ramp * ramp / ACCELERATION_TIME + maxf(0, age - ACCELERATION_TIME))

func _seconds_for_distance(distance: float) -> float:
	var ramp_distance := CHARGE_SPEED * ACCELERATION_TIME * 0.825
	if distance >= ramp_distance: return ACCELERATION_TIME + (distance - ramp_distance) / CHARGE_SPEED
	# Invert the acceleration integral used by actual movement.
	return ACCELERATION_TIME * (-0.65 + sqrt(0.4225 + 0.7 * maxf(0, distance) / (CHARGE_SPEED * ACCELERATION_TIME))) / 0.35

func _recover() -> void:
	state = "impact"
	state_time = 0
	velocity.x = 0
	recoil = -facing * 3.0 # Visual recoil never changes collision position.

func receive_kinetic_strike(_speed: float) -> bool:
	squash = 0.16
	# Descending contact does not cancel a committed rhythm or repeatedly reset
	# preparation. The rebound is always the same vertical impulse.
	if state == "idle":
		state = "stagger"
		state_time = STAGGER
	return true

func strike_rebound_speed() -> float: return -305.0
func strike_surface_y() -> float: return global_position.y - 12
func accepts_strike_at(from: Vector2) -> bool: return from.y <= global_position.y - 14 and absf(from.x - global_position.x) <= 24
func plate_mass() -> float: return 2.0 if is_on_floor() and absf(velocity.y) < 1 else 0.0
func weight_rect() -> Rect2: return Rect2(global_position + Vector2(-10, 8), Vector2(20, 6))
func impact_rect() -> Rect2: return Rect2(global_position - Vector2(12, 12), Vector2(24, 24))

func remaining_charge_distance() -> float:
	return charge_left if state == "charging" else CHARGE_DISTANCE

func predicted_endpoint() -> float:
	var distance := remaining_charge_distance()
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 23.5) # Ignore the floor's contact margin.
	query.shape = shape
	query.transform = global_transform
	query.motion = Vector2(facing * distance, 0)
	query.collision_mask = 1
	query.margin = 0.01
	query.exclude = [get_rid()]
	# cast_motion brackets contact coarsely over a long sweep. Refine only
	# that bracket so the marker agrees with the actual collision margin.
	var travelled := 0.0
	for i in 3:
		var fractions := get_world_2d().direct_space_state.cast_motion(query)
		if fractions.is_empty() or fractions[0] >= 1:
			travelled += distance
			break
		var safe_distance: float = distance * fractions[0]
		var unsafe_distance: float = distance * fractions[1]
		travelled += safe_distance
		query.transform.origin.x += facing * safe_distance
		distance = maxf(0, unsafe_distance - safe_distance)
		query.motion = Vector2(facing * distance, 0)
		if distance < 0.01: break
	return clampf(position.x + facing * travelled, rail_left, rail_right)

func withdrawal_delay(pedal: Rect2) -> float:
	var wait := 0.0
	if state == "windup": wait = state_time + LOCK_REMAINING
	elif state == "lock": wait = state_time
	elif state != "charging": wait = state_time + cooldown + ANTICIPATION + LOCK_REMAINING
	var edge := pedal.end.x + 10 if facing > 0 else pedal.position.x - 10
	if (predicted_endpoint() - edge) * facing < 0: return INF
	var distance := maxf(0, (edge - position.x) * facing)
	if state == "charging": return maxf(0, _seconds_for_distance(_travel_at(charge_age) + distance) - charge_age)
	return wait + _seconds_for_distance(distance)

func _draw() -> void:
	var progress := 1 - state_time / ANTICIPATION if state == "windup" else 1.0 if state == "lock" else 0.0
	var compress := progress * 3
	draw_set_transform(Vector2(recoil - facing * compress, compress * 0.4), 0, Vector2(1 + compress * 0.025, 1 - compress * 0.025))
	var top := -7.0 if squash > 0 else -12.0
	var tint := Color("ff785e") if state == "charging" else Color("edb374")
	if state == "recover": tint = Color("a28e75")
	draw_rect(Rect2(-12, top - 1, 24, 25), Color("101b29"))
	draw_rect(Rect2(-10, top, 20, 22), tint)
	draw_rect(Rect2(-10, top, 20, 3), Color("f1c078"))
	draw_rect(Rect2(-7, top + 6, 14, 6), Color("1c3341"))
	draw_rect(Rect2(facing * 4 - 2, top + 7, 4, 3), Color("fff1b3") if intent_locked else Color("ff785e"))
	draw_rect(Rect2(-9, 9, 18, 3), Color("d5a25d"))
	if lock_flash > 0: draw_rect(Rect2(-12, top - 1, 24, 23), Color("fff1b3", lock_flash / LOCK_REMAINING), false, 2)
	if state in ["windup", "lock"]:
		var color := Color("fff1b3") if intent_locked else Color("ff785e")
		var length := 62.0 if intent_locked else 40.0 + sin(clock * 18) * 3
		var tip := Vector2(facing * length, -5)
		draw_line(Vector2(facing * 16, -5), tip, color, 3)
		draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-facing * 9, -6), tip + Vector2(-facing * 9, 6)]), color)
		draw_rect(Rect2(-13, -23, 26 * progress, 3), color)
		if intent_locked: draw_rect(Rect2(-4, -30, 8, 5), color)
	if state == "charging":
		for i in 3:
			draw_line(Vector2(-facing * (16 + i * 9), -6 + i * 5), Vector2(-facing * (24 + i * 9), -6 + i * 5), Color("edb374"), 2)
	draw_set_transform(Vector2.ZERO)
