extends "res://tests/demo_route.gd"
var upper_opening := false
var retreat_bait := 225.0
var evidence_directory := "res://artifacts/rebalance"

# Rehearsed routes, player input only after spawn. They measure feasibility
# and consequences, never novice discovery or fun. Preserve old evidence.
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

func redirect() -> void:
	if upper_opening:
		for i in 90:
			if absf(game.player.position.x - 80) < 3 and absf(game.player.velocity.x) < 8: break
			await step(direction(80))
		for i in 180:
			if game.platforms.service.powered: break
			await step(direction(80))
		if not game.platforms.service.powered: fail("left opening")
		await step(1, true)
		for i in 150:
			if game.player.is_on_floor() and absf(game.player.position.y + 9 - 220) < 3: break
			await step(direction(147))
		await walk(365)
		for i in 200:
			if game.platforms.freight.powered: break
			await step(direction(427), dodge())
		if not game.platforms.freight.powered: fail("upper approach freight force")
		await leap(535, 212)
		await walk(570)
		await leap(597, 174)
		await walk(616)
		return
	await walk(277)
	for i in 180:
		if game.platforms.shutter.powered: break
		await step(0, dodge())
	if not game.platforms.shutter.powered: fail("right opening")
	await walk(426)
	for i in 180:
		if game.platforms.freight.powered: break
		await step()
	if not game.platforms.freight.powered: fail("lower approach freight force")
	var rebounds_before: int = game.stats.rebounds
	await step(-1, true)
	for i in 180:
		if game.stats.rebounds > rebounds_before: break
		await step(direction(405))
	if game.stats.rebounds <= rebounds_before: fail("use parked Can for height")
	await settle(433, 248)
	await leap(535, 212)
	await walk(570)
	await leap(597, 174)
	await walk(616)

func weight() -> void:
	await walk(265, true)
	for i in 180:
		if game.platforms.duct.powered and (expert or absf(game.boulder.velocity.x) < 1): break
		await step(0, dodge())
	if not game.platforms.duct.powered: fail("Boulder transfers force to duct")
	if not expert and not game.machines.fan.flow_blocked: fail("first roll leaves nozzle obstructed")
	await walk(200, true)
	for i in 180:
		if not game.machines.fan.flow_blocked and absf(game.boulder.velocity.x) < 1: break
		await step(0, dodge())
	if game.machines.fan.flow_blocked: fail("clear nozzle with second force")
	await walk(244)
	for i in 160:
		if game.player.position.y < 123: break
		await step(direction(244))
	await walk(405)
	await settle(405, 146)
	await walk(529)
	await leap(590, 124)
	await walk(616)

func timing() -> void:
	await place_can_on_rotator(351, 281)
	if game.boulder.position.x < 411: fail("prepare Boulder landing")
	await withdraw(26 if expert else 18, 297)
	await walk(365)
	await leap(429, 286)
	await leap(472, 249)
	await leap(515, 222)
	await walk(547)
	await leap(598, 194)
	await walk(617)

func combine() -> void:
	await walk(399, true)
	for i in 240:
		if game.boulder.position.x > 430 and absf(game.boulder.velocity.x) < 1: break
		await step(0, dodge())
	if game.boulder.position.x < 430: fail("clear cover and nozzle")
	if expert:
		await walk(retreat_bait, true)
		await settle(retreat_bait, 280)
	else: await settle(401, 318)
	for i in 120:
		if game.can.intent_locked and game.can.facing < 0: break
		await step()
	await walk(299, true)
	for i in 180:
		if game.player.is_on_floor() and absf(game.player.position.y + 9 - 248) < 3 and game.machines.rotator.occupied: break
		await step(direction(281), game.player.is_on_floor() and game.player.position.y > 248)
	# Prepare above the lower beam before the collector carries Can upward.
	await walk(342, true)
	for i in 420:
		if game.machines.sensor.active and not game.machines.rotator.occupied: break
		await step(direction(342), game.player.is_on_floor() and game.player.position.y > 224)
	if not game.machines.sensor.active: fail("combined optical alignment")
	await settle(342, 224)
	await leap(332, 199)
	await walk(335)
	await leap(397, 190)
	await walk(420)
	if expert:
		await leap(535, 180)
		await walk(574)
		await leap(604, 142)
		await walk(618)
		return
	await leap(470, 206)
	await leap(535, 180)
	await walk(574)
	await leap(604, 142)
	await walk(618)

func capture(name: String) -> void:
	if expert: name = "expert_" + name
	elif upper_opening: name = "upper_" + name
	if name in captures: return
	captures.append(name)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(evidence_directory + "/screenshots/" + name + ".png")

func live_capture() -> void:
	var index: int = game.level_index + 1
	if frame < 10: await capture("L%d_start" % index)
	if game.can.state == "windup" and game.can.intent_locked: await capture("L%d_locked" % index)
	if game.stats.impacts > 0: await capture("L%d_impact" % index)
	if game.machines.has("fan"):
		if game.machines.fan.flow_blocked and game.stats.boulder_impacts > 0 and absf(game.boulder.velocity.x) < 1: await capture("L%d_nozzle_obstructed" % index)
		if not game.machines.fan.flow_blocked and game.player.velocity.y < -100: await capture("L%d_airflow" % index)
	if game.machines.has("rotator"):
		if game.machines.rotator.occupied: await capture("L%d_control" % index)
		if game.machines.rotator.near_alignment and game.machines.rotator.occupied: await capture("L%d_stopping_preview" % index)
		if game.machines.sensor.active: await capture("L%d_alignment" % index)
		if game.machines.rotator.exposure_time > 0: await capture("L%d_exposed_warning" % index)
	if index == 4 and game.can.position.y < 270: await capture("L4_carried_can")
	if game.mode in ["clear", "complete"]: await capture("L%d_exit" % index)
