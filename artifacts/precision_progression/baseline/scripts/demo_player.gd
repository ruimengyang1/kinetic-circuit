extends "res://scripts/yard_player.gd"

var previous_feet := 0.0
var previous_position := Vector2.ZERO
var impact_paused := false
var pending_jump := false
var pending_attack := false
var pending_jump_release := false
var buffered_jump_released := false
var bounce_pose := 0.0
const GROUND_RESPONSE := 1800.0
const STOP_RESPONSE := 1900.0
const AIR_STOP := 650.0

func _physics_process(delta: float) -> void:
	if not active: return
	# Capture edges during the short world impact pause. Simulation and input
	# have separate lifetimes: even a press/release inside 50 ms is retained.
	_capture_input()
	if impact_paused: return
	previous_position = position
	previous_feet = position.y + 9
	bounce_pose = maxf(0, bounce_pose - delta)
	invulnerable_time = maxf(0, invulnerable_time - delta)
	hurt_lock = maxf(0, hurt_lock - delta)
	attack_time = maxf(0, attack_time - delta)
	jump_buffer_time = maxf(0, jump_buffer_time - delta)
	var grounded := is_on_floor() and velocity.y >= 0
	if grounded:
		coyote_time = COYOTE_TIME
		attack_time = 0
		jump_cut_available = false
	else: coyote_time = maxf(0, coyote_time - delta)
	if pending_jump:
		jump_buffer_time = JUMP_BUFFER
		buffered_jump_released = false
	pending_jump = false
	var direction := Input.get_axis("move_left", "move_right")
	if hurt_lock <= 0:
		if absf(direction) > 0.05:
			velocity.x = move_toward(velocity.x, direction * RUN_SPEED, (GROUND_RESPONSE if grounded else air_acceleration) * delta)
			facing = 1 if direction > 0 else -1
		else:
			velocity.x = move_toward(velocity.x, 0, (STOP_RESPONSE if grounded else AIR_STOP) * delta)
	_consume_jump()
	if pending_jump_release:
		if jump_buffer_time > 0: buffered_jump_released = true
		if jump_cut_available and velocity.y < -80 and attack_time <= 0: velocity.y *= 0.55
		jump_cut_available = false
	pending_jump_release = false
	if pending_attack and not grounded and attack_time <= 0 and hurt_lock <= 0:
		attack_time = ATTACK_DURATION
		jump_cut_available = false
		velocity.y = maxf(velocity.y, 170)
	pending_attack = false
	velocity.y = minf(velocity.y + GRAVITY * delta, 390)
	move_and_slide()
	if attack_time > 0: _check_strike()
	if velocity.y >= 0:
		for robot in get_tree().get_nodes_in_group("foundry_can"):
			if try_can_rebound(robot, robot.strike_surface_y(), delta, robot.position.x): break
	if is_on_floor() and velocity.y >= 0:
		# Resolve a buffered landing this frame rather than waiting for the next
		# floor query. An automatic rebound has priority over a ground jump.
		coyote_time = COYOTE_TIME
		attack_time = 0
		_consume_jump()
		if absf(velocity.x) > 10: run_clock += delta * 18
	queue_redraw()

func _capture_input() -> void:
	pending_jump = pending_jump or Input.is_action_just_pressed("jump")
	pending_attack = pending_attack or Input.is_action_just_pressed("attack")
	pending_jump_release = pending_jump_release or Input.is_action_just_released("jump")

func _consume_jump() -> void:
	if jump_buffer_time <= 0 or coyote_time <= 0 or attack_time > 0: return
	velocity.y = JUMP_SPEED
	jump_cut_available = not buffered_jump_released
	if buffered_jump_released: velocity.y *= 0.55
	buffered_jump_released = false
	jump_buffer_time = 0
	coyote_time = 0
	jumped.emit(global_position)

func try_can_rebound(robot: Node2D, previous_surface: float, delta: float, previous_can_x: float = INF) -> bool:
	# Relative swept top contact handles both a fast lateral crossing and a
	# shell rising on its platform. The underside and side remain dangerous.
	var surface: float = robot.strike_surface_y()
	var upward_speed := maxf(0, (previous_surface - surface) / delta)
	if not active or impact_paused or velocity.y < -upward_speed: return false
	var feet := position.y + 9
	if previous_feet > previous_surface + 10 or feet < surface - 3: return false
	if previous_feet > previous_surface + 3 and feet > surface + 10: return false
	var old_gap := previous_feet - previous_surface
	var gap := feet - surface
	var fraction := clampf(-old_gap / (gap - old_gap), 0, 1) if old_gap < 0 and gap > old_gap else 1.0
	var old_can_x := robot.position.x if is_inf(previous_can_x) else previous_can_x
	var relative_x := lerpf(previous_position.x - old_can_x, position.x - robot.position.x, fraction)
	if absf(relative_x) > 24: return false
	robot.receive_kinetic_strike(velocity.x)
	position.y = surface - 9
	velocity.y = robot.strike_rebound_speed()
	jump_cut_available = false
	coyote_time = 0
	attack_time = 0
	jump_buffer_time = 0
	buffered_jump_released = false
	rebounded.emit(position + Vector2(0, 10))
	return true

func _ready() -> void:
	super._ready()
	# Keep ordinary jumps consistent after a fast lift arrives. Riding a lift
	# should not turn a buffered jump into an accidental giant launch.
	platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_DO_NOTHING
	previous_position = position
	previous_feet = position.y + 9
	rebounded.connect(func(_at: Vector2) -> void:
		bounce_pose = 0.10
		jump_buffer_time = 0
		pending_jump = false
		pending_attack = false
	)

func _draw() -> void:
	if bounce_pose > 0:
		var compression := bounce_pose > 0.065
		draw_set_transform(Vector2.ZERO, 0, Vector2(1.20, 0.82) if compression else Vector2(0.9, 1.12))
	super._draw()
	# Headlamp and scarf remain visible against beam/airflow, without changing
	# collision size, movement abilities or rebound height between levels.
	draw_rect(Rect2(-5, -10, 10, 3), Color("f2c879"))
	draw_rect(Rect2(facing * 3 - 1, -10, 3, 2), Color("fff3c6"))
	if velocity.y < -150:
		draw_line(Vector2(-facing * 4, 1), Vector2(-facing * 10, 6), Color("e77e65"), 2)
	draw_set_transform(Vector2.ZERO)
