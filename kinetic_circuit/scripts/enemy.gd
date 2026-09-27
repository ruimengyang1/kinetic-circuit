extends Area2D

signal touched_player(source: Vector2)
signal defeated(at: Vector2)
signal kinetic_struck(player_speed: float, ram_speed: float)
signal carriage_hit(ram_speed: float, carriage_speed: float)
signal wall_rebounded(side: int, incoming_speed: float, outgoing_speed: float)
signal projectile_fired(at: Vector2, direction: Vector2)
signal bomb_fired(at: Vector2, velocity: Vector2)
signal hazard_struck(at: Vector2)

const KINETIC_STRIKE_RAM_RETENTION := 0.40
const KINETIC_PLAYER_TRANSFER := 1.10
const KINETIC_MAX_SPEED := 260.0
const KINETIC_CHARGE_IMPULSE := 150.0
const KINETIC_COAST_FRICTION := 18.0
const KINETIC_IDLE_FRICTION := 85.0
const KINETIC_WINDUP := 0.44
const KINETIC_TRIGGER_RANGE := 95.0
const KINETIC_WALL_RESTITUTION := 0.48
const KINETIC_CONTACT_DISTANCE := 42.0
const TOWER_GUARD_TRIGGER_RANGE := 145.0
const WALKER_SPEED := 48.0
const DRONE_SWEEP_RATE := 2.15
const SPRING_DRONE_BOB_RATE := 2.8
const GEARWING_SWEEP_RATE := 1.75
const RELAY_BOB_RATE := 3.2
const SENTRY_PATROL_SPEED := 29.0
const TOWER_GUARD_PATROL_SPEED := 38.0
const TOWER_GUARD_WINDUP := 0.34
const TOWER_GUARD_CHARGE_SPEED := 220.0
const TOWER_GUARD_CHARGE_TIME := 0.62
const TOWER_GUARD_STUN_TIME := 0.62
const SHOOTER_PATROL_SPEED := 23.0
const SHOOTER_TRIGGER_RANGE := 350.0
const SHOOTER_AIM_TIME := 0.36
const SHOOTER_BURST_GAP := 0.12
const SHOOTER_RECOVERY_TIME := 0.62
const DEATH_ANIMATION_DURATION := 0.34
const KINETIC_RAM_HEALTH := 2
const BOSS_HEALTH := 15
const SKY_HUNTER_SPEED := 195.0
const SKY_HUNTER_PATROL_SPEED := 75.0
const SKY_HUNTER_RETURN_SPEED := 165.0
const SKY_HUNTER_BOB_SPEED := 45.0
const TITAN_DASH_WINDUP := 0.72
const TITAN_DASH_WINDUP_ENRAGED := 0.56
const TITAN_COMBO_WINDUP := 0.64
const TITAN_BOMB_WINDUP := 0.58
const TITAN_FIRST_SWING_RANGE := 82.0
const TITAN_SECOND_SWING_RANGE := 108.0
const HAZARD_LAYER := 32

var kind := "walker"
var left_bound := 0.0
var right_bound := 0.0
var home := Vector2.ZERO
var facing := 1
var health := 1
var max_health := 1
var alive := true
var circuit_style := false
var patrol_right_override := 0.0
var trigger_range_override := 0.0
var burst_gap_override := 0.0
var charge_time_override := 0.0
var clock := 0.0
var flash := 0.0
var state := "patrol"
var state_time := 0.0
var cooldown := 0.3
var kinetic_mode := false
var velocity_x := 0.0
var spawn_position := Vector2.ZERO
var contact_cooldown := 0.0
var aim_direction := Vector2.LEFT
var muzzle_flash := 0.0
var death_time := 0.0
var death_velocity := Vector2.ZERO
var death_rotation := 0.0
var death_spin_speed := 0.0
var pattern_step := 0

func configure(enemy_kind: String, at: Vector2, patrol_left: float, patrol_right: float) -> void:
	kind = enemy_kind
	position = at
	home = at
	left_bound = patrol_left
	right_bound = patrol_right
	if kind in ["boss_titan", "boss_warden"]:
		health = BOSS_HEALTH
	elif kind in ["sentry", "tower_guard", "shooter", "descent_guard", "sky_hunter"]:
		health = 2
	else:
		health = 1
	max_health = health
	spawn_position = at

func configure_kinetic_ram(at: Vector2, movement_left: float, movement_right: float) -> void:
	kinetic_mode = true
	kind = "kinetic_ram"
	position = at
	home = at
	spawn_position = at
	left_bound = movement_left
	right_bound = movement_right
	facing = 1
	state = "idle"
	state_time = 0.3
	cooldown = 0.3
	velocity_x = 0.0
	health = KINETIC_RAM_HEALTH
	max_health = health

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("runtime_cullables")
	if not kinetic_mode and kind != "boss_titan":
		add_to_group("dash_targets")
	if kind in ["spring_drone", "gearwing"]:
		add_to_group("vertical_dual_targets")
	collision_layer = 16
	collision_mask = 2 | HAZARD_LAYER if kind in ["tower_guard", "descent_guard", "boss_titan"] else 2
	monitoring = true
	monitorable = true
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	match kind:
		"drone", "relay", "dash_relay": shape.size = Vector2(18, 12)
		"spring_drone", "gearwing", "sky_hunter": shape.size = Vector2(20, 14)
		"boss_titan": shape.size = Vector2(50, 38)
		"boss_warden": shape.size = Vector2(30, 26)
		"sentry", "tower_guard", "descent_guard", "shooter", "kinetic_ram": shape.size = Vector2(20, 20)
		_: shape.size = Vector2(16, 13)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if state == "dying":
		clock += delta
		death_time = maxf(0.0, death_time - delta)
		death_velocity.y += 420.0 * delta
		position += death_velocity * delta
		death_rotation += death_spin_speed * delta
		queue_redraw()
		if death_time <= 0.0:
			if kinetic_mode:
				state = "defeated"
				hide()
			else:
				queue_free()
		return
	if not alive:
		return
	clock += delta
	flash = maxf(0.0, flash - delta)
	muzzle_flash = maxf(0.0, muzzle_flash - delta)
	contact_cooldown = maxf(0.0, contact_cooldown - delta)
	match kind:
		"walker":
			position.x += facing * WALKER_SPEED * delta
			if position.x >= right_bound:
				position.x = right_bound
				facing = -1
			elif position.x <= left_bound:
				position.x = left_bound
				facing = 1
		"drone":
			position.x = home.x + sin(clock * DRONE_SWEEP_RATE) * (right_bound - left_bound) * 0.5
			position.y = home.y + sin(clock * 3.1) * 6.0
		"spring_drone":
			position.y = home.y + sin(clock * SPRING_DRONE_BOB_RATE) * 7.0
		"gearwing":
			position.x = home.x + sin(clock * GEARWING_SWEEP_RATE) * (right_bound - left_bound) * 0.5
			position.y = home.y - 5.0 + cos(clock * 3.4) * 2.0
		"relay", "dash_relay":
			position.y = home.y + sin(clock * RELAY_BOB_RATE) * 4.0
		"sentry":
			_update_sentry(delta)
		"tower_guard", "descent_guard":
			_update_sentry(delta)
		"shooter":
			_update_shooter(delta)
		"sky_hunter":
			_update_sky_hunter(delta)
		"boss_titan":
			_update_boss_titan(delta)
		"boss_warden":
			_update_boss_warden(delta)
		"kinetic_ram":
			_update_kinetic_ram(delta)
	queue_redraw()

