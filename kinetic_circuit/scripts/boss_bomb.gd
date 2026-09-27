extends Area2D

signal hit_player(source: Vector2)
signal reflected(at: Vector2)
signal detonated(at: Vector2)

const GRAVITY := 360.0
const FUSE_TIME := 1.35
const BLAST_RADIUS := 48.0
const EXPLOSION_TIME := 0.2

var velocity := Vector2.ZERO
var fuse_time := FUSE_TIME
var explosion_time := 0.0
var is_reflected := false
var has_detonated := false
var clock := 0.0

func configure(at: Vector2, initial_velocity: Vector2) -> void:
	position = at
	velocity = initial_velocity

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("reflectable_projectiles")
	add_to_group("boss_bombs")
	collision_layer = 16
	collision_mask = 3
	monitoring = true
	monitorable = true
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	clock += delta
	if has_detonated:
		explosion_time = maxf(0.0, explosion_time - delta)
		queue_redraw()
		if explosion_time <= 0.0:
			queue_free()
		return
	velocity.y += GRAVITY * delta
	position += velocity * delta
	fuse_time = maxf(0.0, fuse_time - delta)
	if fuse_time <= 0.0:
		_detonate()
	queue_redraw()

func receive_directional_strike(direction: Vector2) -> bool:
	if has_detonated:
		return false
	var launch_direction := direction.normalized()
	if absf(launch_direction.x) < 0.25:
		launch_direction.x = 1.0 if velocity.x >= 0.0 else -1.0
	is_reflected = true
	velocity = Vector2(signf(launch_direction.x) * 260.0, -125.0)
	collision_mask = 17
	fuse_time = maxf(fuse_time, 0.9)
	reflected.emit(global_position)
	queue_redraw()
	return true

func _on_body_entered(body: Node2D) -> void:
	if has_detonated:
		return
	if body.is_in_group("player"):
		if not is_reflected:
			_detonate()
	elif (body.collision_layer & 1) != 0:
		_detonate()

func _on_area_entered(area: Area2D) -> void:
	if has_detonated or not is_reflected:
		return
	if area.has_method("receive_projectile_strike") and area.receive_projectile_strike():
		_detonate()

func _detonate() -> void:
	if has_detonated:
		return
	has_detonated = true
	explosion_time = EXPLOSION_TIME
	velocity = Vector2.ZERO
	collision_mask = 0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if not is_reflected:
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player != null and global_position.distance_to(player.global_position) <= BLAST_RADIUS:
			hit_player.emit(global_position)
	detonated.emit(global_position)
	queue_redraw()

func _draw() -> void:
	if has_detonated:
		var progress := 1.0 - explosion_time / EXPLOSION_TIME
		var fade := 1.0 - progress
		draw_circle(Vector2.ZERO, lerpf(8.0, BLAST_RADIUS, progress), Color(1.0, 0.25, 0.12, fade * 0.32))
		draw_arc(Vector2.ZERO, lerpf(6.0, BLAST_RADIUS, progress), 0.0, TAU, 32, Color(1.0, 0.75, 0.28, fade), 3.0)
		return
	var bomb_color := Color("a9f4dd") if is_reflected else Color("8b5360")
	draw_circle(Vector2.ZERO, 9.0, Color(0.05, 0.08, 0.12, 0.75))
	draw_circle(Vector2.ZERO, 6.5, bomb_color)
	draw_arc(Vector2.ZERO, 4.0, clock * 5.0, clock * 5.0 + PI * 1.5, 10, Color("d9b36c"), 1.5)
	draw_line(Vector2(2, -6), Vector2(6, -11), Color("d4a65e"), 2.0)
	var fuse_flash := 2.0 + absf(sin(clock * (18.0 + (FUSE_TIME - fuse_time) * 12.0))) * 2.0
	draw_circle(Vector2(7, -12), fuse_flash, Color("d5fff2") if is_reflected else Color("fff1ac"))
