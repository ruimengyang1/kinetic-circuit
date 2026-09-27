extends SceneTree

var failures: Array[String] = []
var dash_hits := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var level = (load("res://scenes/kinetic_prototype.tscn") as PackedScene).instantiate()
	root.add_child(level)
	await physics_frame
	await physics_frame
	level.player.dash_connected.connect(func(_at: Vector2) -> void: dash_hits += 1)
	_check(not level.player.dash_enabled, "target dash begins locked")
	_check(level.camera.limit_top == 0, "the camera stays vertically locked throughout the horizontal section")
	_check(level.camera.limit_smoothed and level.camera.position_smoothing_enabled, "camera limit changes ease into the vertical section")
	_check(level.dash_relays.size() == 4, "the final spike rail has four relay targets")
	_check(get_nodes_in_group("vertical_dual_targets").size() == 4, "the Vertical Works contains four dual-purpose enemies")
	var vertical_kinds: Array = get_nodes_in_group("vertical_dual_targets").map(func(enemy: Area2D): return enemy.kind)
	_check("spring_drone" in vertical_kinds and "gearwing" in vertical_kinds, "Spring Drones and Gearwings both populate the vertical climb")
	var shielded_relay: Area2D = level.dash_relays[0]
	_check(not shielded_relay.receive_strike() and shielded_relay.alive, "downward strikes cannot break shielded dash relays")

	level.player.reset_at(level.DASH_PICKUP_POSITION)
	await physics_frame
	await physics_frame
	_check(level.dash_pickup_collected, "touching the Dash Core collects it")
	_check(level.player.dash_enabled and level.player.dash_ready, "the Dash Core enables a ready target dash")

	level.carriage.position = Vector2(820, level.CARRIAGE_START.y)
	level.carriage.velocity_x = 70.0
	level.player.kill()
	await create_timer(0.78).timeout
	_check(level.mode == "play", "death after the pickup returns to play")
	_check(level.player.global_position.distance_to(level.DASH_CHECKPOINT_POSITION) < 12.0, "the Dash Core creates a nearby checkpoint")
	_check(level.player.dash_enabled and level.player.dash_ready and level.dash_relays.size() == 4, "checkpoint recovery restores the dash and relay chain")
	_check(level.carriage.position.distance_to(level.CARRIAGE_START) < 1.0 and is_zero_approx(level.carriage.velocity_x), "Dash Core checkpoint deaths also reset the carriage (position %s, spawn %s, velocity %.2f, ram %s/%s/%.1f)" % [level.carriage.position, level.carriage.spawn_position, level.carriage.velocity_x, level.ram.position, level.ram.state, level.ram.velocity_x])
	level.player.reset_at(Vector2(1410, 165))
	await physics_frame
	level.player.dash_ready = false
	Input.action_press("aim_down")
	Input.action_press("attack")
	await create_timer(0.07).timeout
	Input.action_release("attack")
	Input.action_release("aim_down")
	_check(level.mode == "play" and level.player.velocity.y < -180.0 and level.player.dash_ready, "pogoing from spikes refreshes a spent Dash Core charge")
	await _check_vertical_enemy_interactions(level)

	level.player.reset_at(Vector2(1365, 173))
	level.player.velocity = Vector2(120, -30)
	var relay_hits_before := dash_hits
	for expected_x in [1455, 1585, 1715, 1845]:
		await _dash_to(level, expected_x)
	Input.action_press("move_left")
	await create_timer(0.7).timeout
	Input.action_release("move_left")
	_check(dash_hits == relay_hits_before + 4, "all four shielded enemies must be dashed through")
	_check(level.mode == "play" and level.player.global_position.x > level.VERTICAL_SECTION_LEFT and level.player.is_on_floor(), "the complete chain lands at the vertical works")
	_check(level.tower_checkpoint_reached, "landing after the dash chain activates the tower checkpoint")
	_check(level.FINAL_GOAL_POSITION.y < -280.0 and level.camera.limit_top <= -400, "the required route continues more than four hundred pixels upward")
	level.player.reset_at(Vector2(level.VERTICAL_SECTION_LEFT - 25.0, 100))
	await physics_frame
	await physics_frame
	_check(level.camera.limit_top == 0, "leaving the vertical works restores the horizontal camera lock")
	level.player.reset_at(level.TOWER_CHECKPOINT_POSITION)
	await physics_frame
	await physics_frame
	_check(level.camera.limit_top <= -400, "re-entering the vertical works restores upward camera movement")
	_check(level.CLIMB_PLATFORM_RECTS.size() == 9 and get_nodes_in_group("kinetic_climb_platforms").size() == 2, "the vertical works adds nine ledges and two moving platforms")

	level.player.kill()
	await create_timer(0.78).timeout
	_check(level.mode == "play" and level.player.global_position.distance_to(level.TOWER_CHECKPOINT_POSITION) < 12.0, "tower deaths restart at the base of the climb")

	await _check_jump(level, Vector2(2080, 136), level.CLIMB_PLATFORM_RECTS[0], 2150.0, "base to first ledge")
	await _check_jump(level, Vector2(2168, 96), level.CLIMB_PLATFORM_RECTS[1], 2238.0, "first rightward rise")
	await _check_jump(level, Vector2(2238, 58), level.CLIMB_PLATFORM_RECTS[2], 2155.0, "first zigzag reversal")
	await _check_jump(level, Vector2(2395, -57), level.CLIMB_PLATFORM_RECTS[4], 2455.0, "upper rightward rise")
	await _check_jump(level, Vector2(2455, -95), level.CLIMB_PLATFORM_RECTS[5], 2385.0, "upper zigzag reversal")
	await _check_jump(level, Vector2(2385, -133), level.CLIMB_PLATFORM_RECTS[6], 2455.0, "upper return jump")
	await _check_jump(level, Vector2(2670, -247), level.CLIMB_PLATFORM_RECTS[8], 2760.0, "final spike-clearing jump to the bell deck")

	level.player.reset_at(level.FINAL_GOAL_POSITION + Vector2(0, 14))
	await create_timer(0.08).timeout
	_check(level.mode == "complete" and level.clockwork_core_collected, "the expanded route ends by collecting the Clockwork Core")
	_check("CLOCKWORK CORE RESTORED  00:" in level.result_label.text, "the Clockwork Core victory reports the completed run time")

	level.mode = "complete"
	level.player.active = false
	await create_timer(0.55).timeout
	level.free()
	await process_frame
	if failures.is_empty():
		print("KINETIC DASH PASS: pickup, relay chain, dual-purpose tower enemies, vertical jumps, moving platforms, and summit")
		quit(0)
	else:
		for failure in failures:
			printerr("KINETIC DASH FAIL: ", failure)
		quit(1)