func _update_kinetic_ram(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	match state:
		"idle":
			velocity_x = move_toward(velocity_x, 0.0, KINETIC_IDLE_FRICTION * delta)
			cooldown = maxf(0.0, cooldown - delta)
			if player != null and cooldown <= 0.0 and absf(player.global_position.x - global_position.x) <= KINETIC_TRIGGER_RANGE:
				state = "windup"
				state_time = KINETIC_WINDUP
		"windup":
			velocity_x = move_toward(velocity_x, 0.0, KINETIC_IDLE_FRICTION * delta)
			state_time = maxf(0.0, state_time - delta)
			if player != null and not is_zero_approx(player.global_position.x - global_position.x):
				facing = 1 if player.global_position.x > global_position.x else -1
			if state_time <= 0.0:
				velocity_x = clampf(velocity_x + facing * KINETIC_CHARGE_IMPULSE, -KINETIC_MAX_SPEED, KINETIC_MAX_SPEED)
				state = "coast"
		"coast":
			velocity_x = move_toward(velocity_x, 0.0, KINETIC_COAST_FRICTION * delta)
			if absf(velocity_x) < 8.0:
				state = "recover"
				state_time = 0.35
		"recover":
			velocity_x = move_toward(velocity_x, 0.0, KINETIC_IDLE_FRICTION * delta)
			state_time = maxf(0.0, state_time - delta)
			if state_time <= 0.0:
				state = "idle"
				cooldown = 0.2
	position.x += velocity_x * delta
	if position.x < left_bound:
		var incoming_left := velocity_x
		position.x = left_bound
		velocity_x = absf(velocity_x) * KINETIC_WALL_RESTITUTION
		state = "recover"
		state_time = 0.3
		wall_rebounded.emit(-1, incoming_left, velocity_x)
	elif position.x > right_bound:
		var incoming_right := velocity_x
		position.x = right_bound
		velocity_x = -absf(velocity_x) * KINETIC_WALL_RESTITUTION
		state = "recover"
		state_time = 0.3
		wall_rebounded.emit(1, incoming_right, velocity_x)
	_check_kinetic_carriage_contact()

func _check_kinetic_carriage_contact() -> void:
	if contact_cooldown > 0.0:
		return
	var carriage := get_tree().get_first_node_in_group("kinetic_carriage") as Node2D
	if carriage == null or not carriage.has_method("receive_ram_impact"):
		return
	if absf(carriage.global_position.y - global_position.y) > 22.0:
		return
	var offset := carriage.global_position.x - global_position.x
	var direction := signf(offset)
	var carriage_velocity := float(carriage.get("velocity_x"))
	if is_zero_approx(direction):
		direction = 1.0 if velocity_x >= carriage_velocity else -1.0
	var relative_speed: float = velocity_x - carriage_velocity
	if absf(offset) > KINETIC_CONTACT_DISTANCE or relative_speed * direction <= 8.0:
		return
	var incoming := velocity_x
	global_position.x = carriage.global_position.x - direction * KINETIC_CONTACT_DISTANCE
	velocity_x = float(carriage.call("receive_ram_impact", incoming))
	contact_cooldown = 0.12
	state = "recover"
	state_time = 0.3
	carriage_hit.emit(incoming, float(carriage.get("velocity_x")))

func _update_sentry(delta: float) -> void:
	state_time = maxf(0.0, state_time - delta)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var is_charging_guard := kind in ["tower_guard", "descent_guard"]
	var is_descent_guard := kind == "descent_guard"
	var patrol_speed := 46.0 if is_descent_guard else TOWER_GUARD_PATROL_SPEED if is_charging_guard else SENTRY_PATROL_SPEED
	var trigger_range := 190.0 if is_descent_guard else TOWER_GUARD_TRIGGER_RANGE if is_charging_guard else 120.0
	if trigger_range_override > 0.0:
		trigger_range = trigger_range_override
	match state:
		"patrol":
			position.x += facing * patrol_speed * delta
			var patrol_right := patrol_right_override if patrol_right_override > left_bound else right_bound
			if position.x >= patrol_right or position.x <= left_bound:
				position.x = clampf(position.x, left_bound, patrol_right)
				facing *= -1
			cooldown = maxf(0.0, cooldown - delta)
			if player != null and cooldown <= 0.0 and absf(player.global_position.x - global_position.x) < trigger_range and absf(player.global_position.y - global_position.y) < (78.0 if is_descent_guard else 48.0):
				facing = 1 if player.global_position.x > global_position.x else -1
				state = "windup"
				state_time = 0.24 if is_descent_guard else TOWER_GUARD_WINDUP if is_charging_guard else 0.55
		"windup":
			if state_time <= 0.0:
				state = "charge"
				state_time = charge_time_override if charge_time_override > 0.0 else 0.72 if is_descent_guard else TOWER_GUARD_CHARGE_TIME if is_charging_guard else 0.5
		"charge":
			position.x += facing * (245.0 if is_descent_guard else TOWER_GUARD_CHARGE_SPEED if is_charging_guard else 155.0) * delta
			if is_charging_guard and _try_charge_hazard_impact(0.48 if is_descent_guard else TOWER_GUARD_STUN_TIME):
				return
			if position.x <= left_bound or position.x >= right_bound or state_time <= 0.0:
				position.x = clampf(position.x, left_bound, right_bound)
				state = "stunned" if is_charging_guard else "recover"
				state_time = 0.48 if is_descent_guard else TOWER_GUARD_STUN_TIME if is_charging_guard else 0.75
		"stunned":
			if state_time <= 0.0:
				state = "patrol"
				cooldown = 0.5
		"recover":
			if state_time <= 0.0:
				state = "patrol"
				cooldown = 0.55

func _update_shooter(delta: float) -> void:
	state_time = maxf(0.0, state_time - delta)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	match state:
		"patrol":
			cooldown = maxf(0.0, cooldown - delta)
			position.x += facing * SHOOTER_PATROL_SPEED * delta
			if position.x >= right_bound or position.x <= left_bound:
				position.x = clampf(position.x, left_bound, right_bound)
				facing *= -1
			if player == null or cooldown > 0.0:
				return
			var offset := player.global_position - global_position
			var shot_range := trigger_range_override if trigger_range_override > 0.0 else SHOOTER_TRIGGER_RANGE
			if offset.length() > shot_range or absf(offset.y) > 185.0 or not _has_clear_shot(player.global_position):
				return
			facing = 1 if offset.x >= 0.0 else -1
			aim_direction = offset.normalized()
			state = "aim"
			state_time = SHOOTER_AIM_TIME
		"aim":
			if state_time <= 0.0:
				_fire_shooter_round()
				state = "burst"
				state_time = burst_gap_override if burst_gap_override > 0.0 else SHOOTER_BURST_GAP
		"burst":
			if state_time <= 0.0:
				_fire_shooter_round()
				state = "recover"
				state_time = SHOOTER_RECOVERY_TIME
		"recover":
			if state_time <= 0.0:
				state = "patrol"
				cooldown = 0.28

func _update_sky_hunter(delta: float) -> void:
	state_time = maxf(0.0, state_time - delta)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	match state:
		"patrol":
			position.x += facing * SKY_HUNTER_PATROL_SPEED * delta
			if position.x >= right_bound or position.x <= left_bound:
				position.x = clampf(position.x, left_bound, right_bound)
				facing *= -1
			position.y = move_toward(position.y, home.y + sin(clock * 3.1) * 9.0, SKY_HUNTER_BOB_SPEED * delta)
			cooldown = maxf(0.0, cooldown - delta)
			if player != null and cooldown <= 0.0 and global_position.distance_to(player.global_position) < 225.0:
				aim_direction = global_position.direction_to(player.global_position)
				facing = 1 if aim_direction.x >= 0.0 else -1
				state = "windup"
				state_time = 0.24
		"windup":
			position.y += sin(clock * 28.0) * 0.35
			if player != null:
				aim_direction = global_position.direction_to(player.global_position)
			if state_time <= 0.0:
				state = "charge"
				state_time = 0.52
		"charge":
			position += aim_direction * SKY_HUNTER_SPEED * delta
			if state_time <= 0.0:
				state = "recover"
				state_time = 0.48
		"recover":
			position = position.move_toward(home, SKY_HUNTER_RETURN_SPEED * delta)
			if state_time <= 0.0 and position.is_equal_approx(home):
				state = "patrol"
				cooldown = 0.42

func _update_boss_titan(delta: float) -> void:
	state_time = maxf(0.0, state_time - delta)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var enraged := health <= max_health / 2
	match state:
		"patrol":
			position.x += facing * (58.0 if enraged else 42.0) * delta
			if position.x <= left_bound or position.x >= right_bound:
				position.x = clampf(position.x, left_bound, right_bound)
				facing *= -1
			cooldown = maxf(0.0, cooldown - delta)
			if player != null and cooldown <= 0.0 and global_position.distance_to(player.global_position) < 430.0:
				facing = 1 if player.global_position.x >= global_position.x else -1
				var next_pattern: int = pattern_step % 3
				match next_pattern:
					0:
						state = "dash_windup"
						state_time = TITAN_DASH_WINDUP_ENRAGED if enraged else TITAN_DASH_WINDUP
					1:
						state = "combo_windup"
						state_time = TITAN_COMBO_WINDUP
					2:
						state = "bomb_windup"
						state_time = TITAN_BOMB_WINDUP
		"dash_windup":
			if player != null and state_time > 0.2:
				facing = 1 if player.global_position.x >= global_position.x else -1
			if state_time <= 0.0:
				state = "charge"
				state_time = 0.82
				contact_cooldown = 0.0
		"charge":
			position.x += facing * (300.0 if enraged else 255.0) * delta
			if _try_charge_hazard_impact(0.38 if enraged else 0.55):
				return
			_try_titan_charge_hit(player)
			if position.x <= left_bound or position.x >= right_bound or state_time <= 0.0:
				position.x = clampf(position.x, left_bound, right_bound)
				state = "stunned"
				state_time = 0.38 if enraged else 0.55
		"combo_windup":
			if player != null:
				facing = 1 if player.global_position.x >= global_position.x else -1
			if state_time <= 0.0:
				state = "combo_first"
				state_time = 0.18
				contact_cooldown = 0.0
		"combo_first":
			_try_titan_melee_hit(player, TITAN_FIRST_SWING_RANGE)
			if state_time <= 0.0:
				state = "combo_gap"
				state_time = 0.16
		"combo_gap":
			if state_time <= 0.0:
				state = "combo_second"
				state_time = 0.24
				contact_cooldown = 0.0
		"combo_second":
			_try_titan_melee_hit(player, TITAN_SECOND_SWING_RANGE)
			if state_time <= 0.0:
				state = "recover"
				state_time = 0.46
		"bomb_windup":
			if player != null:
				facing = 1 if player.global_position.x >= global_position.x else -1
			if state_time <= 0.0:
				var throw_speed := 190.0 if enraged else 165.0
				bomb_fired.emit(global_position + Vector2(facing * 18.0, -17.0), Vector2(facing * throw_speed, -165.0))
				muzzle_flash = 0.12
				state = "recover"
				state_time = 0.42
		"recover":
			if state_time <= 0.0:
				pattern_step += 1
				state = "patrol"
				cooldown = 0.18 if enraged else 0.34
		"stunned":
			if state_time <= 0.0:
				pattern_step += 1
				state = "patrol"
				cooldown = 0.18 if enraged else 0.34

func _try_titan_melee_hit(player: Node2D, attack_range: float) -> void:
	if player == null or contact_cooldown > 0.0:
		return
	var offset := player.global_position - global_position
	var forward_distance := offset.x * facing
	if forward_distance < -12.0 or forward_distance > attack_range or absf(offset.y) > 38.0:
		return
	contact_cooldown = 0.3
	touched_player.emit(global_position + Vector2(facing * minf(attack_range, maxf(24.0, forward_distance)), 0.0))

func _try_titan_charge_hit(player: Node2D) -> void:
	if player == null or contact_cooldown > 0.0:
		return
	var offset := player.global_position - global_position
	if absf(offset.x) > 38.0 or absf(offset.y) > 30.0:
		return
	contact_cooldown = 0.3
	touched_player.emit(global_position + Vector2(facing * 24.0, 0.0))

func _try_charge_hazard_impact(stun_duration: float) -> bool:
	for hazard in get_overlapping_areas():
		if not hazard.is_in_group("pogo_spikes"):
			continue
		hazard_struck.emit(global_position)
		if not _receive_standard_hit():
			return false
		if alive:
			state = "stunned"
			state_time = stun_duration
		return true
	return false

func _update_boss_warden(delta: float) -> void:
	state_time = maxf(0.0, state_time - delta)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var enraged := health <= max_health / 2
	match state:
		"patrol":
			position.x = home.x + sin(clock * (1.7 if enraged else 1.25)) * (right_bound - left_bound) * 0.5
			position.y = home.y + cos(clock * 2.1) * 42.0
			cooldown = maxf(0.0, cooldown - delta)
			if player != null and cooldown <= 0.0 and global_position.distance_to(player.global_position) < 520.0:
				aim_direction = global_position.direction_to(player.global_position)
				facing = 1 if aim_direction.x >= 0.0 else -1
				state = "aim"
				state_time = 0.28 if enraged else 0.4
		"aim":
			if player != null:
				aim_direction = global_position.direction_to(player.global_position)
			if state_time <= 0.0:
				_fire_boss_spread(player, 7 if enraged else 5, 0.13)
				state = "charge"
				state_time = 0.42
		"charge":
			position += aim_direction * (215.0 if enraged else 175.0) * delta
			if state_time <= 0.0:
				state = "recover"
				state_time = 0.62
		"recover":
			position = position.lerp(home, minf(1.0, delta * 3.2))
			if state_time <= 0.0:
				pattern_step += 1
				state = "patrol"
				cooldown = 0.2 if enraged else 0.38

func _fire_boss_spread(player: Node2D, count: int, spacing: float) -> void:
	var base_direction := aim_direction
	if player != null:
		base_direction = global_position.direction_to(player.global_position)
	if base_direction.is_zero_approx():
		base_direction = Vector2(facing, 0.0)
	for projectile_index in count:
		var centered_index := float(projectile_index) - float(count - 1) * 0.5
		var direction := base_direction.rotated(centered_index * spacing)
		projectile_fired.emit(global_position + direction * 18.0, direction)
	muzzle_flash = 0.12

func _has_clear_shot(target: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, target, 1, [get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _fire_shooter_round() -> void:
	if aim_direction.is_zero_approx():
		return
	muzzle_flash = 0.09
	projectile_fired.emit(global_position + aim_direction * 14.0, aim_direction)

func _boss_required_tool() -> String:
	if kind != "boss_warden":
		return ""
	var damage_taken := max_health - health
	if damage_taken < 5:
		return "STRIKE"
	if damage_taken < 10:
		return "DASH"
	if damage_taken < 15:
		return "POGO"
	return "REFLECT"

func _reject_armored_hit() -> bool:
	flash = 0.08
	queue_redraw()
	return false

func receive_directional_strike(direction: Vector2) -> bool:
	if kinetic_mode:
		return false
	if kind == "dash_relay":
		return _reject_armored_hit()
	if kind == "boss_titan":
		return _receive_standard_hit()
	if kind == "boss_warden":
		var required_tool := _boss_required_tool()
		if required_tool == "STRIKE" or (required_tool == "POGO" and direction.y > 0.5):
			return _receive_standard_hit()
		return _reject_armored_hit()
	return _receive_standard_hit()

func receive_strike() -> bool:
	if kind == "dash_relay":
		flash = 0.14
		queue_redraw()
		return false
	if kind == "boss_warden" and _boss_required_tool() != "STRIKE":
		return _reject_armored_hit()
	return _receive_standard_hit()

func receive_dash() -> bool:
	if kind == "boss_titan":
		return false
	if kind == "boss_warden" and _boss_required_tool() != "DASH":
		flash = 0.08
		queue_redraw()
		return true
	return _receive_standard_hit()

func receive_projectile_strike() -> bool:
	if kind == "boss_titan":
		return _receive_standard_hit()
	if kind == "boss_warden":
		if _boss_required_tool() == "REFLECT":
			return _receive_standard_hit()
		return _reject_armored_hit()
	return _receive_standard_hit()

func should_dash_rebound() -> bool:
	return kind not in ["relay", "dash_relay"]

func _receive_standard_hit() -> bool:
	if not alive:
		return false
	health -= 1
	flash = 0.14
	if health <= 0:
		_begin_death()
	elif kind in ["sentry", "tower_guard", "descent_guard", "shooter", "sky_hunter"]:
		state = "recover"
		state_time = 0.55 if kind == "shooter" else 0.48 if kind == "sky_hunter" else 0.8
	return true

func _begin_death() -> void:
	alive = false
	collision_layer = 0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	remove_from_group("dash_targets")
	state = "dying"
	death_time = DEATH_ANIMATION_DURATION
	death_velocity = Vector2(-facing * 85.0, -125.0)
	death_spin_speed = -facing * 8.0
	death_rotation = 0.0
	defeated.emit(global_position)
	queue_redraw()

func receive_kinetic_strike(player_velocity_x: float) -> bool:
	if not kinetic_mode or not alive:
		return false
	velocity_x = clampf(
		velocity_x * KINETIC_STRIKE_RAM_RETENTION + player_velocity_x * KINETIC_PLAYER_TRANSFER,
		-KINETIC_MAX_SPEED,
		KINETIC_MAX_SPEED
	)
	health -= 1
	flash = 0.14
	kinetic_struck.emit(player_velocity_x, velocity_x)
	if health <= 0:
		_begin_death()
	else:
		state = "coast"
		state_time = 0.0
		contact_cooldown = 0.08
	return true

func reset_kinetic() -> void:
	show()
	position = spawn_position
	home = spawn_position
	velocity_x = 0.0
	health = KINETIC_RAM_HEALTH
	facing = 1
	state = "idle"
	state_time = 0.3
	cooldown = 0.3
	contact_cooldown = 0.0
	death_time = 0.0
	death_velocity = Vector2.ZERO
	death_rotation = 0.0
	death_spin_speed = 0.0
	alive = true
	collision_layer = 16
	monitoring = true
	monitorable = true
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if not alive or not body.is_in_group("player"):
		return
	if kind == "tower_guard" and state == "stunned":
		return
	if kind == "boss_titan":
		return
	var reach := Vector2(24, 27) if kind == "boss_warden" else Vector2(16, 19) if kind in ["sentry", "tower_guard", "descent_guard", "shooter", "kinetic_ram"] else Vector2(15, 16)
	if absf(body.global_position.x - global_position.x) > reach.x or absf(body.global_position.y - global_position.y) > reach.y:
		return
	if body.has_method("is_dashing") and body.is_dashing():
		return
	if body.has_method("is_attacking_toward") and body.is_attacking_toward(global_position):
		return
	touched_player.emit(global_position)

func _draw() -> void:
	if state == "dying":
		_draw_death_animation()
		return
	if circuit_style and kind in ["tower_guard", "shooter"]:
		_draw_circuit_actor()
		return
	var ink := Color("162230")
	var steel := Color("658c94")
	var brass := Color("d4a65e")
	var eye := Color("f4dd8d")
	if flash > 0.0:
		steel = Color("fff1b8")
		brass = Color("fff1b8")
	match kind:
		"walker": _draw_walker(ink, steel, brass, eye)
		"drone", "relay", "dash_relay":
			_draw_flying_unit(ink, steel, brass, eye)
		"spring_drone": _draw_spring_drone(ink)
		"gearwing": _draw_gearwing(ink)
		"sky_hunter": _draw_sky_hunter(ink, brass, eye)
		"boss_titan", "boss_warden": _draw_boss(ink, steel, brass, eye)
		"sentry", "tower_guard", "descent_guard", "shooter", "kinetic_ram":
			_draw_heavy_unit(ink, steel, brass, eye)

func _draw_circuit_actor() -> void:
	var warning := Color("ec7156")
	var shell := Color("344c57")
	var mint := Color("b7e6bc")
	if kind == "tower_guard":
		var low := 3.0 if state == "stunned" else 0.0
		draw_rect(Rect2(-11, -9 + low, 22, 15 - low), Color("0b1720"))
		draw_rect(Rect2(-8, -7 + low, 16, 10 - low), shell)
		draw_rect(Rect2(-12, 4, 24, 4), Color("617985"))
		draw_circle(Vector2(facing * 4, -3 + low), 2.0, warning if state in ["windup", "charge"] else mint)
		if state in ["windup", "charge"]:
			var reach := 25.0 if state == "windup" else 32.0
			draw_line(Vector2(facing * 9, 7), Vector2(facing * reach, 7), warning, 2.0)
			draw_colored_polygon(PackedVector2Array([Vector2(facing * reach, 3), Vector2(facing * (reach + 6), 7), Vector2(facing * reach, 11)]), warning)
		elif state == "stunned":
			draw_line(Vector2(-6, -13), Vector2(-2, -17), mint, 2.0)
			draw_line(Vector2(3, -15), Vector2(8, -12), mint, 2.0)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(-12, 8), Vector2(12, 8), Vector2(7, -7), Vector2(-7, -7)]), Color("0b1720"))
		draw_rect(Rect2(-7, -6, 14, 11), shell)
		var aim := aim_direction if state in ["aim", "burst"] else Vector2(facing, 0.0)
		draw_line(aim * 3.0, aim * 17.0, warning, 4.0)
		draw_circle(aim * 17.0, 2.0, mint)
		if state == "aim":
			for segment in range(3, 16, 2):
				draw_line(aim * (18.0 + segment * 5.0), aim * (20.0 + segment * 5.0), warning, 1.0)
		if muzzle_flash > 0.0:
			draw_circle(aim * 19.0, 4.0, Color("fff1ac"))
	for pip in 2:
		draw_rect(Rect2(-7 + pip * 8, -15, 6, 2), mint if pip < health else Color("455763"))

