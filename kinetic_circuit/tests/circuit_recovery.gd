extends SceneTree

var failures: Array[String] = []
var level: Node2D

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	level = (load("res://scenes/clockwork_tower.tscn") as PackedScene).instantiate()
	root.add_child(level)
	await physics_frame
	level._start_game()
	for enemy in level.enemies:
		enemy.receive_directional_strike(Vector2.DOWN)
		enemy.receive_directional_strike(Vector2.DOWN)
	await _manual_charge("pressure", 450.0, 3)
	await _manual_charge("gallery", 800.0, 2)
	_check(level.receivers["pressure"].charge == 3 and level.receivers["gallery"].charge == 2, "manual impacts power both branches after both sources are lost")
	await create_timer(0.65).timeout
	level._record_checkpoint(Vector2(650, 329))
	level.player.kill()
	await create_timer(0.55).timeout
	_check(level.player.health == 3 and level.receivers["core"].enabled, "checkpoint restores a solvable two-branch circuit")
	_check(not level.retry_hint.visible, "restart hint clears after automatic recovery")
	var living_sources := 0
	for enemy in level.enemies:
		if is_instance_valid(enemy) and enemy.alive:
			living_sources += 1
	_check(living_sources == 0, "checkpoint preserves removal of both sources")
	await _manual_charge("core", 650.0, 3)
	_check(level.receivers["core"].charge == 3, "manual service input still powers Core")
	level.player.kill()
	await create_timer(0.55).timeout
	_check(level.receivers["core"].charge == 0 and level.get_node("CorePowerWheel").collision_layer == 32, "death before exit restores the unsynchronized Core and saw")
	level.queue_free()
	await physics_frame
	if failures.is_empty():
		print("CIRCUIT RECOVERY PASS")
	else:
		for failure in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _manual_charge(key: String, x: float, needed: int) -> void:
	level.player.reset_at(Vector2(x, 329))
	for hit in needed:
		await _hold(["jump"], 8)
		await _hold(["aim_down", "attack"], 8)
		await _hold([], 62)
		if key == "core" and hit < needed - 1:
			await _walk_to(500.0)
			await _hold([], 35)
			await _walk_to(650.0)
			await _hold([], 10)

func _walk_to(target: float) -> void:
	var action := "move_right" if target > level.player.global_position.x else "move_left"
	Input.action_press(action)
	for frame in 200:
		await physics_frame
		if (action == "move_right" and level.player.global_position.x >= target - 9.0) or (action == "move_left" and level.player.global_position.x <= target + 9.0):
			break
	Input.action_release(action)
	for frame in 10:
		await physics_frame

func _hold(actions: Array[String], frames: int) -> void:
	for action in ["jump", "attack", "aim_down", "move_left", "move_right"]:
		if action in actions:
			Input.action_press(action)
		else:
			Input.action_release(action)
	for frame in frames:
		await physics_frame

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
