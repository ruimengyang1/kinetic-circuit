extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var level: Node = (load("res://scenes/kinetic_prototype.tscn") as PackedScene).instantiate()
	root.add_child(level)
	await physics_frame
	await physics_frame

	_check(level.WORLD_WIDTH >= 11500.0 and level.WORLD_TOP <= -1700.0, "the route has room for five substantial post-Crown regions")
	_check(level.DESCENT_RECTS.size() >= 10, "the Descent Foundry provides a long alternating drop")
	_check(level.GAUNTLET_RECTS.size() >= 8 and get_nodes_in_group("gauntlet_moving_platforms").size() == 6, "the Razor Transit combines many platforms with six moving obstructions")
	_check(level.DOUBLE_JUMP_RECTS.size() >= 7 and get_nodes_in_group("double_jump_platforms").size() == 3, "the Aerial Core trial has a full double-jump platform route")
	_check(level.ARENA_RECTS.size() >= 8 and get_nodes_in_group("arena_moving_platforms").size() == 3, "the Titan arena has a complex static and moving platform pattern")
	_check(level.blocks.any(func(rect: Rect2) -> bool: return rect.has_point(Vector2(9130, 60))) and not level.spike_rects.any(func(rect: Rect2) -> bool: return rect.has_point(Vector2(9130, 46))), "the arena's central pit is covered by walkable floor")
	_check(level.SUMMIT_ASCENT_RECTS.size() >= 17 and level.CLOCKWORK_CORE_POSITION.y < -1550.0, "the final ascent climbs a long distance to the Clockwork Core summit")
	_check(get_nodes_in_group("clockwork_saws").size() == 8, "animated pogoable saw traps populate the Transit, arena, and summit")
	_check(get_nodes_in_group("expansion_checkpoints").size() == 9, "four additional checkpoints divide the long Summit Ascent")
	_check(get_nodes_in_group("clockwork_core").size() == 1 and level.clockwork_core.global_position == level.CLOCKWORK_CORE_POSITION, "one Clockwork Core waits at the center of the summit platform")
	_check(is_equal_approx(level.CLOCKWORK_CORE_POSITION.x, level.SUMMIT_ASCENT_RECTS[-1].get_center().x), "the Clockwork Core is centered over the final platform")
	_check(_final_approach_is_accessible(level.SUMMIT_ASCENT_RECTS), "closely spaced final ledges make the top platform accessible")
	_check(get_nodes_in_group("descent_enemies").size() == 9, "the descent deploys a large charger squad")
	_check(get_nodes_in_group("sky_hunters").size() == 5, "five high-altitude Sky Hunters guard the Aerial Core route")
	_check(get_nodes_in_group("summit_enemies").size() == 8, "the summit ascent mixes chargers, shooters, and aerial enemies")
	var test_portals := get_nodes_in_group("boss_test_portal")
	_check(test_portals.size() == 1 and (test_portals[0] as Area2D).global_position.x < level.START_POSITION.x, "one testing warp waits immediately left of the spawn")
	level._on_test_portal_body(level.player)
	_check(level.dash_pickup_collected and level.double_jump_collected and level.player.dash_enabled and level.player.double_jump_enabled, "the testing warp grants every level powerup")
	_check(level.late_checkpoint_order == 7 and level.late_checkpoint_position == level.ARENA_CHECKPOINT_POSITION and level.player.global_position == level.ARENA_CHECKPOINT_POSITION, "the testing warp moves the player and checkpoint directly to the Titan arena")
	level.reset_encounter()
	await physics_frame
	_check(not level.dash_pickup_collected and not level.double_jump_collected and level.player.global_position == level.START_POSITION, "a full reset restores the normal level start after using the testing warp")
	await _check_sky_hunter_movement_and_dash(level)
	await _check_summit_system_interactions(level)

	var saw := get_nodes_in_group("clockwork_saws")[0] as Area2D
	level.player.reset_at(saw.global_position + Vector2(0, -45))
	await physics_frame
	var saw_start := saw.position
	await create_timer(0.12).timeout
	_check(saw.is_physics_processing() and saw.position.distance_to(saw_start) > 1.0, "nearby clockwork saw traps wake and animate along their obstruction paths")

	var charger := get_nodes_in_group("descent_enemies")[0] as Area2D
	level.player.reset_at(charger.global_position + Vector2(-70, 0))
	charger.state = "patrol"
	charger.cooldown = 0.0
	charger._physics_process(0.016)
	_check(charger.state == "windup" and charger.state_time <= 0.25, "descent guards quickly prepare a charge as the player drops past")

	level.player.reset_at(level.DOUBLE_JUMP_PICKUP_POSITION + Vector2(0, 10))
	level._on_double_jump_pickup_body(level.player)
	_check(level.double_jump_collected and level.player.double_jump_enabled and level.player.double_jump_available, "the Aerial Core grants a ready double jump")
	_check(not level.double_jump_pickup.visible and "DOUBLE JUMP" in level.result_label.text, "the powerup has pickup art and concise feedback")
	level.player.global_position = Vector2(7700, -90)
	level.player.velocity = Vector2(0, 40)
	level.player.move_and_slide()
	level.player.coyote_time = 0.0
	level.player.double_jump_available = true
	Input.action_release("jump")
	await physics_frame
	Input.action_press("jump")
	await create_timer(0.05).timeout
	Input.action_release("jump")
	_check(level.player.velocity.y < -130.0 and not level.player.double_jump_available, "the airborne second jump launches the player and consumes its charge (velocity %s, available %s, coyote %.3f, buffer %.3f)" % [level.player.velocity, level.player.double_jump_available, level.player.coyote_time, level.player.jump_buffer_time])

	level.player.active = false
	var bosses: Array = get_nodes_in_group("arena_bosses")
	_check(bosses.size() == 1 and bosses[0].kind == "boss_titan" and level.arena_gate.collision_layer == 1, "only the grounded Titan locks the summit gate")
	var boss: Area2D = bosses[0] if not bosses.is_empty() else null
	if boss != null:
		boss.set_physics_process(false)
		var boss_shape := boss.get_child(0) as CollisionShape2D
		_check(boss_shape.shape.size == Vector2(50, 38), "the Titan's enlarged hitbox matches its body, wheels, and hammer stance")
		_check(boss.health == 15 and boss.max_health == 15, "the Titan starts with fifteen universal health points")
		_check(not boss.is_in_group("dash_targets"), "the Titan is not selectable as a target-dash destination")
		await _check_titan_saw_interaction(boss)
		level.player.global_position = boss.global_position + Vector2(80, 0)

		boss.state = "patrol"
		boss.pattern_step = 0
		boss.cooldown = 0.0
		boss._physics_process(0.016)
		_check(boss.state == "dash_windup" and boss.state_time > 0.5, "the Titan's dash has a long dedicated telegraph")

		boss.state = "patrol"
		boss.pattern_step = 1
		boss.cooldown = 0.0
		boss._physics_process(0.016)
		_check(boss.state == "combo_windup", "the Titan charges its medium-range hammer combo")
		boss._physics_process(boss.TITAN_COMBO_WINDUP + 0.01)
		var saw_first_swing: bool = boss.state == "combo_first"
		boss._physics_process(0.19)
		boss._physics_process(0.17)
		_check(saw_first_swing and boss.state == "combo_second", "the charged hammer combo performs two distinct melee swings")

		boss.state = "patrol"
		boss.pattern_step = 2
		boss.cooldown = 0.0
		boss._physics_process(0.016)
		_check(boss.state == "bomb_windup", "the Titan visibly prepares its bomb throw")
		boss._physics_process(boss.TITAN_BOMB_WINDUP + 0.01)
		var bombs := get_nodes_in_group("boss_bombs")
		_check(bombs.size() == 1, "the Titan throws a live arcing bomb")
		if not bombs.is_empty():
			var bomb := bombs[0] as Area2D
			_check(bomb.receive_directional_strike(Vector2.RIGHT) and bomb.is_reflected and bomb.velocity.x > 0.0, "the thrown bomb can be struck back at the Titan")
		level._clear_projectiles()

		var contact_trace := {"hits": 0}
		boss.touched_player.connect(func(_source: Vector2) -> void: contact_trace["hits"] = int(contact_trace["hits"]) + 1)
		level.player.global_position = boss.global_position
		boss._on_body_entered(level.player)
		_check(int(contact_trace["hits"]) == 0, "passive contact with the Titan's enlarged body is harmless")

		var health_before_dash: int = boss.health
		_check(not boss.receive_dash() and boss.health == health_before_dash, "dashing into the Titan is disabled and cannot deal damage")
		_check(boss.receive_directional_strike(Vector2.RIGHT) and boss.health == 14, "a horizontal strike damages the Titan without an armor requirement")
		_check(boss.receive_directional_strike(Vector2.DOWN) and boss.health == 13, "a pogo strike uses the same universal Titan health")
		_check(boss.receive_strike() and boss.health == 12, "a standard strike damages the Titan")
		_check(boss.receive_projectile_strike() and boss.health == 11, "a reflected bomb damages the Titan without a special phase")
		for _hit in 11:
			boss.receive_strike()
		_check(not boss.alive and boss.state == "dying", "fifteen ordinary valid hits defeat the Titan")
	_check(level.arena_cleared and level.arena_gate.collision_layer == 0, "defeating the Titan opens the summit gate")

	level.dash_pickup_collected = true
	for checkpoint_order in range(9, 13):
		var checkpoint_area: Area2D = get_nodes_in_group("expansion_checkpoints").filter(func(area: Area2D) -> bool: return int(area.get_meta("checkpoint_order")) == checkpoint_order)[0]
		level._on_late_checkpoint_body(level.player, checkpoint_order, checkpoint_area.get_meta("respawn_position"))
	_check(level.late_checkpoint_order == 12 and level.late_checkpoint_position == Vector2(10985, -1503), "the Summit Ascent checkpoints advance recovery to the final approach")
	level._reset_dash_checkpoint()
	_check(level.player.global_position == Vector2(10985, -1503), "failure on the final approach restarts at the latest Summit Ascent checkpoint")

	level.player.reset_at(level.FINAL_GOAL_POSITION + Vector2(0, 14))
	await create_timer(0.1).timeout
	_check(level.mode == "complete" and level.clockwork_core_collected and not level.clockwork_core.visible, "picking up the Clockwork Core wins the game and removes the collected item")
	_check("CLOCKWORK CORE RESTORED" in level.result_label.text and "ASCENT COMPLETE" in level.result_label.text, "the Clockwork Core victory reports the completed run")
	var summit_has_enemy := false
	for enemy in level.expansion_enemies:
		if is_instance_valid(enemy) and enemy.alive and enemy.global_position.distance_to(level.FINAL_GOAL_POSITION) < 260.0:
			summit_has_enemy = true
	_check(not summit_has_enemy, "the Clockwork Core platform remains clear of enemies")
	level.reset_encounter()
	await process_frame
	_check(not level.clockwork_core_collected and level.clockwork_core.visible, "a full replay reset restores the Clockwork Core")

	level.free()
	await process_frame
	if failures.is_empty():
		print("KINETIC EXPANSION PASS: five areas, systemic hazard callbacks, Titan arena, ascent checkpoints, and Clockwork Core finale")
		quit(0)
	else:
		for failure in failures:
			printerr("KINETIC EXPANSION FAIL: ", failure)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _final_approach_is_accessible(platforms: Array) -> bool:
	var approach: Array = platforms.slice(platforms.size() - 5)
	for index in approach.size() - 1:
		var current: Rect2 = approach[index]
		var next: Rect2 = approach[index + 1]
		var horizontal_gap := maxf(0.0, maxf(next.position.x - current.end.x, current.position.x - next.end.x))
		if absf(next.position.y - current.position.y) > 50.0 or horizontal_gap > 20.0:
			return false
	return true

