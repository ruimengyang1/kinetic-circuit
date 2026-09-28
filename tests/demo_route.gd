extends SceneTree

# Routes were recorded after building and inspecting the four maps. Inputs are
# the only actuator after fresh spawn; world state is observed, never assigned.
var game: Node2D
var failures: Array[String] = []
var trace: Array[Dictionary] = []
var frame := 0
var jump_hold := 0
var selected := -1
var capture_run := false
var expert := false
var captures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--level="): selected = int(arg.substr(8)) - 1
	capture_run = "--capture" in OS.get_cmdline_user_args()
	expert = "--expert" in OS.get_cmdline_user_args()
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
	if selected < 0 or selected == 3:
		for i in 65:
			if game.mode == "complete": break
			await step()
	if expert and failures.is_empty() and game.stats.charging_rebounds < 2: fail("expert must preserve two committed rebounds")
	var result := {"input_only": true, "expert": expert, "level": selected + 1, "frames": frame, "failures": failures, "completed": game.completed, "current": game.metrics(), "trace": trace}
	var suffix := "expert" if expert else "sequential"
	if "--rush" in OS.get_cmdline_user_args(): suffix += "_rush"
	if selected >= 0: suffix += "_L%d" % (selected + 1)
	var file := FileAccess.open("res://artifacts/final_demo/route_" + suffix + ("_graphics" if capture_run else "") + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(result, "\t"))
	file.close()
	print("DEMO ROUTE ", suffix, " frames ", frame, " failures ", failures)
	for action in ["move_left", "move_right", "jump", "attack"]: Input.action_release(action)
	game.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func step(direction: float = 0, jump: bool = false, attack: bool = false) -> void:
	await process_frame
	hold("move_left", direction < -0.1)
	hold("move_right", direction > 0.1)
	if jump and not Input.is_action_pressed("jump"): jump_hold = 23
	hold("jump", jump_hold > 0 and not attack)
	jump_hold = maxi(0, jump_hold - 1)
	hold("attack", attack)
	await physics_frame
	frame += 1
	if frame % 15 == 0: trace.append(snapshot())
	if frame % 300 == 0: print(snapshot())
	if frame > 10000: fail("route budget")
	if capture_run: await live_capture()

func hold(action: String, value: bool) -> void:
	if value and not Input.is_action_pressed(action): Input.action_press(action)
	elif not value and Input.is_action_pressed(action): Input.action_release(action)

func direction(x: float) -> float:
	return signf(x - game.player.position.x) if absf(x - game.player.position.x) > 3 else 0

func dodge() -> bool:
	return game.player.is_on_floor() and absf(game.can.position.y - game.player.position.y) < 26 and absf(game.can.position.x - game.player.position.x) < 58

func walk(x: float, auto_jump: bool = false, limit: int = 300) -> void:
	if not failures.is_empty(): return
	for i in limit:
		if game.mode != "play": return
		if absf(game.player.position.x - x) < 4: return
		await step(direction(x), dodge() or (auto_jump and game.player.is_on_floor()))
	fail("walk %.0f" % x)

func settle(x: float, top: float, limit: int = 180) -> void:
	if not failures.is_empty(): return
	for i in limit:
		if game.mode != "play": return
		if game.player.is_on_floor() and absf(game.player.position.y + 9 - top) < 3 and absf(game.player.position.x - x) < 8: return
		await step(direction(x))
	fail("landing %.0f/%.0f" % [x, top])

func leap(x: float, top: float, limit: int = 120) -> void:
	if not failures.is_empty(): return
	await step(direction(x), true)
	for i in limit:
		if game.mode != "play": return
		if game.player.is_on_floor() and absf(game.player.position.y + 9 - top) < 3 and absf(game.player.position.x - x) < 8: return
		await step(direction(x))
	fail("leap %.0f/%.0f" % [x, top])