func _draw_death_animation() -> void:
	var progress := 1.0 - death_time / DEATH_ANIMATION_DURATION
	var fade := clampf(1.0 - progress * 0.9, 0.0, 1.0)
	var body_color := Color("64d8d0") if kind in ["relay", "dash_relay"] else Color("805f68") if kind == "tower_guard" else Color("596f8e") if kind == "shooter" else Color("658c94")
	for fragment_index in 8:
		var direction := Vector2.from_angle(fragment_index * TAU / 8.0 + death_rotation)
		var distance := 4.0 + progress * (13.0 + float(fragment_index % 3) * 4.0)
		var fragment_center := direction * distance
		var fragment_size := Vector2(5, 3) if fragment_index % 2 == 0 else Vector2(3, 5)
		draw_rect(Rect2(fragment_center - fragment_size * 0.5, fragment_size), Color(body_color.r, body_color.g, body_color.b, fade))
		draw_line(fragment_center, fragment_center + direction * (3.0 + progress * 5.0), Color(1.0, 0.75, 0.38, fade), 1.2)
	draw_circle(Vector2.ZERO, maxf(0.0, 6.0 * (1.0 - progress)), Color(1.0, 0.9, 0.62, fade))

func _draw_walker(ink: Color, steel: Color, brass: Color, eye: Color) -> void:
	var stride := sin(clock * 15.0)
	var bob := -absf(stride) * 1.5
	var lean := facing * 1.0
	draw_line(Vector2(-4, 3 + bob), Vector2(-5 + stride * 3.0, 8), ink, 3.0)
	draw_line(Vector2(4, 3 + bob), Vector2(5 - stride * 3.0, 8), ink, 3.0)
	draw_rect(Rect2(-8 + lean, -5 + bob, 16, 9), ink)
	draw_rect(Rect2(-6 + lean, -6 + bob, 12, 8), brass)
	draw_rect(Rect2(-4 + lean, -8 + bob, 8, 3), steel)
	draw_rect(Rect2(2 * facing + lean, -3 + bob, 2, 2), eye)
	draw_line(Vector2(-facing * 5 + lean, -1 + bob), Vector2(-facing * 9 + lean, 2 - stride * 2.0), steel, 2.0)

