extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var level: Node = (load("res://scenes/kinetic_prototype.tscn") as PackedScene).instantiate()
	root.add_child(level)
	await physics_frame
	await physics_frame
	_check(level.WORLD_WIDTH >= 5300.0 and level.FINAL_GOAL_POSITION.x > 5100.0, "the level continues far beyond the original Vertical Works summit")
	_check(level.PRECISION_FOUNDRY_RECTS.size() >= 6, "the Precision Foundry has a substantial platform route")
	_check(level.CANNON_GALLERY_RECTS.size() >= 7, "the Cannon Gallery has a substantial platform route")
	_check(level.CROWN_ASCENT_RECTS.size() >= 7, "the Crown Ascent has a substantial platform route")
	_check(get_nodes_in_group("post_vertical_checkpoints").size() == 3, "each post-tower area has checkpoint coverage")
	_check(get_nodes_in_group("post_vertical_moving_platforms").size() == 3, "the post-tower route adds three moving platforms")
	_check(level.advanced_enemies.size() == 8, "the new areas contain eight aggressive enemies")
	_check(is_equal_approx(level.camera.position.y, level.CLIMB_CAMERA_OFFSET_Y), "the tower retains its upward-looking camera framing")
	level.player.reset_at(Vector2(level.POST_VERTICAL_SECTION_LEFT + 20.0, -280.0))
	level._update_camera_limits(1.0)
	_check(is_zero_approx(level.camera.position.y), "the camera recenters on the player after the Vertical Works")
	var guards := _enemies_of_kind(level, "tower_guard")
	var shooters := _enemies_of_kind(level, "shooter")
	_check(guards.size() == 4 and shooters.size() == 4, "charging guards and projectile shooters are distributed across the new areas")
	var guard_ai: Area2D = guards[0] if not guards.is_empty() else null
	if guard_ai != null:
		level.player.reset_at(guard_ai.global_position + Vector2(-70, 0))
		guard_ai.state = "patrol"
		guard_ai.cooldown = 0.0
		await physics_frame
		await physics_frame
		_check(guard_ai.state == "windup", "Tower Guards visibly commit to a telegraphed rush")
		var saw_guard_charge := false
		for _frame in 75:
			await physics_frame
			saw_guard_charge = saw_guard_charge or guard_ai.state == "charge"
			if guard_ai.state == "stunned":
				break
		_check(saw_guard_charge and guard_ai.state == "stunned", "dodging a Tower Guard rush leaves it visibly stunned")

	level.player.reset_at(level.DASH_PICKUP_POSITION)
	await physics_frame
	await physics_frame
	_check(level.dash_pickup_collected and level.player.dash_enabled, "the expanded route retains the Dash Core before the new areas")

	var shooter: Area2D = shooters[0] if not shooters.is_empty() else null
	if shooter != null:
		for other_shooter in shooters:
			if other_shooter != shooter:
				other_shooter.set_physics_process(false)
		level.player.reset_at(shooter.global_position + Vector2(-95, 0))
		shooter.state = "patrol"
		shooter.cooldown = 0.0
		for _frame in 60:
			await physics_frame
			if shooter.state == "recover":
				break
		_check(shooter.state == "recover" and get_nodes_in_group("reflectable_projectiles").size() >= 2, "Cannon Gallery shooters telegraph and fire two-round reflectable bursts")
	level._clear_projectiles()
	for enemy in level.advanced_enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)
	await _check_dash_rebounds_from_ground_enemy(level, guards[2] if guards.size() > 2 else null)
	await _check_regular_attack(level, guards[1] if guards.size() > 1 else null, "Tower Guards")
	await _check_regular_attack(level, shooters[1] if shooters.size() > 1 else null, "Shooters")

	var guard: Area2D = guards[0] if not guards.is_empty() else null
	level.player.reset_at(Vector2(3700, -470))
	await physics_frame
	if guard != null:
		guard.global_position = level.player.global_position + Vector2(80, 0)
		await physics_frame
	level._spawn_reflectable_projectile(level.player.global_position + Vector2(22, 4), Vector2(-1.0, 0.35))
	await physics_frame
	var reflected_bullet := get_first_node_in_group("reflectable_projectiles") as Area2D
	level.player.attack_direction = Vector2.RIGHT
	level.player.forward_attack_time = level.player.FORWARD_ATTACK_DURATION
	level.player._check_forward_strike()
	_check(reflected_bullet != null and is_instance_valid(reflected_bullet) and reflected_bullet.is_reflected and reflected_bullet.velocity.x > 0.0 and reflected_bullet.velocity.y < 0.0, "an attack reverses a bullet's incoming trajectory instead of using the strike angle")
	if guard != null:
		guard.global_position = level.player.global_position + reflected_bullet.velocity.normalized() * 80.0
		var guard_health_before: int = guard.health
		level.player.active = false
		for _frame in 30:
			await physics_frame
			if not is_instance_valid(reflected_bullet):
				break
		_check(guard.health < guard_health_before, "a reflected bullet damages an attacking enemy")

	level.player.reset_at(Vector2(3700, -470))
	level.player.invulnerable_time = 0.0
	level._clear_projectiles()
	level._spawn_reflectable_projectile(level.player.global_position + Vector2(20, 0), Vector2.LEFT)
	for _frame in 20:
		await physics_frame
		if level.player.health < 3:
			break
	_check(level.player.health == 2, "an unreflected enemy bullet damages the player")

	for checkpoint_position in [Vector2(2835, -279), Vector2(3580, -349), Vector2(4450, -389)]:
		level.player.reset_at(checkpoint_position)
		await physics_frame
		await physics_frame
	_check(level.late_checkpoint_order == 3 and level.late_checkpoint_position == Vector2(4450, -389), "the three new area checkpoints advance the restart point")
	level._spawn_reflectable_projectile(level.player.global_position + Vector2(40, -20), Vector2.LEFT)
	level._reset_dash_checkpoint()
	_check(level.player.global_position.distance_to(Vector2(4450, -389)) < 2.0, "post-tower failures restart at the latest major area")
	_check(get_nodes_in_group("reflectable_projectiles").is_empty() and level.advanced_enemies.size() == 8, "checkpoint resets clear bullets and restore advanced enemies")

	level.player.reset_at(level.FINAL_GOAL_POSITION + Vector2(0, 14))
	await create_timer(0.08).timeout
	_check(level.mode == "complete" and level.clockwork_core_collected, "the Clockwork Core completes the expanded route")
	level.player.active = false
	await create_timer(0.2).timeout
	level.free()
	await process_frame
	if failures.is_empty():
		print("KINETIC ENDGAME PASS: three major areas, guards, shooters, bullet reflection, checkpoints, and route handoff")
		quit(0)
	else:
		for failure in failures:
			printerr("KINETIC ENDGAME FAIL: ", failure)
		quit(1)

