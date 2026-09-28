extends CharacterBody2D

signal rolled(momentum: float)
signal settled
var suspended := false
var spin := 0.0
var rolling := false

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
	var before := global_position.x
	velocity.x = move_toward(velocity.x, 0, 325 * delta)
	velocity.y = minf(velocity.y + 650 * delta, 420)
	move_and_slide()
	spin += (global_position.x - before) / 16
	if rolling and absf(velocity.x) < 1 and is_on_floor():
		rolling = false
		settled.emit()
	queue_redraw()

func receive_impact(momentum: float, _source: Node2D = null) -> float:
	if absf(momentum) < 80: return -momentum * 0.15
	velocity.x = clampf(momentum * 1.22, -300, 300)
	rolling = true
	rolled.emit(momentum)
	return momentum * 0.8

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
