extends "res://tests/progression_route.gd"

# Authored feasibility probes. Human feedback, not these scripts, decides
# whether the choice is noticed and learned during normal play.
func _initialize() -> void:
	evidence_directory = "res://artifacts/level_progression/revision2"
	departure_lead_degrees = 28
	call_deferred("run")

func weight() -> void:
	if expert:
		await walk(460)
		await settle(460, 318)
		for i in 160:
			if game.platforms.shutter.powered: break
			await step(direction(460), dodge())
		if not game.platforms.shutter.powered: fail("covered ground route requires rightward shutter force")
		if game.stats.boulder_impacts != 0: fail("covered route preserves Boulder")
		await walk(519)
		await leap(563, 286)
	else:
		await walk(330)
		for i in 220:
			if game.stats.boulder_impacts > 0: break
			await step(direction(330), dodge())
		if game.stats.boulder_impacts == 0: fail("upper route requires leftward Boulder force")
		await walk(300)
		for i in 240:
			if game.player.position.y < 162: break
			await step(direction(300))
		await walk(380)
		await settle(380, 180)
		await leap(475, 180)
		await walk(550)
	await walk(616)

func park_before_boulder() -> void:
	await walk(145)
	await settle(145, 318)
	await leap(215, 280)
	await leap(215, 248)
	for i in 180:
		if game.machines.rotator.occupied and game.can.state in ["recover", "idle"]: break
		await step(direction(215))
	if game.stats.boulder_impacts != 0: fail("entry charge parks before Boulder")
	if not game.machines.rotator.occupied: fail("entry charge must visibly hold the rotor")
	if capture_run: await capture("L4_shared_choice")

func combine() -> void:
	await park_before_boulder()
	if expert:
		await align_and_open()
	else:
		await walk(399)
		for i in 180:
			if game.stats.boulder_impacts > 0: break
			await step(direction(399), dodge())
		if game.machines.sensor.active: fail("early clearance must leave crossing unprepared")
		await air_to_observation()
		if capture_run: await capture("L4_early_air_gap")
		# The early route buys a high observation position, but Can is now away
		# from control. Return it, rather than treating open airflow as victory.
		await walk(215)
		await settle(215, 280)
		await leap(215, 248)
		for i in 200:
			if game.machines.rotator.occupied and game.can.state in ["idle", "recover"]: break
			await step(direction(215))
		if not game.machines.rotator.occupied: fail("clear-first return must restore beam control")
		await align_and_open()
	if game.player.position.y > 235:
		await air_to_observation()
	for i in 180:
		if game.platforms.crossing.position.x >= 500: break
		await step()
	await walk(530)
	await settle(530, 222)
	await walk(549)
	await leap(601, 214)
	await walk(616)

func align_and_open() -> void:
	var rotor: Node2D = game.machines.rotator
	var target: float = (game.machines.sensor.position - rotor.beam_origin()).angle()
	for i in 450:
		if rotor.rotation_rate < 0 and rotor.angle <= target + deg_to_rad(departure_lead_degrees): break
		await step()
	await walk(399)
	for i in 180:
		if not rotor.occupied and game.machines.sensor.active and not game.machines.fan.flow_blocked: return
		await step(direction(399), dodge())
	fail("alignment plus open air; stopped angle %.1f" % rad_to_deg(rotor.angle))

func air_to_observation() -> void:
	await walk(340)
	for i in 180:
		if game.player.position.y < 219 and game.player.velocity.y < -180: break
		await step(direction(340))
	await walk(410)
	await settle(410, 196)

func live_capture() -> void:
	# Per-room time, not global frame/capture count: transitions must produce
	# a fresh rendered start too. capture() deduplicates the prefixed name.
	if game.mode == "play" and game.level_time >= 0.1: await capture("L%d_start" % (game.level_index + 1))
	if game.level_index == 1:
		if game.platforms.shutter.powered and game.platforms.shutter.position.y <= 146: await capture("L2_preserved_ground")
		if game.stats.boulder_impacts > 0 and absf(game.boulder.velocity.x) < 1 and not game.machines.fan.flow_blocked: await capture("L2_cover_spent_air_open")
	if game.level_index == 3:
		if game.machines.rotator.beam_hit == game.boulder: await capture("L4_initial_cover")
		if game.machines.rotator.occupied and game.stats.boulder_impacts == 0: await capture("L4_preserved_state")
		if game.machines.sensor.active and not game.machines.fan.flow_blocked and game.platforms.crossing.position.x > 500: await capture("L4_ready_crossing")
	if game.mode in ["clear", "complete"]: await capture("L%d_exit" % (game.level_index + 1))