func _check_sky_hunter_movement_and_dash(level: Node) -> void:
	var hunter := get_nodes_in_group("sky_hunters")[0] as Area2D
	hunter.set_physics_process(false)
	level.player.reset_at(hunter.global_position + Vector2(-75, 0))
	await physics_frame
	level.player.invulnerable_time = 0.0
	level.player.dash_enabled = true
	level.player.dash_ready = true
	var health_before: int = level.player.health
	level.player._begin_dash(hunter)
	for _frame in 30:
		await physics_frame
		if not level.player.is_dashing():
			break
	_check(level.player.velocity.y <= level.player.REBOUND_SPEED + 20.0, "dashing a Sky Hunter gives a pogo-height upward rebound")
	_check(level.player.invulnerable_time > 0.2 and level.player.health == health_before, "a Sky Hunter dash hit safely protects its rebound")

	level.player.global_position = Vector2.ZERO
	hunter.position = hunter.home + Vector2(95, 40)
	hunter.state = "recover"
	hunter.state_time = 0.01
	var largest_step := 0.0
	for _frame in 90:
		var previous_position := hunter.position
		hunter._physics_process(0.016)
		largest_step = maxf(largest_step, hunter.position.distance_to(previous_position))
	_check(hunter.state == "patrol" and largest_step < 3.0, "Sky Hunters return to patrol continuously without teleporting (largest step %.2f)" % largest_step)
	hunter.set_physics_process(true)

