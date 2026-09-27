extends Area2D

signal hit_player(source: Vector2)

var home := Vector2.ZERO
var travel := Vector2.ZERO
var speed := 1.8
var radius := 12.0
var clock := 0.0
var phase := 0.0
var inert := false

func configure(at: Vector2, movement: Vector2, movement_speed: float, saw_radius: float = 12.0, start_phase: float = 0.0) -> void:
	position = at
	home = at
	travel = movement
	speed = movement_speed
	radius = saw_radius
	phase = start_phase

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("runtime_cullables")
	collision_layer = 32
	collision_mask = 2
	monitoring = true
	monitorable = true
	add_to_group("pogo_spikes")
	add_to_group("clockwork_saws")
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = maxf(4.0, radius - 2.0)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if inert:
		queue_redraw()
		return
	clock += delta
	position = home + travel * sin(clock * speed + phase)
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("is_pogo_safe") and body.is_pogo_safe():
		return
	hit_player.emit(global_position)

func _draw() -> void:
	var rotation := clock * speed * 3.4 + phase
	draw_circle(Vector2.ZERO, radius + 3.0, Color(0.04, 0.08, 0.11, 0.72))
	draw_circle(Vector2.ZERO, radius - 2.0, Color("364d58"))
	for tooth_index in 12:
		var direction := Vector2.from_angle(rotation + tooth_index * TAU / 12.0)
		var side := direction.orthogonal() * 3.0
		var base := direction * (radius - 2.0)
		var points := PackedVector2Array([base - side, direction * (radius + 4.0), base + side])
		draw_colored_polygon(points, Color("6c9c91") if inert else Color("e68a62"))
	for spoke_index in 6:
		var direction := Vector2.from_angle(-rotation + spoke_index * TAU / 6.0)
		draw_line(direction * 3.0, direction * (radius - 3.0), Color("9ab0a6"), 2.0)
	draw_circle(Vector2.ZERO, 3.0, Color("b7e6bc") if inert else Color("f0bd68"))
