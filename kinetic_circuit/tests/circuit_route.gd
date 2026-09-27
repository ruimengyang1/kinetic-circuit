extends SceneTree

var level: Node2D
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	level = (load("res://scenes/clockwork_tower.tscn") as PackedScene).instantiate()
	root.add_child(level)
	await physics_frame
	level._start_game()
	await _hold(["jump"], 8)
	await _hold(["aim_down", "attack"], 9)
	_check(level.receivers["intake"].charge == 1, "input impact powers Intake")
	await _hold(["move_right"], 39)
	await _hold(["move_right", "jump"], 18)
	await _hold([], 26)
	await _hold(["move_left", "jump"], 18)
	await _hold([], 26)
	await _hold(["move_left", "jump"], 17)
	await _hold([], 28)
	await _hold(["jump"], 17)
	await _hold([], 35)
	_check(level.player.global_position.y < 341.0, "input-only climb reaches shared branch level")
	await _hold(["move_left"], 45)
	await _hold([], 1)
	for index in 210:
		await physics_frame
		if level.receivers["pressure"].charge == 3:
			break
	_check(level.receivers["pressure"].charge == 3, "normal Guard bait powers Pressure")
	await _hold(["move_right"], 108)
	await _hold(["move_right", "jump"], 18)
	await _hold(["move_right"], 35)
	await _hold(["move_right"], 32)
	var attack_count := 0
	for index in 620:
		var strike := false
		for bullet in level.projectiles:
			if is_instance_valid(bullet) and not bullet.is_reflected and bullet.velocity.x > 0.0 and bullet.global_position.x > level.player.global_position.x - 34.0 and bullet.global_position.x < level.player.global_position.x - 10.0 and absf(bullet.global_position.y - level.player.global_position.y) < 20.0:
				strike = true
				break
		if strike:
			Input.action_press("move_left")
			Input.action_press("attack")
			attack_count += 1
		else:
			Input.action_release("attack")
			Input.action_release("move_left")
			if level.player.global_position.x < 985.0:
				Input.action_press("move_right")
			else:
				Input.action_release("move_right")
		await physics_frame
		if level.receivers["core"].charge >= 3 or not level.player.active:
			break
	Input.action_release("attack")
	Input.action_release("move_left")
	Input.action_release("move_right")
	_check(level.receivers["gallery"].charge == 2, "live player reflection powers Signal")
	_check(level.receivers["core"].charge == 3, "later live reflections power the Core")
	await _hold(["move_left"], 131)
	await _hold(["move_left", "jump"], 22)
	await _hold([], 27)
	await _hold(["move_right", "jump"], 22)
	await _hold([], 27)
	await _hold(["move_left", "jump"], 22)
	await _hold([], 27)
	await _hold(["move_right", "jump"], 22)
	await _hold([], 27)
	await _hold(["jump"], 22)
	await _hold([], 30)
	_check(level.finished, "input-only live route reaches synchronized exit")
	level.queue_free()
	await physics_frame
	if failures.is_empty():
		print("CIRCUIT ROUTE PASS")
	else:
		for failure in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)

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