func _draw_flying_unit(ink: Color, steel: Color, brass: Color, eye: Color) -> void:
	var rotor_phase := sin(clock * 27.0)
	var body_bob := sin(clock * 6.0) * 0.8
	var relay_color := Color("64d8d0") if kind == "dash_relay" else Color("397c82") if kind == "relay" else steel
	var relay_eye := Color("d5fff2") if kind == "dash_relay" else Color("a9f4dd") if kind == "relay" else eye
	draw_rect(Rect2(-9, -4 + body_bob, 18, 8), ink)
	draw_rect(Rect2(-7, -3 + body_bob, 14, 6), relay_color)
	var core_size := 4.0 + sin(clock * 9.0) if kind in ["relay", "dash_relay"] else 4.0
	draw_circle(Vector2(0, body_bob), core_size * 0.5, relay_eye)
	draw_rect(Rect2(-11, -6 + body_bob, 5, 2), brass)
	draw_rect(Rect2(6, -6 + body_bob, 5, 2), brass)
	for rotor_x in [-9.0, 9.0]:
		draw_line(Vector2(rotor_x - 5.0 * rotor_phase, -8 + body_bob), Vector2(rotor_x + 5.0 * rotor_phase, -8 + body_bob), Color("9ac6c7"), 1.5)
	if kind == "dash_relay":
		var armor_pulse := 1.0 + sin(clock * 8.0) * 0.12
		draw_line(Vector2(-12, -7) * armor_pulse, Vector2(-8, -10) * armor_pulse, Color("a9f4dd"), 2.0)
		draw_line(Vector2(12, -7) * armor_pulse, Vector2(8, -10) * armor_pulse, Color("a9f4dd"), 2.0)
		draw_line(Vector2(-12, 7) * armor_pulse, Vector2(-8, 10) * armor_pulse, Color("a9f4dd"), 2.0)
		draw_line(Vector2(12, 7) * armor_pulse, Vector2(8, 10) * armor_pulse, Color("a9f4dd"), 2.0)