func _dash_to(level: Node, expected_x: int) -> void:
	var expected_target: Area2D
	for relay in level.dash_relays:
		if is_instance_valid(relay) and absf(relay.global_position.x - expected_x) < 1.0:
			expected_target = relay
			break
	_check(expected_target != null, "relay at x=%d exists" % expected_x)
	if expected_target == null:
		return
	var target_direction: Vector2 = level.player.global_position.direction_to(expected_target.global_position)
	var input_direction := Vector2(signf(target_direction.x), signf(target_direction.y) if absf(target_direction.y) > 0.15 else 0.0).normalized()
	_press_direction(input_direction)
	var acquired := level.player._nearest_dash_target(input_direction) as Area2D
	_check(acquired == expected_target, "directional aim acquires relay at x=%d" % expected_x)
	var hits_before := dash_hits
	Input.action_press("dash")
	for _frame in 32:
		await physics_frame
		if dash_hits > hits_before:
			break
	Input.action_release("dash")
	_release_direction()
	await physics_frame
	_check(dash_hits == hits_before + 1, "dash connects with relay at x=%d" % expected_x)
	_check(level.player.dash_ready, "relay at x=%d refreshes the dash" % expected_x)
	_check(level.mode == "play", "relay at x=%d is crossed without touching the spikes" % expected_x)

