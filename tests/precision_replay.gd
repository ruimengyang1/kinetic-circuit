extends SceneTree
# Open-loop replay of every recorded input; decisions never read world state.
# Compare every boundary against the authored reference, with real hit-stop.
var game: Node2D
var output_dir := "res://artifacts/precision_progression/revision"
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output_dir = arg.substr(9)
	call_deferred("run")
func run() -> void:
	var reference: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(output_dir + "/route_expert_flow.json"))
	game = load("res://scenes/final_demo.tscn").instantiate()
	root.add_child(game)
	var differences: Array[Dictionary] = []
	for sample in reference.trace:
		await process_frame
		for pair in [["move_left", sample.input.left], ["move_right", sample.input.right], ["jump", sample.input.jump], ["attack", sample.input.attack]]:
			if pair[1] and not Input.is_action_pressed(pair[0]): Input.action_press(pair[0])
			elif not pair[1] and Input.is_action_pressed(pair[0]): Input.action_release(pair[0])
		await physics_frame
		var platform_positions: Array = game.platforms.values().map(func(platform: Node2D) -> String: return str(platform.position))
		var laser_angle: float = rad_to_deg(game.machines.rotator.angle) if game.machines.has("rotator") else 0
		var sensor_active: bool = game.machines.sensor.active if game.machines.has("sensor") else false
		var machine_state: Dictionary = {}
		for id in game.machines:
			var machine: Node2D = game.machines[id]
			machine_state[id] = {"active": machine.active, "occupied": machine.occupied, "illuminated": machine.illuminated}
		if machine_state != sample.machines or platform_positions != sample.platforms or absf(laser_angle - float(sample.angle)) > 0.000001 or sensor_active != sample.sensor or str(game.player.position) != sample.p or str(game.can.position) != sample.can or game.can.state != sample.state or game.mode != sample.mode or game.level_index + 1 != sample.level:
			if differences.size() < 8: differences.append({"frame": sample.f, "actual_player": game.player.position, "expected_player": sample.p, "actual_can": game.can.position, "expected_can": sample.can, "actual_state": game.can.state, "expected_state": sample.state})
	var success: bool = differences.is_empty() and game.mode == "complete" and game.completed.size() == 4
	var file := FileAccess.open(output_dir + "/replay.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"open_loop": true, "frames_compared": reference.trace.size(), "exact_position_state_match": differences.is_empty(), "compared": ["player", "Can", "platforms", "laser angle", "all machine power/occupancy/illumination", "mode", "level"], "completed": game.completed.size(), "differences": differences}, "\t"))
	print("PRECISION REPLAY ", reference.trace.size(), " frames; exact match=", differences.is_empty(), " completed=", game.completed.size())
	game.free()
	quit(0 if success else 1)
