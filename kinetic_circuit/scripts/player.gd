extends CharacterBody2D

signal health_changed(value: int)
signal died
signal rebounded(at: Vector2)
signal jumped(at: Vector2)
signal dashed(at: Vector2)
signal dash_connected(at: Vector2)
signal attack_connected(at: Vector2)
signal double_jumped(at: Vector2)

const RUN_SPEED := 155.0
const GROUND_ACCEL := 1050.0
const AIR_ACCEL := 760.0
const GROUND_FRICTION := 1100.0
const AIR_FRICTION := 420.0
const GRAVITY := 650.0
const JUMP_SPEED := -235.0
const DOUBLE_JUMP_SPEED := -225.0
const REBOUND_SPEED := -285.0
const COYOTE_TIME := 0.11
const JUMP_BUFFER := 0.12
const ATTACK_DURATION := 0.27
const FORWARD_ATTACK_DURATION := 0.27
const FORWARD_ATTACK_LUNGE_DURATION := 0.18
const FORWARD_ATTACK_SPEED := 150.0
const ATTACK_ANIMATION_DURATION := 0.32
const ATTACK_IMPACT_FLASH_DURATION := 0.09
const ATTACK_COOLDOWN := 0.38
const ATTACK_HITBOX_SIZE := Vector2(24, 18)
const FORWARD_ATTACK_HITBOX_SIZE := Vector2(28, 24)
const ATTACK_TARGET_MASK := 16
const POGO_SPIKE_LAYER := 32
const POGO_SAFETY_TIME := 0.12
const PLAYER_LEG_COLOR := Color("d89a62")
const IDLE_ANIMATION_SPEED := 2.4
const RUN_ANIMATION_SPEED := 18.0
const DASH_SPEED := 460.0
const DASH_RANGE := 160.0
const DASH_DURATION := 0.48
const DASH_HIT_DISTANCE := 19.0
const DASH_HIT_INVULNERABILITY := 0.35
const DASH_CONE_ANGLE := deg_to_rad(35.0)
const MOUSE_DASH_TARGET_RADIUS := 14.0
const FREE_DASH_SPEED := 280.0
const FREE_DASH_DURATION := 0.16
const FREE_DASH_EXIT_SPEED := 90.0
const DASH_GHOST_LIFETIME := 0.16
const DASH_GHOST_INTERVAL := 0.032
const DEATH_ANIMATION_DURATION := 0.68
const DEATH_GRAVITY := 760.0

var health := 3
var circuit_style := false
var active := true
var invulnerable_time := 0.0
var attack_time := 0.0
var forward_attack_time := 0.0
var attack_animation_time := 0.0
var attack_impact_flash := 0.0
var attack_cooldown := 0.0
var pogo_safety_time := 0.0
var attack_direction := Vector2.RIGHT
var attack_facing := 1
var forward_attack_lunging := false
var coyote_time := 0.0
var jump_buffer_time := 0.0
var jump_cut_available := false
var double_jump_enabled := false
var double_jump_available := false
var hurt_lock := 0.0
var facing := 1
var idle_clock := 0.0
var run_clock := 0.0
var strike_shape := RectangleShape2D.new()
var forward_strike_shape := RectangleShape2D.new()
var dash_enabled := false
var dash_ready := false
var dash_time := 0.0
var dash_target: Area2D
var dash_entry_velocity := Vector2.ZERO
var dash_aim_direction := Vector2.ZERO
var dash_preview_target: Area2D
var dash_direction := Vector2.RIGHT
var dash_is_targeted := false
var dash_ghost_clock := 0.0
var dash_ghosts: Array[Dictionary] = []
var death_animation_time := 0.0
var death_velocity := Vector2.ZERO
var death_spin := 0.0
var death_spin_speed := 0.0
var last_safe_position := Vector2.ZERO
var last_safe_platform: Node2D
var last_safe_platform_offset := Vector2.ZERO
var hazard_recovery_time := 0.0

func _ready() -> void:
	name = "Player"
	add_to_group("player")
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 2.0
	platform_floor_layers = 1
	var body := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(12, 18)
	body.shape = shape
	add_child(body)
	strike_shape.size = Vector2(30, 22) if circuit_style else ATTACK_HITBOX_SIZE
	forward_strike_shape.size = Vector2(34, 26) if circuit_style else FORWARD_ATTACK_HITBOX_SIZE

