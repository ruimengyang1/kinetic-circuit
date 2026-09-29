extends SceneTree

# Input-only shallow attempts are separate from explicitly labelled controlled
# geometry/optical fixtures. These probes are bounded, never proofs of intent.
var game: Node2D
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var output_dir := "res://artifacts/precision_progression/revision"
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output_dir = arg.substr(9)
	call_deferred("run")
func step(side: float = 0, jump: bool = false, attack: bool = false) -> void:
	await process_frame
	for pair in [["move_right", side > 0], ["move_left", side < 0], ["jump", jump], ["attack", attack]]:
		if pair[1] and not Input.is_action_pressed(pair[0]): Input.action_press(pair[0])
		elif not pair[1] and Input.is_action_pressed(pair[0]): Input.action_release(pair[0])
	await physics_frame
func spawn(index: int) -> void:
	if game != null: game.free()
	for action in ["move_right", "move_left", "jump", "attack", "restart"]:
		if InputMap.has_action(action): Input.action_release(action)
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = index
	root.add_child(game)
	await step()
func check(value: bool, message: String) -> void:
	if not value: failures.append(message)
	print("PASS " if value else "FAIL ", message)
func run() -> void:
	for index in 4:
		for pattern in ["standstill", "right", "right_jump", "ignore_can", "one_bait_then_right", "random_right", "wander_stomp"]:
			for seed_value in range(4 if pattern in ["random_right", "wander_stomp"] else 1):
				await spawn(index)
				rng.seed = 711 + seed_value
				var side := 0.0 if pattern == "standstill" else 1.0
				var jump_left := 0
				if pattern == "one_bait_then_right":
					for f in 180:
						var target: float = [185, 185, 334, 225][index]
						await step(signf(target - game.player.position.x) if absf(target - game.player.position.x) > 4 else 0.0, f % 45 < 23)
						if game.stats.charges > 0 and game.can.state in ["impact", "recover", "idle"]: break
				for f in 900:
					if pattern == "ignore_can": game.can.suspended = true
					if pattern in ["random_right", "wander_stomp"]:
						if f % 36 == 0:
							side = 1.0 if pattern == "random_right" or rng.randf() < 0.7 else -1.0
							if rng.randf() < 0.75: jump_left = rng.randi_range(12, 30)
						jump_left = maxi(0, jump_left - 1)
					var jumping := f % 43 < 23 if pattern in ["right_jump", "ignore_can", "one_bait_then_right"] else jump_left > 0
					await step(side, jumping, pattern == "wander_stomp" and f % 61 < 8)
					if not game.completed.is_empty(): break
				var label := "L%d %s seed%d" % [index + 1, pattern, seed_value]
				cases.append({"case": label, "input_only": pattern != "ignore_can", "completed": not game.completed.is_empty(), "deaths": game.total_deaths, "metrics": game.metrics()})
				check(game.completed.is_empty(), label + " cannot complete")
				if pattern == "standstill": check(game.stats.charges == 0, "L%d no input never performs the first interaction" % (index + 1))
		# Worst-position bounce fixture: test actual vertical impulse directly
		# below the exit, with unchanged geometry and no objective flags.
		await spawn(index)
		game._freeze(true)
		game.player.active = true
		game.can.position = Vector2(game.exit_rect.position.x - 30, 305.9)
		game.player.position = Vector2(game.can.position.x - 40, 309)
		game.player.previous_position = game.player.position
		game.player.previous_feet = 318
		for f in 360: await step(1, f % 45 < 23)
		check(game.completed.is_empty(), "L%d accidental exit-side ground Can bounce cannot bypass height" % (index + 1))
	# Controlled destination fixtures test the door itself, independently of
	# whether a route can legitimately reach it through physical geometry.
	for index in 4:
		await spawn(index)
		game._freeze(true)
		game.player.active = true
		game.player.position = Vector2(game.exit_rect.position.x + 12, game.exit_floor - 30)
		game.player.velocity = Vector2(0, -120)
		await step(1)
		check(game.mode == "play", "L%d airborne exit contact does not finish" % (index + 1))
		game.player.position = Vector2(game.exit_rect.position.x - 4, game.exit_floor - 9)
		game.player.velocity = Vector2.ZERO
		for i in 15:
			await step(1)
			if game.mode == "clear": break
		check(game.mode == "clear", "L%d floor exit requires landing and walk, no hidden flags" % (index + 1))
	for i in 44: await step()
	check(game.mode == "complete", "final exit reaches victory")
	Input.action_press("restart")
	await step()
	Input.action_release("restart")
	for i in 3: await step()
	check(game.level_index == 0 and game.completed.is_empty(), "R after victory starts fresh")
	# Keep weight continuously on the rotor. Let several useful-angle passes
	# run naturally; transient power must never create a viable exit launch.
	for index in [2, 3]:
		await spawn(index)
		game.player.active = false
		game.can.position = Vector2(338 if index == 2 else 272.1, 305.9)
		game.can.state = "recover"
		game.can.state_time = 1000
		if index == 3: game.platforms.shutter.set_power(true)
		var farthest := 0.0
		var highest := 1000.0
		var pulses := 0
		var was_lit := false
		for f in 1700:
			await step()
			farthest = maxf(farthest, game.platforms.crossing.position.x + game.platforms.crossing.size.x / 2)
			highest = minf(highest, game.platforms.crossing.position.y - 5)
			if game.machines.sensor.active and not was_lit: pulses += 1
			was_lit = game.machines.sensor.active
		var max_jump := 235.0 * 235 / (2 * 650)
		var gap := 584 - farthest
		cases.append({"case": "L%d transient beam fixture" % (index + 1), "controlled_fixture": true, "pulses": pulses, "farthest_platform_edge": farthest, "highest_top": highest, "exit_gap": gap, "maximum_jump_rise": max_jump})
		check(pulses >= 2 and highest - game.exit_floor > max_jump + 4, "L%d passing final beam cannot supply exit height" % (index + 1))
	# Retry/death state includes momentum and earlier progression.
	await spawn(2)
	game.completed.assign([{"level": 1}, {"level": 2}])
	game.player.velocity = Vector2(155, -170)
	Input.action_press("restart")
	await step()
	Input.action_release("restart")
	for i in 3: await step()
	check(game.level_index == 2 and game.completed.size() == 2 and game.player.health == 3 and absf(game.player.velocity.x) < 0.1, "R clears momentum and preserves prior completions")
	game.player.kill()
	var frames := 0
	for i in 60:
		await step()
		frames += 1
		if game.mode == "play" and game.player.active: break
	check(frames <= 60 and game.completed.size() == 2 and game.player.health == 3, "death restores control within one second and preserves progress")
	cases.append({"case": "death recovery", "seconds": frames / 60.0})
	DirAccess.make_dir_recursive_absolute(output_dir)
	var file := FileAccess.open(output_dir + "/audit.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"bounded": true, "cases": cases, "failures": failures}, "\t"))
	game.free()
	print("PRECISION AUDIT failures=", failures)
	quit(0 if failures.is_empty() else 1)
