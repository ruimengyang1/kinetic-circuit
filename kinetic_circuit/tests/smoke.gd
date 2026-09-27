extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/game.tscn") as PackedScene
	var game := scene.instantiate()
	root.add_child(game)
	await process_frame
	game.unlocked_level = 1
	game.selected_level = 1
	game._open_level_select("CLOCKWORK ASCENT")
	_check(game.mode == "level_select", "level select opens")
	_check(InputMap.has_action("attack") and InputMap.has_action("jump") and InputMap.has_action("aim_up") and InputMap.has_action("slow_motion"), "controls registered")
	Input.action_press("move_right")
	await process_frame
	Input.action_release("move_right")
	_check(game.selected_level == 1, "locked level cannot be selected")
	Input.action_press("ui_accept")
	await create_timer(0.06).timeout
	Input.action_release("ui_accept")
	_check(game.mode == "play" and game.stage_number == 1, "selected first level starts")
	_check(game.player.health == 3, "player starts with three health")
	await create_timer(0.06).timeout
	_check(game.elapsed > 0.0 and "TIME 00:00." in game.hud_label.text, "the HUD tracks the current run time to tenths of a second")
	_check(game.slow_bar.size == Vector2(53, 5), "the original-level slow-motion bar uses the compact HUD size (size %s, minimum %s)" % [game.slow_bar.size, game.slow_bar.get_combined_minimum_size()])
	Input.action_press("slow_motion")
	await process_frame
	await process_frame
	Input.action_release("slow_motion")
	await process_frame
	_check(game.slow_motion_active and game.slow_motion_energy < game.SLOW_MOTION_CAPACITY, "Q toggles the rechargeable slow-motion meter in the original levels")
	Input.action_press("slow_motion")
	await process_frame
	await process_frame
	Input.action_release("slow_motion")
	await process_frame
	_check(not game.slow_motion_active and is_equal_approx(Engine.time_scale, 1.0), "a second Q press leaves the original levels at normal speed")
	Input.action_press("jump")
	await create_timer(0.07).timeout
	_check(game.player.velocity.y < 0.0, "jump launches upward (velocity %s, y %s, floor %s, coyote %s, buffer %s)" % [game.player.velocity.y, game.player.global_position.y, game.player.is_on_floor(), game.player.coyote_time, game.player.jump_buffer_time])
	Input.action_release("jump")
	game.player.global_position = Vector2(210, 425)
	game.player.velocity = Vector2(0, 40)
	Input.action_press("aim_down")
	Input.action_press("attack")
	await physics_frame
	await physics_frame
	_check(game.player.velocity.y < -180.0, "device strike rebounds player")
	Input.action_release("attack")
	Input.action_release("aim_down")
	game.player.global_position = Vector2(735, 395)
	game.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	_check(game.checkpoint_index == 1, "checkpoint activates")
	var death_origin: Vector2 = game.player.global_position
	game.player.kill(Vector2(death_origin.x - 10.0, death_origin.y))
	await create_timer(0.24).timeout
	_check(game.mode == "dead" and game.player.death_animation_time > 0.0 and game.player.global_position.distance_to(death_origin) > 20.0, "death launches and animates the player before revival")
	_check(game.death_label.visible and "SYSTEM FAILURE" in game.death_label.text and game.camera.zoom.x > 1.2, "death displays a dramatic message and camera zoom")
	await create_timer(0.56).timeout
	_check(game.mode == "play", "death returns to play")
	_check(game.player.global_position.distance_to(Vector2(735, 395)) < 12.0, "respawn uses checkpoint")
	_check(game.player.active and game.player.collision_layer == 2 and is_equal_approx(game.camera.zoom.x, 1.0) and not game.death_label.visible, "revival resets player collision and the full death presentation")
	game.player.global_position = Vector2(1460, 320)
	game.player.velocity = Vector2.ZERO
	await create_timer(0.06).timeout
	_check(game.checkpoint_index == 2, "upper checkpoint activates")
	game.player.kill()
	await create_timer(0.8).timeout
	_check(game.mode == "play" and game.player.global_position.distance_to(Vector2(1460, 320)) < 12.0, "upper checkpoint respawn is safe")
	game.player.global_position = Vector2(1904, 251)
	game.player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	await physics_frame
	_check(game.mode == "level_select" and game.unlocked_level == 2 and game.selected_level == 2, "first bell unlocks and selects level two")
	_check("LEVEL 1 COMPLETE  00:" in game.overlay_title.text, "the original level completion screen reports the run time")
	_check(game.completed_levels & 1 and "LEVEL 1   FOUNDRY  [CLEARED]" in game.overlay_body.text, "completed level is marked as cleared")
	var progress := ConfigFile.new()
	_check(progress.load(game.PROGRESS_PATH) == OK and int(progress.get_value("progress", "unlocked_level", 1)) == 2, "level unlock is saved")
	Input.action_press("ui_accept")
	await create_timer(0.08).timeout
	Input.action_release("ui_accept")
	_check(game.mode == "play" and game.stage_number == 2 and game.player.dash_enabled, "level two starts with dash unlocked")
	game.player.global_position = game.level.goal_marker + Vector2(0, 12)
	game.player.velocity = Vector2.ZERO
	await create_timer(0.1).timeout
	_check(game.mode == "level_select" and game.selected_level == 2 and game.completed_levels & 2, "second bell returns to level select and marks level two cleared")
	Input.action_release("move_left")
	await process_frame
	Input.action_press("move_left")
	await create_timer(0.06).timeout
	Input.action_release("move_left")
	_check(game.selected_level == 1, "completed first level can be selected again")
	await process_frame
	Input.action_press("ui_accept")
	await create_timer(0.08).timeout
	Input.action_release("ui_accept")
	_check(game.mode == "play" and game.stage_number == 1 and not game.player.dash_enabled, "level select replays level one")
	_check(game.player.global_position.distance_to(Vector2(48, 470)) < 12.0, "replayed level begins at the entrance")
	await create_timer(0.5).timeout
	paused = false
	game.free()
	if failures.is_empty():
		print("SMOKE PASS: level select, unlock save, both stages, and replay")
		quit(0)
	else:
		for failure in failures:
			printerr("SMOKE FAIL: ", failure)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