func _physics_process(delta: float) -> void:
	if death_animation_time > 0.0:
		death_animation_time = maxf(0.0, death_animation_time - delta)
		death_velocity.y += DEATH_GRAVITY * delta
		global_position += death_velocity * delta
		death_spin += death_spin_speed * delta
		idle_clock += delta
		queue_redraw()
		return
	if not active:
		return
	_update_visual_animation(delta)
	invulnerable_time = maxf(0.0, invulnerable_time - delta)
	hurt_lock = maxf(0.0, hurt_lock - delta)
	attack_time = maxf(0.0, attack_time - delta)
	forward_attack_time = maxf(0.0, forward_attack_time - delta)
	pogo_safety_time = maxf(0.0, pogo_safety_time - delta)
	hazard_recovery_time = maxf(0.0, hazard_recovery_time - delta)
	if forward_attack_lunging and forward_attack_time <= FORWARD_ATTACK_DURATION - FORWARD_ATTACK_LUNGE_DURATION:
		forward_attack_lunging = false
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	jump_buffer_time = maxf(0.0, jump_buffer_time - delta)
	if is_on_floor():
		coyote_time = COYOTE_TIME
		double_jump_available = double_jump_enabled
		if attack_time > 0.0 and attack_direction.y > 0.0:
			attack_time = 0.0
		jump_cut_available = false
		if dash_time <= 0.0:
			dash_ready = dash_enabled
	else:
		coyote_time = maxf(0.0, coyote_time - delta)
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER
	dash_aim_direction = Input.get_vector("move_left", "move_right", "aim_up", "aim_down").normalized()
	if dash_enabled and dash_ready:
		var mouse_target := _mouse_dash_target(get_global_mouse_position())
		dash_preview_target = mouse_target if mouse_target != null else _nearest_dash_target(dash_aim_direction)
	else:
		dash_preview_target = null
	if dash_enabled and dash_ready and hurt_lock <= 0.0 and attack_time <= 0.0 and forward_attack_time <= 0.0 and Input.is_action_just_pressed("dash"):
		var target := dash_preview_target
		if target != null:
			_begin_dash(target)
		else:
			var free_direction := dash_aim_direction if not dash_aim_direction.is_zero_approx() else Vector2(facing, 0.0)
			_begin_free_dash(free_direction)
	if dash_time > 0.0:
		_update_dash(delta)
		move_and_slide()
		_remember_safe_platform()
		_check_dash_hit()
		queue_redraw()
		return
	var direction := Input.get_axis("move_left", "move_right")
	if hurt_lock <= 0.0:
		if forward_attack_time > 0.0 and forward_attack_lunging:
			velocity.x = facing * FORWARD_ATTACK_SPEED
		elif absf(direction) > 0.05:
			velocity.x = move_toward(velocity.x, direction * RUN_SPEED, (GROUND_ACCEL if is_on_floor() else AIR_ACCEL) * delta)
			if attack_animation_time <= 0.0:
				facing = 1 if direction > 0.0 else -1
		else:
			velocity.x = move_toward(velocity.x, 0.0, (GROUND_FRICTION if is_on_floor() else AIR_FRICTION) * delta)
	if jump_buffer_time > 0.0 and attack_time <= 0.0 and forward_attack_time <= 0.0:
		if coyote_time > 0.0:
			velocity.y = JUMP_SPEED
			jump_cut_available = true
			jump_buffer_time = 0.0
			coyote_time = 0.0
			jumped.emit(global_position)
		elif double_jump_enabled and double_jump_available:
			velocity.y = DOUBLE_JUMP_SPEED
			double_jump_available = false
			jump_cut_available = true
			jump_buffer_time = 0.0
			double_jumped.emit(global_position)
	if Input.is_action_just_released("jump"):
		if jump_cut_available and velocity.y < -80.0 and attack_time <= 0.0 and forward_attack_time <= 0.0:
			velocity.y *= 0.55
		jump_cut_available = false
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0 and attack_time <= 0.0 and forward_attack_time <= 0.0 and hurt_lock <= 0.0:
		attack_direction = _attack_direction_from_input()
		if attack_direction.y > 0.0 and is_on_floor():
			attack_direction = Vector2(facing, 0.0)
		if not is_zero_approx(attack_direction.x):
			facing = 1 if attack_direction.x > 0.0 else -1
		attack_animation_time = ATTACK_ANIMATION_DURATION
		attack_impact_flash = 0.0
		attack_cooldown = 0.31 if circuit_style else ATTACK_COOLDOWN
		attack_facing = facing
		if not is_zero_approx(attack_direction.x):
			forward_attack_time = FORWARD_ATTACK_DURATION
			forward_attack_lunging = is_on_floor()
			if forward_attack_lunging:
				velocity.x = facing * FORWARD_ATTACK_SPEED
		else:
			attack_time = ATTACK_DURATION
			jump_cut_available = false
			if attack_direction.y > 0.0:
				velocity.y = maxf(velocity.y, 170.0)
	velocity.y = minf(velocity.y + GRAVITY * delta, 390.0)
	move_and_slide()
	_remember_safe_platform()
	if forward_attack_time > 0.0:
		_check_forward_strike()
	elif attack_time > 0.0:
		_check_strike()
	if absf(velocity.x) > 10.0 and is_on_floor():
		run_clock += delta * RUN_ANIMATION_SPEED
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_world_position: Vector2 = get_canvas_transform().affine_inverse() * event.position
		_try_mouse_dash_at(mouse_world_position)