func redirect() -> void:
	await walk(277)
	for i in 180:
		if game.platforms.shutter.powered: break
		await step(0, dodge())
	if not game.platforms.shutter.powered: fail("shutter force")
	await walk(473, true)
	for i in 250:
		if game.player.is_on_floor() and game.player.position.y < 201: break
		await step(direction(482), dodge())
	await settle(489, 190)
	await leap(583, 168)
	await walk(616)

func weight() -> void:
	await walk(343, true)
	for i in 200:
		if game.machines.button.active: break
		await step(0, dodge())
	if not game.machines.button.active: fail("Boulder weight")
	if "--rush" in OS.get_cmdline_user_args(): await settle(345, 318)
	# Observe the linked shuttle instead of blindly entering the new updraft.
	for i in (0 if expert or "--rush" in OS.get_cmdline_user_args() else 120):
		if game.platforms.shuttle.position.x < 369: break
		await step()
	await walk(409)
	for i in 160:
		if game.player.position.y < 124: break
		await step(direction(409))
	await walk(481)
	await settle(481, 146)
	await walk(529)
	await leap(590, 124)
	await walk(616)

func place_can_on_rotator(park_x: float, perch_top: float) -> void:
	await walk(park_x, true)
	for i in 240:
		var p: CharacterBody2D = game.player
		if p.is_on_floor() and absf(p.position.y + 9 - perch_top) < 3 and game.machines.rotator.occupied: return
		await step(direction(park_x), p.is_on_floor() and p.position.y + 9 > perch_top + 3)
	fail("Can placement and control perch")

func withdraw(lead_degrees: float, bait_x: float) -> void:
	if not failures.is_empty(): return
	var rotator: Node2D = game.machines.rotator
	var sensor: Node2D = game.machines.sensor
	var target: float = (sensor.position - rotator.beam_origin()).angle()
	for i in 500:
		if rotator.angle >= target - deg_to_rad(lead_degrees): break
		await step()
	await walk(bait_x)
	for i in 140:
		if not rotator.occupied and game.machines.sensor.active: return
		await step()
	fail("anticipatory withdrawal; angle %.1f target %.1f" % [rad_to_deg(rotator.angle), rad_to_deg(target)])

func timing() -> void:
	await place_can_on_rotator(351, 281)
	await withdraw(26, 297)
	await walk(359)
	await leap(395, 249)
	await leap(501, 222)
	await walk(547)
	await leap(598, 194)
	await walk(617)

func combine() -> void:
	if expert: await compound_boulder()
	else: await walk(350, true)
	for i in 240:
		if game.machines.button.active: break
		await step(0, dodge())
	if not game.machines.button.active: fail("combined weight chain")
	await walk(299, true)
	for i in 160:
		if game.player.is_on_floor() and absf(game.player.position.y + 9 - 280) < 3 and game.machines.rotator.occupied: break
		await step(direction(299), game.player.is_on_floor() and game.player.position.y > 280)
	# A sequential plan keeps the occupied pedal; the sensor's physical lift
	# removes Can weight itself, and exposes the newly carried threat.
	if expert:
		await lift_rebound()
		await settle(298, 199)
		await walk(337)
		await settle(363, 224)
		await walk(490)
		for i in 160:
			if game.player.position.y < 132: break
			await step(direction(490))
		await walk(532)
		await settle(532, 180)
		await walk(574)
		await leap(604, 142)
		await walk(618)
		return
	else:
		for i in 350:
			if game.machines.sensor.active and not game.machines.rotator.occupied: break
			await step(direction(301))
		if not game.machines.sensor.active: fail("combined optical activation")
	await walk(490)
	for i in 150:
		if game.player.position.y < 153: break
		await step(direction(490))
	await walk(532)
	await settle(532, 180)
	await walk(574)
	await leap(604, 142)
	await walk(618)

