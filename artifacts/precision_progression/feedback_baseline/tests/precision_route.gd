extends "res://tests/demo_route.gd"

# Rehearsed styles, not human novice/expert measurements. Input is the only
# actuator after spawn. World/actor state is read but never assigned.
var notes: Array[Dictionary] = []
var lead_offset := 0.0
var output_dir := "res://artifacts/precision_progression"
var inspect_frames := 24

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--level="): selected = int(arg.substr(8)) - 1
		if arg.begins_with("--offset="): lead_offset = float(arg.substr(9))
	capture_run = "--capture" in OS.get_cmdline_user_args()
	expert = "--expert" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(output_dir + "/screenshots")
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = maxi(0, selected)
	root.add_child(game)
	await step()
	var first: int = game.level_index
	for index in range(first, 4 if selected < 0 else first + 1):
		mark("room start")
		match index:
			0: await direction_room()
			1: await position_room()
			2: await timing_room()
			3: await combination_room()
		if not failures.is_empty(): break
		for i in 80:
			if game.mode in ["clear", "complete"]: break
			await step(1)
		if game.mode not in ["clear", "complete"]: fail("physical exit not reached")
		print("PRECISION L", index + 1, " seconds=", game.level_time, " stats=", game.stats)
		if not failures.is_empty(): break
		if selected < 0 and index < 3:
			for i in 90:
				await step()
				if game.level_index == index + 1: break
	if selected < 0 and failures.is_empty():
		for i in 65:
			if game.mode == "complete": break
			await step()
		if game.mode != "complete": fail("full victory flow")
		for i in 45: await step()
	var suffix := "expert" if expert else "novice"
	if selected >= 0: suffix += "_L%d" % (selected + 1)
	if lead_offset != 0: suffix += "_offset%d" % int(lead_offset)
	if capture_run: suffix += "_visible"
	var file := FileAccess.open(output_dir + "/route_" + suffix + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"input_only": true, "rehearsed": true, "style": "anticipate / preposition / chain" if expert else "inspect / react / reposition", "failures": failures, "completed": game.completed, "notes": notes, "trace": trace}, "\t"))
	print("PRECISION ROUTE ", suffix, " frames=", frame, " failures=", failures)
	for action in ["move_left", "move_right", "jump", "attack"]: Input.action_release(action)
	game.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func step(axis: float = 0, jump: bool = false, attack: bool = false) -> void:
	await process_frame
	hold("move_left", axis < -0.1)
	hold("move_right", axis > 0.1)
	if jump and not Input.is_action_pressed("jump"): jump_hold = 23
	hold("jump", jump_hold > 0 and not attack)
	jump_hold = maxi(0, jump_hold - 1)
	hold("attack", attack)
	await physics_frame
	frame += 1
	var sample := snapshot()
	sample["input"] = {"left": Input.is_action_pressed("move_left"), "right": Input.is_action_pressed("move_right"), "jump": Input.is_action_pressed("jump"), "attack": Input.is_action_pressed("attack")}
	sample["seconds"] = game.level_time
	trace.append(sample)
	if frame > 10000: fail("route budget")
	if capture_run: await live_capture()

func leap(x: float, top: float, limit: int = 120) -> void:
	if not failures.is_empty(): return
	# A distinct release/press is a normal new jump, even when the preceding
	# landing occurred before an authored hold's timer finished.
	jump_hold = 0
	hold("jump", false)
	await step(direction(x))
	await step(direction(x), true)
	for i in limit:
		if game.mode != "play": return
		if game.player.is_on_floor() and absf(game.player.position.y + 9 - top) < 3 and absf(game.player.position.x - x) < 8: return
		await step(direction(x))
	fail("leap %.0f/%.0f" % [x, top])

func mark(note: String) -> void:
	notes.append({"note": note, "level": game.level_index + 1, "seconds": game.level_time, "player": game.player.position, "can": game.can.position})

func inspect() -> void:
	if not expert:
		mark("inspect result")
		for i in inspect_frames: await step()

func wait_power(id: String, limit: int = 160) -> void:
	if not failures.is_empty(): return
	for i in limit:
		if not failures.is_empty(): return
		if game.platforms[id].powered: return
		await step()
	fail(id + " force not applied")

func safe_perch(x: float) -> void:
	if not failures.is_empty(): return
	for i in 240:
		if game.player.is_on_floor() and absf(game.player.position.y + 9 - 248) < 3 and absf(game.player.position.x - x) < 8: return
		await step(direction(x), game.player.is_on_floor() and game.player.position.y + 9 > 251)
	fail("safe observation perch")

func open_initial_shutter() -> void:
	for i in 60:
		if game.can.state == "windup" and game.can.facing > 0: break
		await step(direction(195))
	# A broad jump to the first step clears the machine, then a second ordinary
	# jump enters the visibly safe observation shelf above its search lane.
	await safe_perch(175)
	await wait_power("shutter")
	await inspect()

