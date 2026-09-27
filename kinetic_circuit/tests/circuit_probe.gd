extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/clockwork_tower.tscn") as PackedScene
	var level = scene.instantiate()
	root.add_child(level)
	await physics_frame
	level._start_game()
	level.player.set_physics_process(false)
	level.player.global_position = Vector2(570, 329)
	for index in 210:
		await physics_frame
	_check(level.receivers["pressure"].charge == 3, "natural Guard charge reaches Pressure")
	_check(level.enemies[0].health == 1, "same charge reaches teeth and weakens Guard")
	level.player.global_position = Vector2(990, 329)
	var reflected_count := 0
	for index in 360:
		await physics_frame
		for bullet in level.projectiles:
			if is_instance_valid(bullet) and not bullet.is_reflected and bullet.global_position.x > 945.0:
				bullet.receive_directional_strike(Vector2.LEFT)
				reflected_count += 1
	_check(reflected_count > 0, "Shooter fired a live reflectable shot")
	_check(level.receivers["gallery"].charge == 2, "returned shot reaches Signal")
	_check(level.receivers["core"].enabled, "two branches expose the Core inlet")
	_check(level.receivers["core"].charge >= 2, "later returned shot can reach shared Core")
	level.queue_free()
	await physics_frame
	if failures.is_empty():
		print("CIRCUIT PROBE PASS")
	else:
		for failure in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
