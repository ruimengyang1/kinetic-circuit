extends SceneTree

var failures: Array[String] = []
var rebound_count := 0
var device_hits := 0
var attack_hits := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for action in ["jump", "attack", "move_left", "move_right", "aim_up", "aim_down"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	var arena := Node2D.new()
	root.add_child(arena)
	var device := (load("res://scripts/rebound_device.gd") as GDScript).new() as Area2D
	device.position = Vector2(121, 100)
	device.activated.connect(func(_at: Vector2) -> void: device_hits += 1)
	arena.add_child(device)
	var player := (load("res://scripts/player.gd") as GDScript).new() as CharacterBody2D
	player.position = Vector2(100, 76)
	player.rebounded.connect(func(_at: Vector2) -> void: rebound_count += 1)
	player.attack_connected.connect(func(_at: Vector2) -> void: attack_hits += 1)
	arena.add_child(player)
	await physics_frame
	await physics_frame
	_check(player.idle_clock > 0.0, "the player's procedural idle animation advances while standing still")
	_check(player.PLAYER_LEG_COLOR.get_luminance() > 0.35, "the player's legs use a bright color that contrasts with the dark level backgrounds")
	_check(player.strike_shape.size == player.ATTACK_HITBOX_SIZE and player.forward_strike_shape.size == player.FORWARD_ATTACK_HITBOX_SIZE, "attack hitboxes include a small margin around the visible blade swing")
	Input.action_press("aim_up")
	_check(player._attack_direction_from_input() == Vector2.UP, "up input selects an upward attack")
	Input.action_release("aim_up")
	Input.action_press("move_left")
	_check(player._attack_direction_from_input() == Vector2.LEFT, "left input selects a leftward attack")
	Input.action_release("move_left")
	Input.action_press("move_right")
	_check(player._attack_direction_from_input() == Vector2.RIGHT, "right input selects a rightward attack")
	Input.action_release("move_right")
	Input.action_press("aim_down")
	_check(player._attack_direction_from_input() == Vector2.DOWN, "down input selects a downward attack")
	Input.action_press("jump")
	Input.action_press("attack")
	await create_timer(0.05).timeout
	_check(rebound_count == 1, "strike on a device directly below rebounds once")
	_check(attack_hits == 1, "downward rebound emits the shared attack-hit event")
	var speed_before_release := player.velocity.y
	Input.action_release("jump")
	await create_timer(0.035).timeout
	_check(player.velocity.y < speed_before_release + 55.0, "releasing jump just after a rebound preserves launch speed (before %.1f, after %.1f)" % [speed_before_release, player.velocity.y])
	Input.action_release("attack")
	Input.action_release("aim_down")
	await create_timer(0.04).timeout

	player.reset_at(Vector2(100, 120))
	await physics_frame
	Input.action_press("aim_up")
	Input.action_press("attack")
	await create_timer(0.05).timeout
	Input.action_release("attack")
	Input.action_release("aim_up")
	_check(device_hits == 2, "upward attack connects with a device above the player (hits %d, direction %s, attack %.2f, player %s)" % [device_hits, player.attack_direction, player.attack_time, player.global_position])
	await create_timer(0.04).timeout

	device.position = Vector2(134, 100)
	player.reset_at(Vector2(100, 100))
	await physics_frame
	Input.action_press("move_right")
	Input.action_press("attack")
	await create_timer(0.05).timeout
	Input.action_release("attack")
	Input.action_release("move_right")
	_check(device_hits == 3, "right attack connects with a device beside the player (hits %d, direction %s, attack %.2f, player %s)" % [device_hits, player.attack_direction, player.forward_attack_time, player.global_position])
	await create_timer(0.04).timeout

	device.position = Vector2(66, 100)
	player.reset_at(Vector2(100, 100))
	await physics_frame
	Input.action_press("move_left")
	Input.action_press("attack")
	await create_timer(0.05).timeout
	Input.action_release("attack")
	Input.action_release("move_left")
	_check(device_hits == 4, "left attack connects with a device beside the player (hits %d, direction %s, attack %.2f, player %s)" % [device_hits, player.attack_direction, player.forward_attack_time, player.global_position])
	await create_timer(0.08).timeout
	var recovery_before_retry: float = player.attack_cooldown
	Input.action_press("attack")
	await create_timer(0.035).timeout
	Input.action_release("attack")
	_check(player.attack_cooldown < recovery_before_retry, "attack input during recovery does not restart the cooldown (before %.3f, after %.3f)" % [recovery_before_retry, player.attack_cooldown])
	Input.action_press("move_right")
	await create_timer(0.12).timeout
	_check(player.facing == -1 and player.attack_animation_time > 0.0, "movement does not visually turn the player during attack follow-through")
	await create_timer(0.20).timeout
	_check(player.facing == 1 and player.attack_animation_time <= 0.0, "player turns toward held movement after the attack animation finishes")
	Input.action_release("move_right")
	Input.action_press("attack")
	await create_timer(0.035).timeout
	Input.action_release("attack")
	_check(player.attack_cooldown > 0.3, "attack becomes available after the short recovery (cooldown %.3f)" % player.attack_cooldown)
	await create_timer(0.40).timeout
	device.position = Vector2(165, 100)
	player.reset_at(Vector2(100, 100))
	await physics_frame
	player.velocity = Vector2(155, -80)
	Input.action_press("move_right")
	Input.action_press("attack")
	await create_timer(0.24).timeout
	Input.action_release("attack")
	Input.action_release("move_right")
	_check(device_hits == 5, "a forward-moving attack still connects late in the visible blade swing (hits %d, player %s)" % [device_hits, player.global_position])

	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(200, 210)
	var floor_collision := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(100, 20)
	floor_collision.shape = floor_shape
	floor_body.add_child(floor_collision)
	arena.add_child(floor_body)
	player.reset_at(Vector2(200, 191))
	await create_timer(0.05).timeout
	Input.action_press("jump")
	await create_timer(0.035).timeout
	var jump_speed_before_release := player.velocity.y
	_check(jump_speed_before_release < -150.0, "ordinary jump launches upward")
	Input.action_release("jump")
	await create_timer(0.035).timeout
	_check(player.velocity.y > jump_speed_before_release + 70.0, "releasing jump still shortens an ordinary jump")
	paused = false
	arena.free()
	if failures.is_empty():
		print("REBOUND PASS: all attacks emit hits, recovery prevents spam, facing stays locked through swings, rebound speed is preserved, and jumps retain variable height")
		quit(0)
	else:
		for failure in failures:
			printerr("REBOUND FAIL: ", failure)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
