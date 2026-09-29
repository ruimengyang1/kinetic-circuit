extends "res://tests/strategic_route.gd"

# Temporary recorder harness: inherited input-only routes, unchanged production scene.
func _initialize() -> void:
	evidence_directory = "res://artifacts/playthrough"
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(evidence_directory + "/screenshots")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--level="): selected = int(arg.substr(8)) - 1
		if arg.begins_with("--bait="): retreat_bait = float(arg.substr(7))
	capture_run = "--capture" in OS.get_cmdline_user_args()
	expert = "--expert" in OS.get_cmdline_user_args()
	upper_opening = "--upper" in OS.get_cmdline_user_args()
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = maxi(0, selected)
	root.add_child(game)
	await step()
	var first: int = game.level_index
	for index in range(first, 4 if selected < 0 else first + 1):
		match index:
			0: await redirect()
			1: await weight()
			2: await timing()
			3: await combine()
		if not failures.is_empty(): break
		for i in 80:
			if game.mode in ["clear", "complete"]: break
			await step(1)
		if game.mode not in ["clear", "complete"]: fail("physical exit not reached")
		if not failures.is_empty(): break
		print("LEVEL ", index + 1, " COMPLETE ", game.level_time, "s; ", game.stats)
		if index < 3 and selected < 0:
			for i in 90:
				await step()
				if game.level_index == index + 1: break
	for i in 240:
		await step()
	if game.mode != "complete": fail("final completion screen missing")
	var suffix := "expert" if expert else "sequential"
	if selected >= 0: suffix += "_L%d" % (selected + 1)
	if upper_opening: suffix += "_upper"
	if not is_equal_approx(retreat_bait, 225): suffix += "_bait%d" % int(retreat_bait)
	var file := FileAccess.open(evidence_directory + "/route_" + suffix + ("_graphics" if capture_run else "") + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"input_only": true, "rehearsed": true, "frames": frame, "failures": failures, "completed": game.completed, "current": game.metrics(), "trace": trace}, "\t"))
	file.close()
	print("REBALANCE ROUTE ", suffix, " frames ", frame, " failures ", failures)
	for action in ["move_left", "move_right", "jump", "attack"]: Input.action_release(action)
	game.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
