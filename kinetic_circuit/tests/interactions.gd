extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await process_frame
	game._start_game()
	await create_timer(0.8).timeout
	var walker: Area2D
	for child in game.level.get_children():
		if child is Area2D and child.get("kind") == "walker":
			walker = child
			break
	_check(walker != null, "walker exists")
	if walker != null:
		game.player.global_position = walker.global_position
		game.player.velocity = Vector2.ZERO
		await create_timer(0.07).timeout
		_check(game.player.health == 2, "enemy body contact costs one health")
		await create_timer(0.2).timeout
		game.player.global_position = walker.global_position + Vector2(0, -20)
		game.player.velocity = Vector2(0, 35)
		Input.action_press("aim_down")
		Input.action_press("attack")
		await create_timer(0.07).timeout
		Input.action_release("attack")
		Input.action_release("aim_down")
		_check(is_instance_valid(walker) and not walker.alive and walker.state == "dying" and walker.death_time > 0.0, "a defeated walker plays its breakup animation before removal")
		_check(game.player.velocity.y < -150.0, "enemy hit rebounds player (velocity %s)" % game.player.velocity)
		await create_timer(0.38).timeout
		_check(not is_instance_valid(walker), "the walker is removed after its death animation")
	game.player.reset_at(Vector2(600, 395))
	await create_timer(0.08).timeout
	var last_safe_platform_position: Vector2 = game.player._safe_recovery_position()
	game.player.global_position = Vector2(660, 515)
	game.player.velocity = Vector2.ZERO
	await create_timer(0.07).timeout
	_check(game.mode == "play" and game.player.health == 2 and game.player.global_position.distance_to(last_safe_platform_position) < 4.0, "pit spikes cost one health and return the player to the last safe platform")
	game.player.health = 1
	game.player.hazard_recovery_time = 0.0
	game._on_lethal_hazard()
	_check(game.mode == "dead", "hazard damage only triggers checkpoint death at zero health")
	await create_timer(0.8).timeout
	_check(game.mode == "play" and game.player.health == 3 and game.player.global_position.distance_to(game.checkpoint) < 12.0, "zero-health hazard death restores the checkpoint")
	var pogo_spike := game.get_tree().get_first_node_in_group("pogo_spikes") as Area2D
	_check(pogo_spike != null and (pogo_spike.collision_layer & game.player.POGO_SPIKE_LAYER) != 0, "floor spikes expose a downward-attack pogo surface")
	game.player.reset_at(Vector2(660, 479))
	game.player.velocity = Vector2(0, 60)
	await physics_frame
	Input.action_press("aim_down")
	Input.action_press("attack")
	await create_timer(0.07).timeout
	Input.action_release("attack")
	Input.action_release("aim_down")
	_check(game.mode == "play" and game.player.velocity.y < -180.0, "a downward strike pogos from pit spikes without killing the player (mode %s, velocity %s)" % [game.mode, game.player.velocity])
	var platform: AnimatableBody2D
	for child in game.level.get_children():
		if child is AnimatableBody2D:
			platform = child
			break
	_check(platform != null, "moving platform exists")
	if platform != null:
		game.player.reset_at(platform.global_position + Vector2(0, -14))
		await create_timer(0.1).timeout
		var player_x: float = game.player.global_position.x
		var platform_x: float = platform.global_position.x
		await create_timer(0.18).timeout
		var delta_player: float = game.player.global_position.x - player_x
		if is_instance_valid(platform):
			var delta_platform: float = platform.global_position.x - platform_x
			_check(absf(delta_player - delta_platform) < 7.0, "platform carries player (player %.1f, platform %.1f)" % [delta_player, delta_platform])
		else:
			failures.append("platform was rebuilt after player fell")
	var crusher: AnimatableBody2D
	for child in game.level.get_children():
		if child is AnimatableBody2D and child.has_signal("crushed_player"):
			crusher = child
			break
	_check(crusher != null, "crusher exists")
	if crusher != null:
		crusher.clock = 0.85
		await create_timer(0.03).timeout
		game.player.reset_at(crusher.global_position + Vector2(0, -48))
		await create_timer(0.3).timeout
		_check(game.mode == "play" and game.player.health == 3 and game.player.is_on_floor(), "player can land safely on the crusher top")
		_check(absf(game.player.global_position.y - (crusher.global_position.y - 31.0)) < 3.0, "crusher top supports the player (player %s, crusher %s)" % [game.player.global_position, crusher.global_position])
		await create_timer(0.42).timeout
		_check(game.mode == "play" and game.player.is_on_floor() and absf(game.player.global_position.y - (crusher.global_position.y - 31.0)) < 3.0, "rising crusher carries player on top")
		game.player.reset_at(crusher.global_position + Vector2(18, -2))
		await create_timer(0.08).timeout
		_check(game.mode == "play" and game.player.health == 3, "unspiked crusher side is safe")
		game.player.reset_at(Vector2(958, 396))
		crusher.clock = 0.7
		await create_timer(0.14).timeout
		_check(game.mode == "play" and game.player.health == 2, "crusher spikes cost one health and recover the player")
	paused = false
	game.free()
	if failures.is_empty():
		print("INTERACTIONS PASS: enemy damage, spike pogo and hazards, respawn, moving platform, and crusher contacts")
		quit(0)
	else:
		for failure in failures:
			printerr("INTERACTIONS FAIL: ", failure)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
