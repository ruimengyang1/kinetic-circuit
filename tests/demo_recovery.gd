extends SceneTree
var game: Node2D
var failures: Array[String] = []
var checks: Array[String] = []
func _initialize() -> void: call_deferred("run")
func step(direction: float = 0, jump: bool = false) -> void:
	await process_frame
	for pair in [["move_right", direction > 0], ["move_left", direction < 0], ["jump", jump]]:
		if pair[1]: Input.action_press(pair[0])
		else: Input.action_release(pair[0])
	await physics_frame
func check(value: bool, message: String) -> void:
	checks.append(message)
	if not value: failures.append(message)
	print("PASS " if value else "FAIL ", message)
func spawn(index: int) -> void:
	if game != null: game.free()
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = index
	root.add_child(game)
	await step()
func run() -> void:
	# Ordinary jump spam without manipulating the machine must not win. Can
	# is isolated for this mechanical audit; input-only routes test active AI.
	for index in 4:
		await spawn(index)
		game.can.suspended = true
		for i in 400:
			await step(1, i % 40 < 23)
			game.can.suspended = true
		check(game.completed.is_empty(), "T L%d ordinary forward/jump cannot bypass machinery" % (index + 1))
		game.player.position = Vector2(614, game.exit_floor - 30)
		game.player.velocity = Vector2(0, -120)
		await step(1)
		check(game.mode == "play", "U L%d airborne doorway grazing cannot win" % (index + 1))
		# Actual alcove floor allows completion without checking any machine
		# flag. This fixture distinguishes physical gating from hidden flags.
		game.player.position = Vector2(600, game.exit_floor - 9)
		game.player.velocity = Vector2.ZERO
		for i in 15:
			await step(1)
			if game.mode == "clear": break
		check(game.mode == "clear", "physical exit floor, no invisible completion prerequisite L%d" % (index + 1))
	await spawn(2)
	game.completed.assign([{"level": 1}, {"level": 2}])
	Input.action_press("restart")
	await step()
	Input.action_release("restart")
	for i in 4: await step()
	check(game.level_index == 2 and game.player.health == 3 and game.completed.size() == 2 and game.total_resets == 1, "V R restores only current level, preserving earlier progress")
	game.player.kill()
	for i in 22: await step()
	check(game.level_index == 2 and game.mode == "play" and game.player.health == 3 and game.completed.size() == 2 and game.total_deaths == 1, "W death recovery under one second preserves progression")
	game.free()
	for action in ["move_left", "move_right", "jump", "restart"]: Input.action_release(action)
	var file := FileAccess.open("res://artifacts/final_demo/recovery.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks": checks, "failures": failures}, "\t"))
	file.close()
	print("FINAL RECOVERY ", checks.size(), " checks; failures ", failures)
	quit(0 if failures.is_empty() else 1)