func _draw_spring_drone(ink: Color) -> void:
	var bounce := sin(clock * 11.0)
	var squash := absf(bounce) * 1.2
	draw_rect(Rect2(-10 - squash, -5 + squash * 0.5, 20 + squash * 2.0, 10 - squash), ink)
	draw_rect(Rect2(-8 - squash, -4 + squash * 0.5, 16 + squash * 2.0, 8 - squash), Color("4fa39b"))
	draw_rect(Rect2(-11, -8 - squash, 22, 4), Color("f0bd68"))
	draw_rect(Rect2(-5, -7 - squash, 10, 2), Color("fff1ac"))
	draw_circle(Vector2(0, -1), 2.5 + maxf(0.0, bounce), Color("d5fff2"))
	var coil_height := 3.0 + (bounce + 1.0) * 2.0
	draw_line(Vector2(-5, 6), Vector2(5, 6 + coil_height), Color("88bbc0"), 2.0)
	draw_line(Vector2(5, 6 + coil_height), Vector2(-5, 8 + coil_height), Color("88bbc0"), 2.0)

func _draw_gearwing(ink: Color) -> void:
	var flap := sin(clock * 23.0)
	var gear_angle := clock * 5.0
	draw_line(Vector2(-7, -2), Vector2(-16, -5 + flap * 5.0), Color("a9f4dd"), 3.0)
	draw_line(Vector2(7, -2), Vector2(16, -5 - flap * 5.0), Color("a9f4dd"), 3.0)
	draw_line(Vector2(-13, -4 + flap * 4.0), Vector2(-18, -1 + flap * 6.0), Color(0.66, 0.96, 0.87, 0.55), 2.0)
	draw_line(Vector2(13, -4 - flap * 4.0), Vector2(18, -1 - flap * 6.0), Color(0.66, 0.96, 0.87, 0.55), 2.0)
	draw_circle(Vector2.ZERO, 8.0, ink)
	draw_circle(Vector2.ZERO, 6.0, Color("6d879d"))
	for spoke in 4:
		var direction := Vector2.from_angle(gear_angle + spoke * PI * 0.5)
		draw_line(direction * 2.0, direction * 6.0, Color("b6c9c7"), 1.5)
	draw_circle(Vector2.ZERO, 2.0, Color("fff1ac"))
	draw_rect(Rect2(-5, 6, 10, 3), Color("f0bd68"))