func direction_room() -> void:
	await open_initial_shutter()
	await walk(100)
	await wait_power("service")
	await inspect()
	await settle(100, 250)
	await leap(163, 214)
	await walk(440)

func position_room() -> void:
	await open_initial_shutter()
	if not expert:
		mark("wrong endpoint: repeated right")
		await walk(250)
		await settle(250, 318)
		for i in 120:
			if game.can.intent_locked and game.can.facing > 0: break
			await step()
		await safe_perch(311)
		for i in 160:
			if game.can.position.x > 460 and game.can.state in ["impact", "recover", "idle"]: break
			await step()
		await inspect()
		mark("correct endpoint: return, then park left")
		await walk(250)
		await settle(250, 318)
		for i in 120:
			if game.can.intent_locked and game.can.facing < 0: break
			await step()
		await safe_perch(175)
		for i in 160:
			if game.can.position.x < 225 and game.can.state in ["impact", "recover", "idle"]: break
			await step()
	await walk(110)
	await settle(110, 318)
	for i in 120:
		if game.can.intent_locked and game.can.facing < 0: break
		await step()
	await safe_perch(175)
	for i in 180:
		if game.machines.button.active: break
		await step()
	if not game.machines.button.active: fail("useful parked Can must hold ascent")
	await inspect()
	await walk(200)
	await leap(311, 248)
	await walk(378)
	await walk(421)
	await settle(421, 250)
	await walk(466)
	await leap(545, 214)
	await walk(615)

func park_rotor(x: float) -> void:
	await walk(x)
	await safe_perch(x)
	for i in 150:
		if game.machines.rotator.occupied and game.can.state in ["impact", "recover", "idle"]: break
		await step()
	if not game.machines.rotator.occupied: fail("charge endpoint must occupy rotor")
	mark("Can parked on rotor")

func withdraw(bait: float, lead: float) -> void:
	if not failures.is_empty(): return
	var rotor: Node2D = game.machines.rotator
	var target: float = (game.machines.sensor.position - rotor.beam_origin()).angle()
	for i in 500:
		var gap: float = rad_to_deg(angle_difference(rotor.angle, target))
		if (rotor.rotation_rate > 0 and gap <= lead + lead_offset) or (rotor.rotation_rate < 0 and gap >= -lead - lead_offset): break
		await step()
	mark("begin anticipated withdrawal")
	await walk(bait)
	await settle(bait, 281)
	for i in 140:
		if game.can.intent_locked: break
		await step()
	# Leave the acquisition lane before recovery, maintaining the parked state.
	await safe_perch(334 if game.level_index == 2 else 391)
	for i in 160:
		if not rotor.occupied and game.machines.sensor.active: return
		await step()
	fail("useful frozen angle %.2f" % rad_to_deg(rotor.angle))

func crossing_route(perch_x: float) -> void:
	await inspect()
	await walk(perch_x)
	await settle(perch_x, 248)
	for i in 140:
		if game.platforms.crossing.position.x >= 516: break
		await step()
	await leap(532, 216)
	await walk(565)
	await leap(609, 180)
	await walk(615)

func flow_crossing(board_x: float) -> void:
	if not failures.is_empty(): return
	mark("preposition to board crossing while Can completes charge")
	for i in 120:
		if game.platforms.crossing.position.x >= 325: break
		await step()
	await leap(board_x, 216)
	mark("ride crossing into next jump setup")
	for i in 120:
		if game.platforms.crossing.position.x >= 480: break
		await step()
	await walk(550)
	await leap(609, 180)
	await walk(615)

func timing_room() -> void:
	await park_rotor(334)
	await inspect()
	await withdraw(265, 23)
	if expert:
		await flow_crossing(390)
	else:
		await leap(432, 248)
		await crossing_route(448)

func combination_room() -> void:
	await park_rotor(225)
	await inspect()
	await withdraw(389, 23)
	await wait_power("shutter")
	if expert:
		await flow_crossing(391)
	else:
		await walk(448)
		await crossing_route(448)

func capture(name: String) -> void:
	if expert: name = "expert_" + name
	if name in captures: return
	captures.append(name)
	paused = true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output_dir + "/screenshots/" + name + ".png")
	paused = false

func live_capture() -> void:
	var level: int = game.level_index + 1
	await capture("L%d_start" % level)
	if game.can.state == "lock": await capture("L%d_lock" % level)
	if game.can.state == "impact": await capture("L%d_endpoint" % level)
	if game.machines.has("button") and game.machines.button.active and game.can.state in ["impact", "recover", "idle"]: await capture("L2_parked")
	if game.machines.has("rotator"):
		if game.machines.rotator.occupied: await capture("L%d_turning" % level)
		if not game.machines.rotator.occupied and game.machines.sensor.active: await capture("L%d_frozen" % level)
	if game.mode in ["clear", "complete"]: await capture("L%d_exit" % level)

func snapshot() -> Dictionary:
	var result := super.snapshot()
	result["feet"] = game.player.position.y + 9
	return result