func _check_summit_system_interactions(level: Node) -> void:
	var summit_guard := _summit_enemy_near(Vector2(9882, -422), "descent_guard")
	if summit_guard == null:
		_check(false, "a Summit Guard is available beside the first bait spike")
		return
	var guard_processing := summit_guard.is_physics_processing()
	summit_guard.set_physics_process(false)
	summit_guard.global_position = Vector2(9930, -422)
	summit_guard.state = "charge"
	summit_guard.state_time = 0.5
	var guard_health_before: int = summit_guard.health
	await physics_frame
	await physics_frame
	summit_guard._physics_process(0.016)
	_check(summit_guard.health == guard_health_before - 1 and summit_guard.state == "stunned", "baiting a committed Summit Guard charge through its spike strip damages and stuns it")
	summit_guard.health = summit_guard.max_health
	summit_guard.global_position = summit_guard.home
	summit_guard.state = "patrol"
	summit_guard.set_physics_process(guard_processing)

	var hunter := _summit_enemy_near(Vector2(9860, -540), "sky_hunter")
	var shooter := _summit_enemy_near(Vector2(10050, -602), "shooter")
	if hunter == null or shooter == null:
		_check(false, "the Summit reflection lane retains its Shooter and Sky Hunter")
		return
	var hunter_processing := hunter.is_physics_processing()
	hunter.set_physics_process(false)
	hunter.global_position = hunter.home
	var hunter_health_before: int = hunter.health
	var reflection_point := Vector2(9780, -509)
	level._spawn_reflectable_projectile(reflection_point, shooter.global_position.direction_to(reflection_point))
	var reflected_bullet := get_nodes_in_group("reflectable_projectiles").back() as Area2D
	reflected_bullet.receive_directional_strike(Vector2.RIGHT)
	for _frame in 45:
		await physics_frame
		if hunter.health < hunter_health_before:
			break
	_check(hunter.health == hunter_health_before - 1, "the aligned Summit Shooter lane lets a reflected bullet hit the existing Sky Hunter")
	level._clear_projectiles()
	hunter.health = hunter.max_health
	hunter.global_position = hunter.home
	hunter.state = "patrol"
	hunter.set_physics_process(hunter_processing)

