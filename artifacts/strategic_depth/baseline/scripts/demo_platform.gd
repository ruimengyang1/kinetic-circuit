extends AnimatableBody2D

signal started
signal arrived
var size := Vector2(72, 10)
var home := Vector2.ZERO
var path: Array[Vector2] = []
var speed := 150.0
var powered := false
var suspended := false
var force_operated := false
var force_direction := 1
var impact_return := -0.18
var activation_delay := 0.0
var hazard := false
var warning_time := 0.0
var cursor := 0
var clock := 0.0
var translation := Vector2.ZERO

func configure(area: Rect2, destinations: Array[Vector2], travel_speed: float = 150) -> void:
	position = area.get_center()
	home = position
	size = area.size
	path = destinations
	speed = travel_speed

func _ready() -> void:
	process_physics_priority = -10
	collision_layer = 1
	collision_mask = 0
	sync_to_physics = true
	z_index = 2
	add_to_group("demo_platforms")
	if force_operated: add_to_group("force_receivers")
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

func set_power(value: bool) -> void:
	if powered == value: return
	powered = value
	cursor = 0
	warning_time = maxf(activation_delay, 0.22 if hazard else 0.0) if value else 0.0
	started.emit()
	queue_redraw()

func _physics_process(delta: float) -> void:
	translation = Vector2.ZERO
	if suspended: return
	clock += delta
	if warning_time > 0:
		warning_time = maxf(0, warning_time - delta)
		queue_redraw()
		return
	var target := home
	if powered and not path.is_empty(): target = path[mini(cursor, path.size() - 1)]
	var previous := position
	var next := position.move_toward(target, speed * delta)
	position = next
	translation = next - previous
	if next.is_equal_approx(target) and not previous.is_equal_approx(target):
		if powered and cursor < path.size() - 1: cursor += 1
		else: arrived.emit()
	if hazard and not translation.is_zero_approx():
		for worker in get_tree().get_nodes_in_group("player"):
			var lower := Rect2(global_position + Vector2(-size.x / 2 - 2, 0), Vector2(size.x + 4, size.y / 2 + 7))
			if lower.intersects(Rect2(worker.global_position - Vector2(6, 9), Vector2(12, 18))) and worker.global_position.y > global_position.y:
				worker.take_damage(global_position)
	queue_redraw()

func receive_impact(momentum: float, _source: Node2D = null) -> float:
	if absf(momentum) >= 80: set_power(momentum * force_direction > 0)
	return momentum * impact_return

func impact_enabled() -> bool: return force_operated
func impact_rect() -> Rect2: return Rect2(global_position - size / 2, size).grow(2)

func _draw() -> void:
	if not path.is_empty():
		var last := path[path.size() - 1] - position
		draw_line(home - position, last, Color("334f5d"), 2)
		draw_rect(Rect2(last - size / 2, size), Color("447784"), false, 1)
	draw_rect(Rect2(-size / 2 - Vector2.ONE, size + Vector2(2, 2)), Color("101b29"))
	draw_rect(Rect2(-size / 2, size), Color("426575"))
	draw_rect(Rect2(-size / 2, Vector2(size.x, 3)), Color("a9f4dd") if powered else Color("e8ba72"))
	for x in range(int(-size.x / 2 + 6), int(size.x / 2), 12):
		draw_line(Vector2(x, size.y / 2 - 5), Vector2(x + 5, size.y / 2 - 1), Color("edb374"), 1)
	if force_operated:
		for side in [-1, 1]:
			draw_rect(Rect2(side * size.x / 2 - 3, -size.y / 2 - 2, 6, size.y + 4), Color("ff9470"))
	if warning_time > 0:
		draw_arc(Vector2(0, -size.y / 2 - 9), 6, -PI / 2, -PI / 2 + TAU * (1 - warning_time / maxf(activation_delay, 0.22)), 16, Color("fff1b3"), 2)
	if hazard:
		draw_rect(Rect2(-size.x / 2, size.y / 2 - 3, size.x, 3), Color("ff785e"))
		if warning_time > 0: draw_circle(Vector2(0, -size.y / 2 - 6), 4, Color("fff1b3"))