func _nearest_dash_target(direction: Vector2) -> Area2D:
	if direction.is_zero_approx():
		return null
	var aim := direction.normalized()
	var nearest: Area2D
	var nearest_distance := DASH_RANGE * DASH_RANGE
	for node in get_tree().get_nodes_in_group("dash_targets"):
		var enemy := node as Area2D
		if not _is_dash_target_reachable(enemy):
			continue
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance >= nearest_distance:
			continue
		var target_direction := global_position.direction_to(enemy.global_position)
		if absf(aim.angle_to(target_direction)) > DASH_CONE_ANGLE:
			continue
		nearest = enemy
		nearest_distance = distance
	return nearest

func _mouse_dash_target(mouse_world_position: Vector2) -> Area2D:
	var nearest: Area2D
	var nearest_cursor_distance := MOUSE_DASH_TARGET_RADIUS * MOUSE_DASH_TARGET_RADIUS
	for node in get_tree().get_nodes_in_group("dash_targets"):
		var enemy := node as Area2D
		if not _is_dash_target_reachable(enemy):
			continue
		var cursor_distance := mouse_world_position.distance_squared_to(enemy.global_position)
		if cursor_distance > nearest_cursor_distance:
			continue
		nearest = enemy
		nearest_cursor_distance = cursor_distance
	return nearest