func _draw_sky_hunter(ink: Color, brass: Color, eye: Color) -> void:
	var charge_stretch := 4.0 if state == "charge" else 0.0
	var wing := sin(clock * (26.0 if state == "charge" else 15.0)) * 4.0
	draw_line(Vector2(-7, 0), Vector2(-16 - charge_stretch, -5 + wing), Color("a97fd1"), 3.0)
	draw_line(Vector2(7, 0), Vector2(16 + charge_stretch, -5 - wing), Color("a97fd1"), 3.0)
	draw_circle(Vector2.ZERO, 8.0, ink)
	draw_circle(Vector2.ZERO, 5.5, Color("6f4e89"))
	draw_circle(Vector2(facing * 3, -1), 2.0, Color("ff8a66") if state == "windup" else eye)
	for spoke_index in 4:
		var direction := Vector2.from_angle(clock * 4.0 + spoke_index * TAU / 4.0)
		draw_line(direction * 2.0, direction * 6.0, brass, 1.5)
	if state == "windup":
		draw_arc(Vector2.ZERO, 12.0 + absf(sin(clock * 20.0)) * 3.0, 0.0, TAU, 16, Color("ff8a66"), 1.5)

func _draw_boss(ink: Color, steel: Color, brass: Color, eye: Color) -> void:
	var pulse := sin(clock * 8.0)
	if kind == "boss_titan":
		var idle_bob := sin(clock * 5.0) * 0.8 if state == "patrol" else 0.0
		var lean := Vector2(facing, idle_bob)
		if state == "dash_windup":
			lean = Vector2(-facing * (2.0 + sin(clock * 32.0) * 1.5), 3.0)
		elif state == "charge":
			lean = Vector2(facing * 5.0, -1.0)
		elif state == "combo_windup":
			lean = Vector2(-facing * 2.0, 2.0)
		elif state in ["combo_first", "combo_second"]:
			lean = Vector2(facing * 3.0, -1.0)
		elif state == "bomb_windup":
			lean = Vector2(-facing, 1.0)
		elif state == "stunned":
			lean = Vector2(sin(clock * 27.0) * 2.5, 2.0)
		draw_rect(Rect2(Vector2(-18, -15) + lean, Vector2(36, 28)), ink)
		draw_rect(Rect2(Vector2(-15, -13) + lean, Vector2(30, 23)), Color("704c48"))
		draw_rect(Rect2(Vector2(-13, -10) + lean, Vector2(26, 5)), brass)
		var alert_state := state in ["dash_windup", "combo_windup", "bomb_windup"]
		draw_circle(Vector2(facing * 8, -3) + lean, 3.0, Color("ff5b4d") if alert_state else eye)
		for wheel_x in [-11.0, 11.0]:
			draw_circle(Vector2(wheel_x, 13) + lean, 6.0, ink)
			var wheel_speed := 16.0 if state == "charge" else 6.0 if state == "patrol" else 2.0
			draw_arc(Vector2(wheel_x, 13) + lean, 4.0, clock * wheel_speed, clock * wheel_speed + PI * 1.6, 8, steel, 2.0)
		var hammer_anchor := Vector2(facing * 12, -2) + lean
		var hammer_end := Vector2(facing * 25, 8) + lean
		var swing_progress := -1.0
		if state in ["dash_windup", "combo_windup"]:
			var charge_shake := sin(clock * 18.0) * 2.0 if state == "combo_windup" else 0.0
			hammer_end = Vector2(-facing * (10.0 + charge_shake), -29.0 - absf(charge_shake)) + lean
		elif state == "combo_first":
			swing_progress = clampf(1.0 - state_time / 0.18, 0.0, 1.0)
			var first_angle := lerpf(-1.82, 0.18, smoothstep(0.0, 1.0, swing_progress))
			hammer_end = hammer_anchor + Vector2(cos(first_angle) * facing, sin(first_angle)) * 52.0
		elif state == "combo_gap":
			var reset_sway := sin(clock * 22.0) * 3.0
			hammer_end = Vector2(-facing * (17.0 + reset_sway), -22.0) + lean
		elif state == "combo_second":
			swing_progress = clampf(1.0 - state_time / 0.24, 0.0, 1.0)
			var second_angle := lerpf(-2.15, 0.32, smoothstep(0.0, 1.0, swing_progress))
			hammer_end = hammer_anchor + Vector2(cos(second_angle) * facing, sin(second_angle)) * 68.0
		elif state == "charge":
			hammer_end = Vector2(facing * 31, 5) + lean
		if swing_progress >= 0.0:
			for trail_index in range(1, 4):
				var trail_progress := maxf(0.0, swing_progress - float(trail_index) * 0.11)
				var trail_angle := lerpf(-1.82 if state == "combo_first" else -2.15, 0.18 if state == "combo_first" else 0.32, smoothstep(0.0, 1.0, trail_progress))
				var trail_length := 52.0 if state == "combo_first" else 68.0
				var trail_end := hammer_anchor + Vector2(cos(trail_angle) * facing, sin(trail_angle)) * trail_length
				draw_line(hammer_anchor, trail_end, Color(0.85, 0.45, 0.3, 0.2 - float(trail_index) * 0.04), 3.0)
		draw_line(hammer_anchor, hammer_end, Color("d8865c"), 5.0)
		var hammer_direction := hammer_anchor.direction_to(hammer_end)
		var hammer_side := hammer_direction.orthogonal() * 7.0
		draw_line(hammer_end - hammer_side, hammer_end + hammer_side, brass, 7.0)
		if state == "dash_windup":
			var warning_color := Color(1.0, 0.22, 0.18, 0.82)
			draw_line(Vector2(facing * 24, 19), Vector2(facing * 125, 19), warning_color, 3.0)
			for marker_distance in [42.0, 70.0, 98.0]:
				var marker_x: float = facing * float(marker_distance)
				draw_line(Vector2(marker_x - facing * 8.0, 13), Vector2(marker_x, 19), warning_color, 2.0)
				draw_line(Vector2(marker_x - facing * 8.0, 25), Vector2(marker_x, 19), warning_color, 2.0)
		elif state == "charge":
			for trail_y in [-10.0, 0.0, 10.0]:
				draw_line(Vector2(-facing * 22, trail_y), Vector2(-facing * (42.0 + absf(pulse) * 8.0), trail_y), Color(1.0, 0.32, 0.23, 0.55), 3.0)
		elif state in ["combo_first", "combo_second"]:
			var impact_strength := smoothstep(0.58, 1.0, swing_progress)
			if impact_strength > 0.0:
				draw_arc(hammer_end, 8.0 + impact_strength * 10.0, -1.4, 1.4, 12, Color(1.0, 0.72, 0.32, impact_strength * 0.8), 3.0)
		elif state == "bomb_windup":
			var bomb_at := Vector2(facing * 10, -29) + lean
			draw_circle(bomb_at, 8.0, ink)
			draw_circle(bomb_at, 5.5, Color("7f5262"))
			draw_line(bomb_at + Vector2(2, -6), bomb_at + Vector2(5, -11), brass, 2.0)
			draw_circle(bomb_at + Vector2(6, -12), 2.0 + absf(pulse), Color("fff1ac"))
		elif state == "stunned":
			for spark_side in [-1.0, 1.0]:
				var spark_at := Vector2(spark_side * 15.0, -22)
				draw_line(spark_at, spark_at + Vector2(spark_side * 5.0, -5.0 - absf(pulse) * 3.0), Color("fff1ac"), 2.0)
	else:
		var orbit := clock * 2.8
		draw_circle(Vector2.ZERO, 15.0, Color("1b293b"))
		draw_circle(Vector2.ZERO, 11.0 + pulse, Color("56416f"))
		draw_circle(Vector2.ZERO, 5.0, Color("d7a9ff"))
		for arm_index in 4:
			var direction := Vector2.from_angle(orbit + arm_index * TAU / 4.0)
			draw_line(direction * 9.0, direction * 21.0, brass, 4.0)
			draw_circle(direction * 22.0, 4.0, Color("ff8a66") if state == "aim" else steel)
		if muzzle_flash > 0.0:
			draw_circle(aim_direction * 20.0, 7.0, Color("fff1ac"))
	var bar_width := 60.0
	var tool_color := Color("ff9b75")
	draw_rect(Rect2(-bar_width * 0.5 - 1.0, -28, bar_width + 2.0, 5), Color("111c2a"))
	for health_index in max_health:
		var segment_width := bar_width / float(max_health)
		var segment_color := tool_color if health_index < health else Color("3b414b")
		draw_rect(Rect2(-bar_width * 0.5 + health_index * segment_width, -27, maxf(1.0, segment_width - 0.5), 3), segment_color)

