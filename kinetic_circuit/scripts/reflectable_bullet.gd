extends Area2D

signal hit_player(source: Vector2)
signal reflected(at: Vector2)

const SPEED_AFTER_REFLECT := 230.0
const MAX_LIFETIME := 4.5

var velocity := Vector2.ZERO
var lifetime := MAX_LIFETIME
var is_reflected := false
var source_actor: Area2D

func configure(at: Vector2, initial_velocity: Vector2) -> void:
	position = at
	velocity = initial_velocity

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("reflectable_projectiles")
	collision_layer = 16
	collision_mask = 3
	monitoring = true
	monitorable = true
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
	queue_redraw()

func receive_directional_strike(_direction: Vector2) -> bool:
	if velocity.is_zero_approx():
		return false
	is_reflected = true
	velocity = -velocity.normalized() * SPEED_AFTER_REFLECT
	collision_mask = 17
	lifetime = maxf(lifetime, 1.5)
	reflected.emit(global_position)
	queue_redraw()
	return true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not is_reflected:
			hit_player.emit(global_position)
			queue_free()
	elif (body.collision_layer & 1) != 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not is_reflected:
		return
	if area == source_actor:
		return
	if area.has_method("receive_projectile_strike") and area.receive_projectile_strike():
		queue_free()
	elif not area.has_method("receive_projectile_strike") and area.has_method("receive_strike") and area.receive_strike():
		queue_free()

func _draw() -> void:
	var core := Color("a9f4dd") if is_reflected else Color("ff8a66")
	var glow := Color(0.66, 0.96, 0.87, 0.35) if is_reflected else Color(1.0, 0.42, 0.28, 0.35)
	draw_circle(Vector2.ZERO, 6.0, glow)
	if is_reflected:
		draw_rect(Rect2(-3, -3, 6, 6), core, false, 2.0)
	else:
		draw_circle(Vector2.ZERO, 3.0, core)
	var trail_direction := -velocity.normalized() if not velocity.is_zero_approx() else Vector2.LEFT
	draw_line(trail_direction * 4.0, trail_direction * 11.0, core, 2.0)