func _is_dash_target_reachable(enemy: Area2D) -> bool:
	if enemy == null or enemy.get("alive") != true:
		return false
	if global_position.distance_squared_to(enemy.global_position) >= DASH_RANGE * DASH_RANGE:
		return false
	var ray := PhysicsRayQueryParameters2D.create(global_position, enemy.global_position, 1, [get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _try_mouse_dash_at(mouse_world_position: Vector2) -> bool:
	if not active or not dash_enabled or not dash_ready or hurt_lock > 0.0 or attack_time > 0.0 or forward_attack_time > 0.0:
		return false
	var target := _mouse_dash_target(mouse_world_position)
	if target == null:
		return false
	_begin_dash(target)
	return true

func _attack_direction_from_input() -> Vector2:
	var vertical := Input.get_axis("aim_up", "aim_down")
	if absf(vertical) > 0.2:
		return Vector2(0.0, 1.0 if vertical > 0.0 else -1.0)
	var horizontal := Input.get_axis("move_left", "move_right")
	if absf(horizontal) > 0.2:
		return Vector2(1.0 if horizontal > 0.0 else -1.0, 0.0)
	return Vector2(facing, 0.0)

func _begin_dash(target: Area2D) -> void:
	dash_target = target
	dash_is_targeted = true
	dash_preview_target = null
	dash_entry_velocity = velocity
	dash_time = DASH_DURATION
	dash_ready = false
	attack_time = 0.0
	jump_buffer_time = 0.0
	jump_cut_available = false
	coyote_time = 0.0
	velocity = global_position.direction_to(target.global_position) * DASH_SPEED
	dash_direction = velocity.normalized()
	_start_dash_animation()
	facing = 1 if velocity.x >= 0.0 else -1
	dashed.emit(global_position)

func _begin_free_dash(direction: Vector2) -> void:
	dash_target = null
	dash_is_targeted = false
	dash_preview_target = null
	dash_entry_velocity = velocity
	dash_direction = direction.normalized()
	_start_dash_animation()
	dash_time = FREE_DASH_DURATION
	dash_ready = false
	attack_time = 0.0
	forward_attack_time = 0.0
	forward_attack_lunging = false
	jump_buffer_time = 0.0
	jump_cut_available = false
	coyote_time = 0.0
	velocity = dash_direction * FREE_DASH_SPEED
	if not is_zero_approx(dash_direction.x):
		facing = 1 if dash_direction.x > 0.0 else -1
	dashed.emit(global_position)

func _update_dash(delta: float) -> void:
	dash_time = maxf(0.0, dash_time - delta)
	if not dash_is_targeted:
		velocity = dash_direction * (FREE_DASH_EXIT_SPEED if dash_time <= 0.0 else FREE_DASH_SPEED)
		return
	if not is_instance_valid(dash_target) or dash_target.get("alive") != true:
		dash_time = 0.0
		dash_target = null
		dash_is_targeted = false
		return
	velocity = global_position.direction_to(dash_target.global_position) * DASH_SPEED

func _start_dash_animation() -> void:
	dash_ghosts.clear()
	dash_ghost_clock = 0.0
	_add_dash_ghost()

func _update_visual_animation(delta: float) -> void:
	idle_clock += delta
	attack_animation_time = maxf(0.0, attack_animation_time - delta)
	attack_impact_flash = maxf(0.0, attack_impact_flash - delta)
	for i in range(dash_ghosts.size() - 1, -1, -1):
		var ghost := dash_ghosts[i]
		ghost["life"] = float(ghost["life"]) - delta
		if float(ghost["life"]) <= 0.0:
			dash_ghosts.remove_at(i)
		else:
			dash_ghosts[i] = ghost
	if dash_time > 0.0:
		dash_ghost_clock -= delta
		if dash_ghost_clock <= 0.0:
			_add_dash_ghost()
			dash_ghost_clock = DASH_GHOST_INTERVAL

func _add_dash_ghost() -> void:
	dash_ghosts.append({
		"position": global_position,
		"facing": facing,
		"life": DASH_GHOST_LIFETIME,
	})

func _check_dash_hit() -> void:
	if not dash_is_targeted:
		return
	if dash_target == null or not is_instance_valid(dash_target):
		dash_target = null
		dash_is_targeted = false
		return
	if global_position.distance_to(dash_target.global_position) <= DASH_HIT_DISTANCE:
		var hit_position := dash_target.global_position
		var exit_direction := global_position.direction_to(hit_position)
		if exit_direction.is_zero_approx():
			exit_direction = dash_direction
		var should_rebound: bool = dash_target.has_method("should_dash_rebound") and bool(dash_target.should_dash_rebound())
		if dash_target.receive_dash():
			dash_direction = exit_direction
			invulnerable_time = maxf(invulnerable_time, DASH_HIT_INVULNERABILITY)
			if should_rebound:
				velocity = Vector2(dash_entry_velocity.x, REBOUND_SPEED)
				double_jump_available = double_jump_enabled
				jump_cut_available = false
				coyote_time = 0.0
				rebounded.emit(hit_position)
			else:
				velocity = (velocity + dash_entry_velocity * 0.35).limit_length(520.0)
			dash_ready = true
			dash_connected.emit(hit_position)
		dash_time = 0.0
		dash_target = null
		dash_is_targeted = false
	elif dash_time <= 0.0:
		dash_target = null
		dash_is_targeted = false

func _check_strike() -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = strike_shape
	query.transform = Transform2D(0.0, global_position + attack_direction * 14.0)
	query.collision_mask = ATTACK_TARGET_MASK | (POGO_SPIKE_LAYER if attack_direction.y > 0.0 else 0)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	for result in get_world_2d().direct_space_state.intersect_shape(query, 8):
		var target: Object = result["collider"]
		var target_node := target as Node
		var connected: bool = attack_direction.y > 0.0 and target_node != null and target_node.is_in_group("pogo_spikes")
		if connected:
			pogo_safety_time = POGO_SAFETY_TIME
			dash_ready = dash_enabled
		elif target.has_method("receive_directional_strike"):
			connected = target.receive_directional_strike(attack_direction)
		if not connected and target.has_method("receive_kinetic_strike"):
			connected = target.receive_kinetic_strike(velocity.x)
		if not connected and target.has_method("receive_strike"):
			connected = target.receive_strike()
		if connected:
			attack_time = 0.0
			attack_impact_flash = ATTACK_IMPACT_FLASH_DURATION
			jump_cut_available = false
			coyote_time = 0.0
			if attack_direction.y > 0.0:
				dash_ready = dash_enabled
				double_jump_available = double_jump_enabled
				velocity.y = REBOUND_SPEED
				attack_connected.emit(global_position + attack_direction * 10.0)
				rebounded.emit(global_position + Vector2(0.0, 10.0))
			else:
				attack_connected.emit(global_position + attack_direction * 10.0)
			return

func _check_forward_strike() -> void:
	var attack_side := 1.0 if attack_direction.x > 0.0 else -1.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = forward_strike_shape
	query.transform = Transform2D(0.0, global_position + Vector2(attack_side * 12.0, 0.0))
	query.collision_mask = ATTACK_TARGET_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = true
	for result in get_world_2d().direct_space_state.intersect_shape(query, 8):
		var target: Object = result["collider"]
		var connected := false
		if target.has_method("receive_directional_strike"):
			connected = target.receive_directional_strike(Vector2(attack_side, 0.0))
		elif target.has_method("receive_ram_impact"):
			velocity.x = float(target.receive_ram_impact(attack_side * FORWARD_ATTACK_SPEED))
			connected = true
		if not connected and target.has_method("receive_kinetic_strike"):
			connected = target.receive_kinetic_strike(attack_side * FORWARD_ATTACK_SPEED)
		if not connected and target.has_method("receive_strike"):
			connected = target.receive_strike()
		if connected:
			forward_attack_time = 0.0
			forward_attack_lunging = false
			attack_impact_flash = ATTACK_IMPACT_FLASH_DURATION
			attack_connected.emit(global_position + Vector2(attack_side * 10.0, 0.0))
			return

func take_damage(source: Vector2) -> void:
	if not active or invulnerable_time > 0.0:
		return
	health -= 1
	health_changed.emit(health)
	attack_time = 0.0
	forward_attack_time = 0.0
	attack_animation_time = 0.0
	attack_impact_flash = 0.0
	attack_cooldown = 0.0
	pogo_safety_time = 0.0
	forward_attack_lunging = false
	dash_time = 0.0
	dash_target = null
	dash_is_targeted = false
	dash_preview_target = null
	jump_cut_available = false
	if health <= 0:
		kill(source)
		return
	invulnerable_time = 0.95
	hurt_lock = 0.16
	velocity = Vector2(95.0 if global_position.x >= source.x else -95.0, -145.0)
	queue_redraw()

func take_hazard_damage() -> bool:
	if not active or hazard_recovery_time > 0.0:
		return false
	health -= 1
	health_changed.emit(health)
	_cancel_actions()
	if health <= 0:
		kill()
		return true
	global_position = _safe_recovery_position()
	velocity = Vector2.ZERO
	invulnerable_time = 0.7
	hazard_recovery_time = 0.7
	hurt_lock = 0.12
	dash_ready = dash_enabled
	double_jump_available = double_jump_enabled
	queue_redraw()
	return true

func _safe_recovery_position() -> Vector2:
	if is_instance_valid(last_safe_platform):
		return last_safe_platform.to_global(last_safe_platform_offset)
	return last_safe_position

func _remember_safe_platform() -> void:
	if not is_on_floor() or _touching_spikes():
		return
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		if collision.get_normal().y > -0.65:
			continue
		var floor_node := collision.get_collider() as Node2D
		if floor_node == null:
			continue
		last_safe_position = global_position
		last_safe_platform = floor_node
		last_safe_platform_offset = floor_node.to_local(global_position)
		return

func _touching_spikes() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	var feet_shape := RectangleShape2D.new()
	feet_shape.size = Vector2(10, 4)
	query.shape = feet_shape
	query.transform = Transform2D(0.0, global_position + Vector2(0, 9))
	query.collision_mask = POGO_SPIKE_LAYER
	query.collide_with_areas = true
	query.collide_with_bodies = false
	return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func _cancel_actions() -> void:
	attack_time = 0.0
	forward_attack_time = 0.0
	attack_animation_time = 0.0
	attack_impact_flash = 0.0
	attack_cooldown = 0.0
	pogo_safety_time = 0.0
	forward_attack_lunging = false
	dash_time = 0.0
	dash_target = null
	dash_is_targeted = false
	dash_preview_target = null
	jump_cut_available = false

func kill(source: Vector2 = Vector2.ZERO) -> void:
	if not active:
		return
	active = false
	collision_layer = 0
	var launch_direction := Vector2(facing, -1.0).normalized()
	if not source.is_zero_approx() and global_position.distance_squared_to(source) > 1.0:
		launch_direction = source.direction_to(global_position)
	death_velocity = Vector2(launch_direction.x * 330.0, -285.0)
	death_spin_speed = (9.0 if launch_direction.x >= 0.0 else -9.0)
	death_spin = 0.0
	death_animation_time = DEATH_ANIMATION_DURATION
	velocity = Vector2.ZERO
	attack_time = 0.0
	forward_attack_time = 0.0
	attack_animation_time = 0.0
	attack_impact_flash = 0.0
	attack_cooldown = 0.0
	pogo_safety_time = 0.0
	dash_ghosts.clear()
	forward_attack_lunging = false
	dash_time = 0.0
	dash_target = null
	dash_is_targeted = false
	dash_preview_target = null
	jump_cut_available = false
	died.emit()

func reset_at(at: Vector2) -> void:
	global_position = at
	collision_layer = 2
	velocity = Vector2.ZERO
	health = 3
	last_safe_position = at
	last_safe_platform = null
	last_safe_platform_offset = Vector2.ZERO
	hazard_recovery_time = 0.0
	death_animation_time = 0.0
	death_velocity = Vector2.ZERO
	death_spin = 0.0
	death_spin_speed = 0.0
	active = true
	invulnerable_time = 0.7
	attack_time = 0.0
	forward_attack_time = 0.0
	attack_animation_time = 0.0
	attack_impact_flash = 0.0
	attack_cooldown = 0.0
	pogo_safety_time = 0.0
	dash_ghosts.clear()
	attack_direction = Vector2(facing, 0.0)
	attack_facing = facing
	forward_attack_lunging = false
	dash_time = 0.0
	dash_target = null
	dash_is_targeted = false
	dash_ready = dash_enabled
	double_jump_available = double_jump_enabled
	dash_aim_direction = Vector2.ZERO
	dash_preview_target = null
	coyote_time = 0.0
	jump_buffer_time = 0.0
	jump_cut_available = false
	hurt_lock = 0.0
	health_changed.emit(health)
	queue_redraw()

func is_striking() -> bool:
	return active and attack_time > 0.0 and attack_direction.y > 0.0

func is_pogo_safe() -> bool:
	return active and (is_striking() or pogo_safety_time > 0.0)

func is_forward_attacking() -> bool:
	return active and forward_attack_time > 0.0

func is_attacking_toward(at: Vector2) -> bool:
	if not active:
		return false
	if forward_attack_time <= 0.0 and attack_time <= 0.0:
		return false
	return attack_direction.dot(global_position.direction_to(at)) > 0.25

func is_dashing() -> bool:
	return active and dash_time > 0.0

func _draw() -> void:
	if death_animation_time > 0.0:
		_draw_death_animation()
		return
	if not active:
		return
	if circuit_style:
		_draw_circuit_hero()
		return
	_draw_dash_ghosts()
	if invulnerable_time > 0.0 and int(invulnerable_time * 14.0) % 2 == 0:
		return
	var scarf := Color("e45d54")
	var coat := Color("416d83")
	var brass := Color("edc27a")
	var ink := Color("162230")
	var visual_facing := attack_facing if attack_animation_time > 0.0 else facing
	var locomotion_moving := absf(velocity.x) > 25.0 and is_on_floor() and attack_animation_time <= 0.0 and dash_time <= 0.0
	var body_offset := Vector2.ZERO
	if attack_animation_time > 0.0:
		var attack_progress := 1.0 - attack_animation_time / ATTACK_ANIMATION_DURATION
		body_offset.x = lerpf(-2.0 * visual_facing, 2.0 * visual_facing, smoothstep(0.12, 0.58, attack_progress))
	elif dash_time > 0.0:
		body_offset = dash_direction * 2.0
	elif locomotion_moving:
		body_offset = Vector2(visual_facing * 0.75, -absf(sin(run_clock)) * 1.25)
	elif is_on_floor():
		body_offset.y = sin(idle_clock * IDLE_ANIMATION_SPEED) * 0.55
	var scarf_end: Vector2
	if dash_time > 0.0:
		scarf_end = body_offset - dash_direction * 10.0
	elif locomotion_moving:
		scarf_end = body_offset + Vector2(-visual_facing * 7.0, -1.0 + sin(run_clock - 0.8) * 1.5)
	else:
		scarf_end = body_offset + Vector2(-visual_facing * 6.0, sin(idle_clock * IDLE_ANIMATION_SPEED + 0.7))
	draw_line(body_offset + Vector2(-visual_facing * 2, -1), scarf_end, scarf, 3.0)
	if locomotion_moving:
		var arm_swing := sin(run_clock) * 2.5
		var shoulder := body_offset + Vector2(visual_facing * 3.0, 1.0)
		draw_line(shoulder, shoulder + Vector2(-visual_facing * arm_swing, 4.0), coat, 2.0)
	draw_rect(Rect2(body_offset + Vector2(-4, -1), Vector2(8, 7)), coat)
	draw_rect(Rect2(body_offset + Vector2(-4, -9), Vector2(8, 7)), brass)
	draw_rect(Rect2(body_offset + Vector2(-3, -8), Vector2(6, 4)), ink)
	var blinking := not locomotion_moving and attack_animation_time <= 0.0 and dash_time <= 0.0 and fmod(idle_clock, 3.4) > 3.24
	if not blinking:
		draw_rect(Rect2(body_offset + Vector2(1 if visual_facing > 0 else -2, -7), Vector2.ONE), Color("fff4d7"))
	if locomotion_moving:
		var gait := sin(run_clock)
		var left_hip := body_offset + Vector2(-2, 6)
		var right_hip := body_offset + Vector2(2, 6)
		var left_foot := body_offset + Vector2(-2.0 + gait * 2.5, 9.0 - maxf(0.0, -gait))
		var right_foot := body_offset + Vector2(2.0 - gait * 2.5, 9.0 - maxf(0.0, gait))
		draw_line(left_hip, left_foot, PLAYER_LEG_COLOR, 3.0)
		draw_line(right_hip, right_foot, PLAYER_LEG_COLOR, 3.0)
	else:
		var dash_tuck := 2 if dash_time > 0.0 else 0
		draw_rect(Rect2(body_offset + Vector2(-4, 6 - dash_tuck), Vector2(3, 3)), PLAYER_LEG_COLOR)
		draw_rect(Rect2(body_offset + Vector2(1, 6 - dash_tuck), Vector2(3, 3)), PLAYER_LEG_COLOR)
	if attack_animation_time > 0.0:
		_draw_attack_swing(body_offset)
	if dash_time > 0.0:
		_draw_dash_streaks()
	elif dash_enabled and dash_ready:
		draw_rect(Rect2(-2, -13, 4, 2), Color("a9f4dd"))
		if is_instance_valid(dash_preview_target):
			draw_arc(to_local(dash_preview_target.global_position), 12.0, 0.0, TAU, 16, Color("a9f4dd"), 1.0)
	if double_jump_enabled and double_jump_available and not is_on_floor():
		var wing_phase := sin(idle_clock * 12.0) * 2.0
		draw_line(Vector2(-4, 0), Vector2(-9, -2 - wing_phase), Color("d7a9ff"), 2.0)
		draw_line(Vector2(4, 0), Vector2(9, -2 - wing_phase), Color("d7a9ff"), 2.0)

func _draw_circuit_hero() -> void:
	if invulnerable_time > 0.0 and int(invulnerable_time * 12.0) % 2 == 0:
		return
	var mint := Color("b7e6bc")
	var cyan := Color("66d9d1")
	var slate := Color("344c57")
	var gait := sin(run_clock) * 2.0 if is_on_floor() and absf(velocity.x) > 25.0 else 0.0
	draw_rect(Rect2(-4, -1, 8, 7), slate)
	draw_rect(Rect2(-5, -9, 10, 8), Color("0b1720"))
	draw_arc(Vector2(0, -5), 5.0, 0.0, TAU, 16, mint, 2.0)
	draw_circle(Vector2(facing * 2, -5), 1.5, cyan)
	draw_line(Vector2(-3, 6), Vector2(-3 + gait, 9), mint, 2.0)
	draw_line(Vector2(3, 6), Vector2(3 - gait, 9), mint, 2.0)
	if attack_animation_time > 0.0:
		var direction := attack_direction.normalized()
		draw_line(direction * 5.0, direction * 20.0, cyan, 3.0)
		draw_circle(direction * 20.0, 2.0, mint)

func _draw_death_animation() -> void:
	var progress := 1.0 - death_animation_time / DEATH_ANIMATION_DURATION
	var fade := clampf(1.0 - progress * 0.82, 0.0, 1.0)
	var burst := smoothstep(0.08, 0.9, progress)
	draw_set_transform(Vector2.ZERO, death_spin, Vector2.ONE * (1.0 + sin(progress * PI) * 0.28))
	draw_rect(Rect2(Vector2(-5, -7) + Vector2(-8, -5) * burst, Vector2(9, 10)), Color(0.25, 0.43, 0.51, fade))
	draw_rect(Rect2(Vector2(0, -7) + Vector2(8, -6) * burst, Vector2(6, 10)), Color(0.25, 0.43, 0.51, fade))
	draw_rect(Rect2(Vector2(-4, 3) + Vector2(-7, 8) * burst, Vector2(3, 5)), Color(0.85, 0.6, 0.38, fade))
	draw_rect(Rect2(Vector2(1, 3) + Vector2(7, 9) * burst, Vector2(3, 5)), Color(0.85, 0.6, 0.38, fade))
	draw_line(Vector2(-5, -2) + Vector2(-9, 1) * burst, Vector2(-10, 2) + Vector2(-12, 5) * burst, Color(0.93, 0.76, 0.48, fade), 2.0)
	draw_line(Vector2(5, -2) + Vector2(9, 0) * burst, Vector2(10, 2) + Vector2(13, 4) * burst, Color(0.93, 0.76, 0.48, fade), 2.0)
	var scarf_origin := Vector2(-facing * 4, -5) + Vector2(-facing * 13, -4) * burst
	draw_line(scarf_origin, scarf_origin + Vector2(-facing * (9.0 + burst * 7.0), 3), Color(0.89, 0.36, 0.33, fade), 3.0)
	for spark_index in 6:
		var spark_direction := Vector2.from_angle(spark_index * TAU / 6.0 + 0.35)
		var spark_start := spark_direction * burst * 8.0
		draw_line(spark_start, spark_start + spark_direction * (3.0 + burst * 5.0), Color(1.0, 0.86, 0.55, fade), 1.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_attack_swing(body_offset: Vector2) -> void:
	var progress := clampf(1.0 - attack_animation_time / ATTACK_ANIMATION_DURATION, 0.0, 1.0)
	var swing_progress := smoothstep(0.12, 0.64, progress)
	var recovery := smoothstep(0.70, 1.0, progress)
	var swing_side := float(attack_facing)
	var start_offset := -2.15 * swing_side
	var end_offset := 1.05 * swing_side
	var angle_offset := lerpf(start_offset, end_offset, swing_progress)
	angle_offset = lerpf(angle_offset, 0.55 * swing_side, recovery)
	var base_angle := attack_direction.angle()
	var blade_direction := Vector2.from_angle(base_angle + angle_offset)
	var pivot := body_offset + Vector2(attack_facing * 2.0, -2.0)
	if progress > 0.16 and progress < 0.78:
		var arc_points := PackedVector2Array()
		var trail_start := lerpf(start_offset, end_offset, maxf(0.0, swing_progress - 0.34))
		for i in 10:
			var amount := float(i) / 9.0
			var trail_angle := lerpf(trail_start, angle_offset, amount)
			arc_points.append(pivot + Vector2.from_angle(base_angle + trail_angle) * 18.0)
		draw_polyline(arc_points, Color(1.0, 0.86, 0.5, 0.24), 5.0)
		draw_polyline(arc_points, Color(1.0, 0.96, 0.7, 0.9), 1.5)
	var hilt := pivot + blade_direction * 3.0
	var tip := pivot + blade_direction * 20.0
	var blade_normal := Vector2(-blade_direction.y, blade_direction.x)
	draw_line(hilt, tip, Color("162230"), 4.0)
	draw_line(hilt, tip, Color("fff1aa"), 2.0)
	draw_line(hilt - blade_normal * 3.0, hilt + blade_normal * 3.0, Color("f29662"), 2.0)
	draw_circle(pivot, 2.0, Color("edc27a"))
	if attack_impact_flash > 0.0:
		var flash := attack_impact_flash / ATTACK_IMPACT_FLASH_DURATION
		var impact_point := attack_direction * 18.0
		draw_circle(impact_point, 3.0 + flash * 3.0, Color(1.0, 0.95, 0.65, flash * 0.75), false, 2.0)
		for i in 4:
			var ray := Vector2.from_angle(float(i) * PI * 0.5 + PI * 0.25) * (5.0 + flash * 5.0)
			draw_line(impact_point + ray * 0.35, impact_point + ray, Color(1.0, 0.96, 0.75, flash), 2.0)

func _draw_dash_ghosts() -> void:
	for ghost in dash_ghosts:
		var life_ratio := clampf(float(ghost["life"]) / DASH_GHOST_LIFETIME, 0.0, 1.0)
		var at := to_local(ghost["position"] as Vector2)
		var ghost_facing := int(ghost["facing"])
		var ghost_coat := Color(0.38, 0.86, 0.82, life_ratio * 0.22)
		var ghost_light := Color(1.0, 0.94, 0.58, life_ratio * 0.18)
		draw_rect(Rect2(at + Vector2(-5, -2), Vector2(10, 8)), ghost_coat)
		draw_rect(Rect2(at + Vector2(-4, -9), Vector2(8, 7)), ghost_light)
		draw_line(at + Vector2(-ghost_facing * 2, 0), at + Vector2(-ghost_facing * 12, 0), ghost_coat, 3.0)

func _draw_dash_streaks() -> void:
	var side := Vector2(-dash_direction.y, dash_direction.x)
	for i in 3:
		var offset := side * (float(i) - 1.0) * 4.0
		var near_point := -dash_direction * (8.0 + float(i) * 2.0) + offset
		var far_point := near_point - dash_direction * (13.0 + float(i) * 5.0)
		draw_line(near_point, far_point, Color(0.66, 0.96, 0.87, 0.75 - float(i) * 0.16), 2.0 if i == 1 else 1.0)
	draw_circle(-dash_direction * 8.0, 2.0, Color("fff1ac"))
