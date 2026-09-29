extends CharacterBody2D

signal rolled(momentum: float)
signal settled
signal transferred(receiver: Node2D, momentum: float)
var suspended := false
var spin := 0.0
var rolling := false
var impact_flash := 0.0
var roll_voice: AudioStreamPlayer
var hit_receivers: Array[Node2D] = []

func _ready() -> void:
	collision_layer = 17
	collision_mask = 1
	floor_snap_length = 3
	z_index = 4
	add_to_group("foundry_heavy")
	add_to_group("force_receivers")
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16
	collision.shape = shape
	add_child(collision)

func _physics_process(delta: float) -> void:
	if suspended: return
	impact_flash = maxf(0, impact_flash - delta)
	var before := global_position.x
	velocity.x = move_toward(velocity.x, 0, 325 * delta)
	velocity.y = minf(velocity.y + 650 * delta, 420)
	var impact_speed := velocity.x
	var receiver: Node2D = _transfer_force(delta) if absf(velocity.x) >= 80 else null
	move_and_slide()
	if receiver != null:
		var bounds: Rect2 = receiver.impact_rect()
		var edge := bounds.position.x - 16 if impact_speed > 0 else bounds.end.x + 16
		if absf(position.x - edge) < 0.25:
			hit_receivers.append(receiver)
			var response: float = receiver.receive_impact(impact_speed, self)
			transferred.emit(receiver, impact_speed)
			impact_flash = 0.10
			if response * impact_speed <= 0: velocity.x = 0
	spin += (global_position.x - before) / 16
	if roll_voice != null:
		roll_voice.volume_db = -40 + 17 * minf(1, absf(velocity.x) / 280)
		roll_voice.pitch_scale = 0.75 + 0.35 * minf(1, absf(velocity.x) / 280)
		roll_voice.stream_paused = absf(velocity.x) < 8 or not is_on_floor()
	if rolling and absf(velocity.x) < 1 and is_on_floor():
		rolling = false
		settled.emit()
	queue_redraw()

func receive_impact(momentum: float, _source: Node2D = null) -> float:
	if absf(momentum) < 80: return 0.0
	velocity.x = clampf(momentum * 1.22, -300, 300)
	rolling = true
	impact_flash = 0.10
	hit_receivers.clear()
	rolled.emit(momentum)
	return momentum * 0.8

func _transfer_force(delta: float) -> Node2D:
	var side := signf(velocity.x)
	var distance := absf(velocity.x) * delta
	var receiver: Node2D
	for object in get_tree().get_nodes_in_group("force_receivers"):
		if object == self or object in hit_receivers or not object.impact_enabled(): continue
		var bounds: Rect2 = object.impact_rect()
		if bounds.position.y >= global_position.y + 16 or bounds.end.y <= global_position.y - 16: continue
		var edge := bounds.position.x - 16 if side > 0 else bounds.end.x + 16
		var ahead := (edge - global_position.x) * side
		if ahead >= -0.2 and ahead <= distance + 0.08:
			distance = maxf(0, ahead)
			receiver = object
	if receiver != null: velocity.x = side * distance / delta
	return receiver

func impact_enabled() -> bool: return true
func impact_rect() -> Rect2: return Rect2(global_position - Vector2(16, 16), Vector2(32, 32))
func plate_mass() -> float: return 3.0 if is_on_floor() else 0.0
func weight_rect() -> Rect2: return Rect2(global_position + Vector2(-12, 10), Vector2(24, 8))

func _draw() -> void:
	draw_circle(Vector2.ZERO, 17, Color("101b29"))
	var points := PackedVector2Array()
	for i in 9:
		points.append(Vector2.from_angle(spin + TAU * i / 9) * (15 if i % 2 == 0 else 16))
	draw_colored_polygon(points, Color("8c7e6d"))
	draw_arc(Vector2.ZERO, 14, 0, TAU, 18, Color("c3ad83"), 2)
	for i in 3:
		var at := Vector2.from_angle(spin + i * 2.1) * 7
		draw_line(at, at.rotated(0.7) * 1.6, Color("e7bd75"), 2)
	draw_circle(Vector2(-5, -6).rotated(spin), 3, Color("665e57"))
	if impact_flash > 0: draw_arc(Vector2.ZERO, 17, 0, TAU, 24, Color("fff1b3", impact_flash / 0.10), 2)
	if not rolling:
		for side in [-1, 1]:
			var tip := Vector2(side * 27, 10)
			draw_line(Vector2(side * 20, 10), tip, Color("c3ad83", 0.65), 1)
			draw_line(tip, tip + Vector2(-side * 4, -3), Color("c3ad83", 0.65), 1)
			draw_line(tip, tip + Vector2(-side * 4, 3), Color("c3ad83", 0.65), 1)