func _check_titan_saw_interaction(boss: Area2D) -> void:
	var arena_saw: Area2D
	for candidate in get_nodes_in_group("clockwork_saws"):
		if is_equal_approx((candidate as Area2D).home.x, 9000.0):
			arena_saw = candidate as Area2D
			break
	if arena_saw == null:
		_check(false, "the Titan arena retains its travelling saw")
		return
	var saw_processing := arena_saw.is_physics_processing()
	var saw_position := arena_saw.global_position
	arena_saw.set_physics_process(false)
	arena_saw.global_position = arena_saw.home + arena_saw.travel
	boss.global_position = Vector2(arena_saw.global_position.x - 10.0, boss.home.y)
	boss.facing = 1
	boss.state = "charge"
	boss.state_time = 0.5
	var health_before: int = boss.health
	await physics_frame
	await physics_frame
	boss._physics_process(0.016)
	_check(boss.health == health_before - 1 and boss.state == "stunned", "baiting the Titan's committed rush into an arena saw damages and stuns it")
	boss.health = boss.max_health
	boss.global_position = boss.home
	boss.state = "patrol"
	boss.state_time = 0.0
	arena_saw.global_position = saw_position
	arena_saw.set_physics_process(saw_processing)

func _summit_enemy_near(point: Vector2, kind: String) -> Area2D:
	for enemy in get_nodes_in_group("summit_enemies"):
		if enemy.kind == kind and enemy.home.distance_to(point) < 2.0:
			return enemy as Area2D
	return null
