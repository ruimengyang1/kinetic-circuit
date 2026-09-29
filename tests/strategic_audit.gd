extends SceneTree

# Bounded shallow input attempts plus controlled recovery fixtures. These
# catch trivial routes, but are not exhaustive searches or human playtests.
var game: Node2D
var failures: Array[String] = []
var cases: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func step(direction: float = 0, jump: bool = false) -> void:
	await process_frame
	for pair in [["move_right", direction > 0], ["move_left", direction < 0], ["jump", jump]]:
		if pair[1]: Input.action_press(pair[0])
		else: Input.action_release(pair[0])
	await physics_frame
func spawn(index: int) -> void:
	if game != null: game.free()
	for action in ["move_right", "move_left", "jump", "attack", "restart"]:
		if InputMap.has_action(action): Input.action_release(action)
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = index
	root.add_child(game)
	await step()
func check(value: bool, label: String) -> void:
	if not value: failures.append(label)
	print("PASS " if value else "FAIL ", label)
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/level_progression/revision2/checks")
	for index in 4:
		var behaviors := ["forward", "forward_jump", "one_bait_forward"]
		if index == 1: behaviors.append_array(["left", "left_jump"])
		for behavior in behaviors:
			await spawn(index)
			if behavior == "one_bait_forward":
				var bait: float = [277, 407, 351, 399][index]
				for i in 240:
					var dx: float = bait - game.player.position.x
					var danger: bool = game.player.is_on_floor() and absf(game.can.position.x - game.player.position.x) < 55
					await step(signf(dx) if absf(dx) > 5 else 0.0, danger)
					if game.stats.charges > 0 and game.can.state in ["recover", "idle"]: break
			for i in 750:
				await step(-1 if behavior.begins_with("left") else 1, behavior in ["forward_jump", "left_jump"] and i % 45 < 23)
				if not game.completed.is_empty(): break
			var entry := {"level": index + 1, "behavior": behavior, "completed": not game.completed.is_empty(), "player": game.player.position,
				"can": game.can.position, "boulder": game.boulder.position if game.boulder != null else Vector2.ZERO,
				"deaths": game.total_deaths, "current": game.metrics()}
			cases.append(entry)
			if index == 1 and entry.completed:
				# A shallow input can legitimately choose the new covered fork.
				# Verify physical force use, not an invented mandatory sequence.
				check(game.completed[0].impacts > 0, "L2 %s uses real Can force rather than bypassing both routes" % behavior)
			else:
				check(not entry.completed, "L%d %s needs deliberate follow-up" % [index + 1, behavior])
	# Controlled floor/door fixtures: exits are actual destinations, never flags.
	for index in 4:
		await spawn(index)
		game._freeze(true)
		game.player.active = true
		game.player.position = Vector2(614, game.exit_floor - 30)
		game.player.velocity = Vector2(0, -120)
		await step(1)
		check(game.mode == "play", "L%d airborne door contact does not finish" % (index + 1))
		game.player.position = Vector2(600, game.exit_floor - 9)
		game.player.velocity = Vector2.ZERO
		for i in 15:
			await step(1)
			if game.mode == "clear": break
		check(game.mode == "clear", "L%d actual floor completes with no hidden prerequisites" % (index + 1))
	for i in 44: await step()
	check(game.mode == "complete", "final clear reaches the victory flow")
	Input.action_press("restart")
	await step()
	Input.action_release("restart")
	for i in 4: await step()
	check(game.level_index == 0 and game.completed.is_empty(), "R after victory starts a fresh demo")
	await spawn(2)
	game.completed.assign([{"level": 1}, {"level": 2}])
	Input.action_press("restart")
	await step()
	Input.action_release("restart")
	for i in 4: await step()
	check(game.level_index == 2 and game.player.health == 3 and game.completed.size() == 2, "R preserves earlier completions")
	game.player.kill()
	for i in 22: await step()
	check(game.level_index == 2 and game.mode == "play" and game.player.health == 3 and game.completed.size() == 2, "death recovery under one second preserves progression")
	var file := FileAccess.open("res://artifacts/level_progression/revision2/checks/audit.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"bounded_input_attempts": cases, "failures": failures}, "\t"))
	game.free()
	for action in ["move_right", "move_left", "jump", "attack", "restart"]: Input.action_release(action)
	print("REBALANCE AUDIT failures ", failures)
	quit(0 if failures.is_empty() else 1)