func _draw_heavy_unit(ink: Color, steel: Color, brass: Color, eye: Color) -> void:
	var pose := Vector2.ZERO
	if state == "windup":
		pose = Vector2(-facing * (2.0 + sin(clock * 34.0)), 1.5)
	elif state == "charge":
		pose = Vector2(facing * 2.0, -1.0)
	elif state == "stunned":
		pose = Vector2(sin(clock * 25.0) * 2.0, 1.0)
	elif state == "burst":
		pose = -aim_direction * 1.5
	var body_color := Color("8f574d") if kind == "descent_guard" else Color("805f68") if kind == "tower_guard" else Color("596f8e") if kind == "shooter" else steel
	draw_rect(Rect2(Vector2(-10, -10) + pose, Vector2(20, 20)), ink)
	draw_rect(Rect2(Vector2(-8, -9) + pose, Vector2(16, 16)), body_color)
	var foot_step := sin(clock * 13.0) * 1.5 if state == "patrol" else 0.0
	draw_line(Vector2(-5, 7) + pose, Vector2(-5 + foot_step, 11) + pose, ink, 3.0)
	draw_line(Vector2(5, 7) + pose, Vector2(5 - foot_step, 11) + pose, ink, 3.0)
	draw_rect(Rect2(Vector2(-7, 5) + pose, Vector2(14, 3)), brass)
	draw_rect(Rect2(Vector2(-2 + facing * 3, -5) + pose, Vector2(3, 3)), Color("f46e5a") if state in ["windup", "aim"] else eye)
	draw_rect(Rect2(Vector2(-7, -12) + pose, Vector2(14, 3)), brass)
	if kind in ["tower_guard", "descent_guard"]:
		var blade_end := Vector2(facing * (17 if state == "charge" else 15), 5 if state != "windup" else -5) + pose
		draw_line(Vector2(facing * 8, -1) + pose, blade_end, Color("ff8a66"), 3.0)
		if state == "charge":
			for trail_y in [-6.0, 0.0, 6.0]:
				draw_line(Vector2(-facing * 10, trail_y), Vector2(-facing * (24 + absf(sin(clock * 20.0)) * 5.0), trail_y), Color(1.0, 0.54, 0.4, 0.55), 2.0)
		elif state == "stunned":
			var spark := 2.0 + absf(sin(clock * 18.0)) * 3.0
			draw_line(Vector2(-8, -15), Vector2(-8 - spark, -19), Color("fff1ac"), 2.0)
			draw_line(Vector2(8, -15), Vector2(8 + spark, -19), Color("fff1ac"), 2.0)
	elif kind == "shooter":
		var barrel_direction := aim_direction if state in ["aim", "burst"] else Vector2(facing, 0)
		draw_line(barrel_direction * 5.0 + pose, barrel_direction * 14.0 + pose, Color("d5fff2"), 4.0)
		if state == "aim":
			for segment in range(1, 16, 2):
				draw_line(aim_direction * (16.0 + segment * 6.0), aim_direction * (19.0 + segment * 6.0), Color(1.0, 0.42, 0.3, 0.72), 1.0)
		if muzzle_flash > 0.0:
			draw_circle(aim_direction * 17.0 + pose, 4.0 + muzzle_flash * 18.0, Color("fff1ac"))
	elif kinetic_mode:
		var wheel_angle := clock * (5.0 + absf(velocity_x) * 0.045)
		for wheel_x in [-6.0, 6.0]:
			draw_circle(Vector2(wheel_x, 8) + pose, 3.0, ink)
			var spoke := Vector2.from_angle(wheel_angle) * 2.5
			draw_line(Vector2(wheel_x, 8) + pose - spoke, Vector2(wheel_x, 8) + pose + spoke, Color("a9f4dd"), 1.0)
		if absf(velocity_x) > 10.0:
			draw_line(Vector2.ZERO, Vector2(clampf(velocity_x * 0.12, -28.0, 28.0), 0), Color("a9f4dd"), 2.0)
		for pip_index in KINETIC_RAM_HEALTH:
			var pip_color := Color("fff1ac") if pip_index < health else Color("3b5058")
			draw_rect(Rect2(-7 + pip_index * 8, -18, 6, 2), pip_color)
	if state == "windup":
		draw_rect(Rect2(Vector2(-12 if facing < 0 else 8, -3) + pose, Vector2(4, 6)), Color("f46e5a"))
