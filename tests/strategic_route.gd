extends "res://tests/rebalance_route.gd"

var departure_lead_degrees := 14.0

# Two deliberately different rehearsed strategies. Normal inputs are the only
# actuator after spawning; neither script is a blind novice playtest.
func _initialize() -> void:
	evidence_directory = "res://artifacts/strategic_depth"
	call_deferred("run")

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--lead="):
			departure_lead_degrees = float(arg.substr(7))
			evidence_directory += "/margins/lead%d" % int(departure_lead_degrees)
	await super.run()

func capture(name: String) -> void:
	if expert: name = "expert_" + name
	elif upper_opening: name = "upper_" + name
	if name in captures: return
	captures.append(name)
	# Photography must not add unactuated gameplay while awaiting a renderer.
	paused = true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(evidence_directory + "/screenshots/" + name + ".png")
	paused = false

func weight() -> void:
	await walk(407, true)
	if expert:
		await settle(407, 280)
	else:
		# Observe the result from the low approach before choosing safer height.
		await settle(503, 318)
		await walk(407)
	for i in 240:
		if game.stats.boulder_impacts > 0 and absf(game.boulder.velocity.x) < 1: break
		await step(direction(407), dodge())
	if game.stats.boulder_impacts == 0: fail("cover-changing Can force")
	if game.machines.fan.flow_blocked: fail("Boulder move opens air")
	await walk(342)
	for i in 180:
		if game.player.position.y < 126: break
		await step(direction(342))
	await walk(405)
	await settle(405, 146)
	await walk(529)
	await leap(590, 124)
	await walk(616)

func timing() -> void:
	await place_can_on_rotator(351, 281)
	if game.boulder != null: fail("L3 must not keep a compulsory landing Boulder")
	await withdraw(18, 297)
	await walk(365)
	await leap(407, 286)
	await leap(472, 249)
	await leap(515, 222)
	await walk(547)
	await leap(598, 194)
	await walk(617)

func combine() -> void:
	if expert: await preserved_cover_order()
	else: await cleared_cover_order()
	if not failures.is_empty(): return
	await walk(342)
	for i in 160:
		if game.player.position.y < 215: break
		await step(direction(342))
	await settle(342, 224)
	await leap(470, 249)
	await leap(535, 222)
	await walk(547)
	await leap(600, 182)
	await leap(604, 142)
	await walk(618)

func cleared_cover_order() -> void:
	# Useful action taken first; now the same Can must be brought back before
	# it can turn Laser. This plan can inspect/correct each state independently.
	await walk(399, true)
	for i in 200:
		if game.stats.boulder_impacts > 0 and absf(game.boulder.velocity.x) < 1: break
		await step(direction(399), dodge())
	await walk(272, true)
	await settle(272, 318)
	for i in 150:
		if game.can.intent_locked and game.can.facing < 0: break
		await step()
	await leap(225, 280)
	await leap(225, 248)
	for i in 150:
		if game.machines.rotator.occupied: break
		await step(direction(225))
	if not game.machines.rotator.occupied: fail("return Can to rotor after spending cover")
	await withdraw_right()

func preserved_cover_order() -> void:
	# Spend the initial left intent to get a known charge endpoint. The next
	# right commitment ends on the pedal before reaching the retained Boulder.
	for i in 60:
		if absf(game.player.position.x - 24) < 3: break
		await step(direction(24))
	for i in 180:
		if game.can.intent_locked and game.can.facing < 0: break
		await step(direction(24))
	for i in 10: await step(0, i == 0)
	await walk(225, true)
	await settle(225, 280)
	for i in 180:
		if game.can.facing > 0 and (game.can.state == "charging" or (game.can.state == "windup" and game.can.intent_locked)): break
		await step()
	await leap(225, 248)
	for i in 180:
		if game.machines.rotator.occupied and game.can.state in ["recover", "idle"]: break
		await step(direction(225))
	if game.stats.boulder_impacts != 0: fail("prepared plan must retain initial Boulder cover")
	if not game.machines.rotator.occupied: fail("right charge parks Can on rotor")
	await withdraw_right()

func withdraw_right() -> void:
	if not failures.is_empty(): return
	var rotor: Node2D = game.machines.rotator
	var goal: float = (game.machines.sensor.position - rotor.beam_origin()).angle()
	# Travel from the observation shelf to the low right bait also takes time.
	# Begin before the useful state; this is a broad planning margin, not a
	# center-angle reaction or a frame-perfect input.
	for i in 400:
		if rotor.angle <= goal + deg_to_rad(departure_lead_degrees): break
		await step()
	await walk(397)
	for i in 240:
		if not rotor.occupied and game.machines.sensor.active and not game.machines.fan.flow_blocked: break
		await step(direction(397), dodge())
	if not game.machines.sensor.active: fail("early right withdrawal retains optical crossing")
	if game.machines.fan.flow_blocked: fail("withdrawal also clears nozzle")
	if expert and game.stats.boulder_impacts != 1: fail("one withdrawal combines Boulder displacement and freeze")

func live_capture() -> void:
	if frame < 10: await capture("L%d_start" % (game.level_index + 1))
	if game.machines.has("laser"):
		if game.machines.laser.covered_by_heavy: await capture("L2_cover")
		if game.machines.laser.exposure_time > 0: await capture("L2_cover_spent")
	if game.level_index == 3 and game.machines.rotator.occupied and game.stats.boulder_impacts == 0:
		await capture("L4_retained_cover_setup")
	if game.level_index == 3 and not game.machines.rotator.occupied and game.stats.boulder_impacts == 1 and game.machines.sensor.active:
		await capture("L4_combined_withdrawal")
	await super.live_capture()
