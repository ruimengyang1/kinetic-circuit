extends "res://tests/final_rescue_route.gd"

# Input-only late-first attempt, followed by quick R and an earlier start.
# No player position, laser phase, platform state or Can intent is assigned.
func run() -> void:
	output_dir = "res://artifacts/final_rescue"
	expert = true
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = 2
	root.add_child(game)
	await step()
	await park_rotor(364)
	var rotor: Node2D = game.machines.rotator
	var goal: float = (game.machines.boarding_sensor.position - rotor.beam_origin()).angle()
	for i in 300:
		if rotor.angle >= goal: break
		await step()
	mark("late attempt: start moving when beam already reaches target")
	await walk(265)
	for i in 120:
		if not rotor.occupied and game.can.state in ["recover", "idle"]: break
		await step()
	var wrong_angle: float = rad_to_deg(rotor.angle)
	if "--investigate" in OS.get_cmdline_user_args():
		for i in 140:
			if game.player.position.y + 9 < 220: break
			await step()
		if game.player.position.y + 9 < 220:
			await walk(338)
			await upper_crossing()
			for i in 30:
				if game.mode == "clear": break
				await step(1)
		var evidence := FileAccess.open(output_dir + "/baseline/late_reaction_bypass.json", FileAccess.WRITE)
		evidence.store_string(JSON.stringify({"input_only": true, "completed": game.mode == "clear", "angle": wrong_angle, "metrics": game.metrics(), "trace": trace}, "\t"))
		print("LATE REACTION INVESTIGATION completed=", game.mode == "clear", " angle=", wrong_angle)
		game.free()
		quit()
		return
	if game.machines.boarding_sensor.illuminated or game.machines.sensor.illuminated or not game.completed.is_empty(): fail("late departure must overshoot first setup, not accidentally freeze next setup")
	mark("visible overshoot; retry immediately and start earlier")
	Input.action_press("restart")
	await step()
	Input.action_release("restart")
	for i in 3: await step()
	if game.mode != "play" or game.level_index != 2: fail("R must restore same room immediately")
	await timing_room()
	for i in 30:
		if game.mode == "clear": break
		await step(1)
	if game.mode != "clear" or game.stats.hits != 0: fail("earlier departure should complete without damage")
	var file := FileAccess.open(output_dir + "/late_start_learning.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"input_only": true, "late_angle": wrong_angle, "target_angle": rad_to_deg(goal), "retry_control_within_frames": 4, "notes": notes, "metrics": game.metrics(), "failures": failures, "trace": trace}, "\t"))
	print("LATE START LEARNING late=", wrong_angle, " target=", rad_to_deg(goal), " failures=", failures)
	game.free()
	quit(0 if failures.is_empty() else 1)
