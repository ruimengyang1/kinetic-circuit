extends CharacterBody2D

# One routine and one set of constants across all four levels. Physical support
# transports this actor; no level adds an attack, input command or AI mode.
signal telegraphed
signal direction_locked(side: int)
signal committed
signal impacted(receiver: Node2D, momentum: float)
signal wall_impacted(at: Vector2)

const ANTICIPATION := 0.55
const LOCK_REMAINING := 0.35
const CHARGE_SPEED := 230.0
const CHARGE_TIME := 1.15
const RECOVERY := 0.20
const STAGGER := 0.38
var state := "idle"
var state_time := 0.0
var facing := 1
var intent_locked := false
var cooldown := 0.45
var suspended := false
var rail_left := 24.0
var rail_right := 610.0
var squash := 0.0
var clock := 0.0
var hit_receivers: Array[Node2D] = []

func _ready() -> void:
	add_to_group("foundry_can")
	add_to_group("foundry_heavy")
	collision_layer = 16
	collision_mask = 1
	floor_snap_length = 4
	platform_floor_layers = 1
	z_index = 5
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

func _physics_process(delta: float) -> void:
	if suspended: return
	clock += delta
	state_time = maxf(0, state_time - delta)
	squash = maxf(0, squash - delta)
	cooldown = maxf(0, cooldown - delta)
	var worker := get_tree().get_first_node_in_group("player") as Node2D
	velocity.x = 0
	match state:
		"idle":
			intent_locked = false
			if worker != null:
				var dx := worker.global_position.x - global_position.x
				if absf(dx) > 24 and absf(worker.global_position.y - global_position.y) < 52:
					facing = 1 if dx > 0 else -1
					if cooldown <= 0 and absf(dx) < 310 and absf(worker.global_position.y - global_position.y) < 52:
						state = "windup"
						state_time = ANTICIPATION
						telegraphed.emit()
					else:
						velocity.x = facing * 84
		"windup":
			if not intent_locked:
				if worker != null:
					facing = 1 if worker.global_position.x > global_position.x else -1
				if state_time <= LOCK_REMAINING:
					intent_locked = true
					direction_locked.emit(facing)
			if state_time <= 0:
				state = "charging"
				state_time = CHARGE_TIME
				hit_receivers.clear()
				velocity.x = facing * CHARGE_SPEED
				committed.emit()
		"charging":
			velocity.x = facing * CHARGE_SPEED
			if state_time <= 0: _recover()
		"recover", "stagger":
			if state_time <= 0:
				state = "idle"
				cooldown = 0.08
	velocity.y = minf(velocity.y + 650 * delta, 420)
	if state == "charging": _force_sweep(delta)
	move_and_slide()
	if global_position.x <= rail_left or global_position.x >= rail_right:
		global_position.x = clampf(global_position.x, rail_left, rail_right)
		if state == "charging":
			wall_impacted.emit(global_position)
			_recover()
	if state == "charging" and is_on_wall():
		var movable_contact := false
		for i in get_slide_collision_count():
			if get_slide_collision(i).get_collider().has_method("receive_impact"):
				movable_contact = true
		if not movable_contact:
			wall_impacted.emit(global_position)
			_recover()
	if worker != null and state in ["idle", "windup", "charging"]:
		if impact_rect().intersects(Rect2(worker.global_position - Vector2(6, 9), Vector2(12, 18))):
			if not (worker.global_position.y + 9 <= global_position.y - 8):
				worker.take_damage(global_position)
	queue_redraw()

func _force_sweep(delta: float) -> void:
	var nearest: Node2D
	var distance := INF
	for object in get_tree().get_nodes_in_group("force_receivers"):
		if object in hit_receivers or not object.impact_enabled(): continue
		var bounds: Rect2 = object.impact_rect()
		if bounds.position.y > global_position.y + 12 or bounds.end.y < global_position.y - 12: continue
		var edge := bounds.position.x - 12 if facing > 0 else bounds.end.x + 12
		var ahead := (edge - global_position.x) * facing
		if ahead >= -5 and ahead < distance and ahead <= CHARGE_SPEED * delta + 2:
			nearest = object
			distance = ahead
	if nearest != null:
		hit_receivers.append(nearest)
		var response: float = nearest.receive_impact(facing * CHARGE_SPEED, self)
		impacted.emit(nearest, facing * CHARGE_SPEED)
		if response * facing < 0: _recover()

func _recover() -> void:
	state = "recover"
	state_time = RECOVERY
	velocity.x = 0

func receive_kinetic_strike(_speed: float) -> bool:
	squash = 0.16
	if state != "charging":
		state = "stagger"
		state_time = STAGGER
		velocity.x = 0
	return true

func strike_rebound_speed() -> float: return -305.0
func strike_surface_y() -> float: return global_position.y - 12
func accepts_strike_at(from: Vector2) -> bool: return from.y <= global_position.y - 14 and absf(from.x - global_position.x) <= 24
func plate_mass() -> float: return 2.0 if is_on_floor() else 0.0
func weight_rect() -> Rect2: return Rect2(global_position + Vector2(-10, 8), Vector2(20, 6))
func impact_rect() -> Rect2: return Rect2(global_position - Vector2(12, 12), Vector2(24, 24))

func _draw() -> void:
	var top := -7.0 if squash > 0 else -12.0
	var tint := Color("ff785e") if state == "charging" else Color("8bb5b8")
	draw_rect(Rect2(-13, top - 2, 26, 25 - (top + 12)), Color("101b29"))
	draw_rect(Rect2(-10, top, 20, 20 - (top + 12)), tint)
	draw_rect(Rect2(-10, top, 20, 3), Color("f1c078"))
	draw_rect(Rect2(-7, top + 6, 14, 6), Color("1c3341"))
	draw_rect(Rect2(facing * 4 - 2, top + 7, 4, 3), Color("fff1b3") if intent_locked else Color("ff785e"))
	draw_rect(Rect2(-9, 9, 18, 3), Color("d5a25d"))
	if state == "windup":
		var color := Color("fff1b3") if intent_locked else Color("ff785e")
		var length := 62.0 if intent_locked else 40.0 + sin(clock * 28) * 4
		var tip := Vector2(facing * length, -5)
		draw_line(Vector2(facing * 16, -5), tip, color, 3)
		draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-facing * 9, -6), tip + Vector2(-facing * 9, 6)]), color)
		draw_rect(Rect2(-13, -23, 26 * (1 - state_time / ANTICIPATION), 3), color)
		if intent_locked: draw_rect(Rect2(-4, -30, 8, 5), color)
	if state == "charging":
		for i in 3:
			draw_line(Vector2(-facing * (16 + i * 9), -6 + i * 5), Vector2(-facing * (24 + i * 9), -6 + i * 5), Color("edb374"), 2)
		draw_line(Vector2(facing * 10, -6), Vector2(facing * 20, -22), Color("fff1b3"), 3)