func _enemies_of_kind(level: Node, kind: String) -> Array[Area2D]:
	var result: Array[Area2D] = []
	for enemy in level.advanced_enemies:
		if is_instance_valid(enemy) and enemy.kind == kind:
			result.append(enemy)
	return result

func _check_regular_attack(level: Node, enemy: Area2D, label: String) -> void:
	if enemy == null:
		_check(false, "%s are available for regular-attack coverage" % label)
		return
	var original_position := enemy.global_position
	level.player.reset_at(Vector2(3700, -470))
	enemy.global_position = level.player.global_position + Vector2(20, 0)
	level._update_runtime_activation(0.0, true)
	enemy.set_physics_process(false)
	await physics_frame
	var health_before: int = enemy.health
	level.player.attack_direction = Vector2.RIGHT
	level.player.forward_attack_time = level.player.FORWARD_ATTACK_DURATION
	level.player._check_forward_strike()
	_check(enemy.health == health_before - 1, "regular horizontal attacks damage %s" % label)
	enemy.global_position = original_position
	await physics_frame

func _check_dash_rebounds_from_ground_enemy(level: Node, enemy: Area2D) -> void:
	if enemy == null:
		_check(false, "a grounded Tower Guard is available for dash-rebound coverage")
		return
	level.player.reset_at(enemy.global_position + Vector2(-75, 0))
	await physics_frame
	var enemy_x := enemy.global_position.x
	var health_before: int = level.player.health
	level.player.invulnerable_time = 0.0
	level.player.dash_ready = true
	level.player._begin_dash(enemy)
	for _frame in 30:
		await physics_frame
		if not level.player.is_dashing():
			break
	_check(level.player.global_position.x < enemy_x, "target dashing rebounds from the near side of a grounded enemy")
	_check(level.player.velocity.y <= level.player.REBOUND_SPEED + 20.0, "target dashing a grounded enemy gives a pogo-height upward rebound (velocity %s)" % level.player.velocity)
	_check(level.player.invulnerable_time > 0.2, "a grounded-enemy dash hit grants post-impact invulnerability")
	level._on_ram_touched_player(enemy.global_position)
	_check(level.player.health == health_before, "post-impact invulnerability prevents grounded enemy contact damage")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