func _check_vertical_enemy_interactions(level: Node) -> void:
	for kind in ["spring_drone", "gearwing"]:
		var dash_target := _vertical_target(level, kind, kind == "gearwing")
		_check(dash_target != null, "%s exists for the dash check" % kind)
		if dash_target == null:
			continue
		level.player.reset_at(dash_target.global_position + Vector2(-75, 0))
		await physics_frame
		level.player.dash_ready = true
		var hits_before := dash_hits
		Input.action_press("move_right")
		Input.action_press("dash")
		for _frame in 32:
			await physics_frame
			if dash_hits > hits_before:
				break
		Input.action_release("dash")
		Input.action_release("move_right")
		_check(dash_hits == hits_before + 1 and level.player.dash_ready, "%s can be targeted and defeated by a dash" % kind)
		level._recreate_vertical_enemies()
		await physics_frame
		var pogo_target := _vertical_target(level, kind, kind == "gearwing")
		_check(pogo_target != null, "%s respawns for the pogo check" % kind)
		if pogo_target == null:
			continue
		level.player.reset_at(pogo_target.global_position + Vector2(0, -27))
		await physics_frame
		level.player.dash_ready = false
		Input.action_press("aim_down")
		Input.action_press("attack")
		await create_timer(0.08).timeout
		Input.action_release("attack")
		Input.action_release("aim_down")
		_check(level.player.velocity.y < -180.0 and level.player.dash_ready, "%s can be defeated with a downward pogo that refreshes dash" % kind)
		_check(is_instance_valid(pogo_target) and not pogo_target.alive and pogo_target.state == "dying", "%s plays a death animation after the pogo" % kind)
		await create_timer(0.34).timeout
		_check(not is_instance_valid(pogo_target), "%s is removed after its death animation" % kind)
		level._recreate_vertical_enemies()
		await physics_frame
	_check(get_nodes_in_group("vertical_dual_targets").size() == 4, "all Vertical Works enemies respawn after the interaction checks")

func _vertical_target(level: Node, kind: String, choose_rightmost: bool) -> Area2D:
	var result: Area2D
	for enemy in level.vertical_enemies:
		if not is_instance_valid(enemy) or enemy.kind != kind:
			continue
		if result == null or (enemy.global_position.x > result.global_position.x if choose_rightmost else enemy.global_position.x < result.global_position.x):
			result = enemy
	return result

func _press_direction(direction: Vector2) -> void:
	if direction.x > 0.0:
		Input.action_press("move_right")
	elif direction.x < 0.0:
		Input.action_press("move_left")
	if direction.y > 0.0:
		Input.action_press("aim_down")
	elif direction.y < 0.0:
		Input.action_press("aim_up")

func _release_direction() -> void:
	for action in ["move_left", "move_right", "aim_up", "aim_down"]:
		Input.action_release(action)

func _check_jump(level: Node, from: Vector2, target_rect: Rect2, landing_x: float, label: String) -> void:
	level.player.reset_at(from)
	level.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	var direction := signf(landing_x - from.x)
	Input.action_press("move_right" if direction > 0.0 else "move_left")
	Input.action_press("jump")
	for frame in 120:
		if frame == 16:
			Input.action_release("jump")
		var dx: float = landing_x - level.player.global_position.x
		if absf(dx) < 4.0:
			Input.action_release("move_left")
			Input.action_release("move_right")
		elif dx > 0.0:
			Input.action_press("move_right")
			Input.action_release("move_left")
		else:
			Input.action_press("move_left")
			Input.action_release("move_right")
		await physics_frame
		var feet: Vector2 = level.player.global_position + Vector2(0, 9)
		if level.player.is_on_floor() and target_rect.grow(2.0).has_point(feet):
			_release_direction()
			Input.action_release("jump")
			_check(true, label)
			return
	_release_direction()
	Input.action_release("jump")
	_check(false, "%s (ended at %s, mode %s, health %d)" % [label, level.player.global_position, level.mode, level.player.health])

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