func lift_rebound() -> void:
	var rotator: Node2D = game.machines.rotator
	var target: float = (game.machines.sensor.position - rotator.beam_origin()).angle()
	for i in 400:
		if rotator.angle >= target - deg_to_rad(28): break
		await step(direction(303))
	await walk(233)
	var before: int = game.stats.rebounds
	for i in 110:
		if game.can.state == "charging" and game.can.position.x - game.player.position.x < 64: break
		await step()
	await step(1, true)
	for i in 100:
		if game.stats.rebounds > before: return
		var dx: float = game.can.position.x - game.player.position.x
		var attack: bool = absf(dx) < 25 and game.player.position.y > game.can.position.y - 55 and not game.player.is_on_floor()
		await step(1 if dx > 12 else 0, false, attack)
	fail("expert arriving lift rebound")

func compound_boulder() -> void:
	await walk(163)
	for i in 120:
		if game.can.state == "charging" and game.player.position.x - game.can.position.x < 60: break
		await step()
	await step(1, true)
	for i in 90:
		var dx: float = game.can.position.x - game.player.position.x
		var attack: bool = absf(dx) < 23 and game.player.position.y > game.can.position.y - 52 and not game.player.is_on_floor()
		if game.stats.charging_rebounds > 0: break
		await step(0, false, attack)
	if game.stats.charging_rebounds == 0: fail("expert committed rebound")
	await walk(299)

func snapshot() -> Dictionary:
	return {"f": frame, "level": game.level_index + 1, "mode": game.mode, "p": game.player.position, "v": game.player.velocity, "can": game.can.position, "state": game.can.state, "health": game.player.health, "platforms": game.platforms.values().map(func(p): return p.position), "B": game.boulder.position if game.boulder != null else Vector2.ZERO, "angle": rad_to_deg(game.machines.rotator.angle) if game.machines.has("rotator") else 0, "sensor": game.machines.sensor.active if game.machines.has("sensor") else false}

func fail(message: String) -> void:
	if failures.is_empty():
		failures.append(message + " / " + str(snapshot()))
		print("FAIL ", failures)

func capture(name: String) -> void:
	if expert: name = "expert_" + name
	if name in captures: return
	captures.append(name)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/final_demo/screenshots/" + name + ".png")

func live_capture() -> void:
	var index: int = game.level_index + 1
	if game.can.state == "windup" and game.can.intent_locked: await capture("L%d_locked" % index)
	if game.boulder != null and game.can.state == "charging" and game.can.facing > 0 and game.boulder.position.x - game.can.position.x < 65 and game.boulder.position.x - game.can.position.x > 28: await capture("L%d_before_boulder" % index)
	if game.stats.impacts > 0: await capture("L%d_impact" % index)
	if game.machines.has("button") and game.machines.button.active and (game.boulder == null or absf(game.boulder.velocity.x) < 1): await capture("L%d_button" % index)
	if game.machines.has("fan") and game.machines.fan.active and game.player.velocity.y < -100 and game.player.position.y < 260 and Rect2(game.machines.fan.position + game.machines.fan.rect.position, game.machines.fan.rect.size).has_point(game.player.position): await capture("L%d_fan_lift" % index)
	if game.platforms.has("shuttle") and game.platforms.shuttle.powered and game.platforms.shuttle.position.x > 390 and game.platforms.shuttle.position.x < 440: await capture("L2_linked_sweep")
	if game.machines.has("rotator"):
		if game.machines.rotator.occupied: await capture("L%d_rotator_hold" % index)
		if game.machines.rotator.angle > (game.machines.sensor.position - game.machines.rotator.beam_origin()).angle() - deg_to_rad(26) and game.machines.rotator.occupied: await capture("L%d_approaching_sensor" % index)
		if game.can.state == "windup" and game.can.facing < 0 and game.machines.rotator.occupied: await capture("L%d_bait_away" % index)
		if game.machines.sensor.active and game.platforms.crossing.position.x > 480: await capture("L%d_sensor_platform" % index)
	if index == 4 and game.can.position.y < 270: await capture("L4_can_lift_consequence")
	if index == 4 and game.stats.charging_rebounds > 0: await capture("L4_continued_charge_rebound")
	if game.mode in ["clear", "complete"]: await capture("L%d_exit" % index)
	if game.mode == "complete": await capture("victory")
