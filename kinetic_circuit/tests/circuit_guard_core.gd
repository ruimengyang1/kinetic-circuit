extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var level = (load("res://scenes/clockwork_tower.tscn") as PackedScene).instantiate()
	root.add_child(level)
	await physics_frame
	level._start_game()
	level.player.set_physics_process(false)
	level.player.global_position = Vector2(570, 329)
	for frame in 210:
		await physics_frame
	_check(level.receivers["pressure"].charge == 3, "normal Guard charge powers Pressure")
	_check(level.enemies[0].health == 1, "teeth stun and weaken the Guard without removing it")
	level.receivers["gallery"].receive_directional_strike(Vector2.DOWN)
	level.receivers["gallery"].receive_directional_strike(Vector2.DOWN)
	_check(level.receivers["core"].enabled, "the two conductors expose Core")
	level.player.global_position = Vector2(700, 329)
	for frame in 240:
		await physics_frame
		if level.receivers["core"].charge >= 3:
			break
	_check(level.receivers["core"].charge == 3, "later natural Guard charge reaches shared Core")
	level.queue_free()
	await physics_frame
	if failures.is_empty():
		print("CIRCUIT GUARD CORE PASS")
	else:
		for failure in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
