extends "res://tests/rebalance_systems.gd"

# Controlled fixtures are separate from the input-only route evidence.
var states: Array[Dictionary] = []

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/strategic_depth")
	# The same stable acquisition, lock, charge and recovery in every room.
	for index in 4:
		await spawn(index)
		game.can.position = Vector2(100, 306)
		game.can.state = "idle"
		game.can.cooldown = 0
		game.can.suspended = false
		game.player.position = Vector2(180, 309)
		await tick(3)
		check(game.can.state == "windup" and not game.can.intent_locked, "L%d tracking preview before lock" % (index + 1))
		await tick(14)
		check(game.can.intent_locked and game.can.facing == 1, "L%d stable position-selected lock" % (index + 1))
		game.player.position = Vector2(46, 180)
		await tick(23)
		check(game.can.state == "charging" and game.can.facing == 1 and game.can.velocity.x > 200, "L%d later position cannot redirect committed charge" % (index + 1))
		game.can.position.x = game.can.rail_left
		game.can.facing = -1
		await tick()
		check(game.can.state == "recover", "L%d impact uses shared recovery" % (index + 1))
		await tick(14)
		check(game.can.state == "idle", "L%d recovery has no added delay" % (index + 1))

	# Same setup, same settled position. No dice, physics jitter or identity gates.
	var endpoints: Array[float] = []
	for repetition in 3:
		await spawn(1)
		game.player.position = Vector2(594, 100)
		game.boulder.suspended = false
		game.boulder.receive_impact(-230)
		await tick(75)
		endpoints.append(game.boulder.position.x)
	check(absf(endpoints.max() - endpoints.min()) < 0.01, "repeated signed force has deterministic endpoints")
	check(endpoints[0] < 230, "left force leaves Boulder left of both nozzle and emitter")

	# A real Can impact trades two useful states, without a button circuit.
	for prepared in [false, true]:
		await spawn(1)
		var emitter: Node2D = game.machines.laser
		emitter.suspended = false
		game.machines.fan.suspended = false
		await tick(3)
		check(emitter.beam_hit == game.boulder and game.machines.fan.flow_blocked, "L2 initial Boulder is physical beam cover and nozzle obstruction")
		check(not game.machines.has("button") and not game.platforms.has("duct"), "L2 relationships require no object-to-key circuit")
		game.player.position = Vector2(407, 271 if prepared else 309)
		game.player.active = true
		game.player.set_physics_process(false)
		game.can.position = Vector2(380, 306)
		game.can.state = "charging"
		game.can.state_time = 1.1
		game.can.facing = -1
		game.can.suspended = false
		game.boulder.suspended = false
		await tick(28)
		check(game.stats.boulder_impacts == 1 and not game.machines.fan.flow_blocked, "L2 moving cover opens the running airflow")
		check(emitter.exposure_time > 0 and game.player.health == 3, "L2 exposed beam warns before harming the lower approach")
		await tick(55)
		check(game.player.health == (3 if prepared else 2), "L2 preparation changes damage outcome without faster input")
		states.append({"level": 2, "prepared": prepared, "health": game.player.health, "can": game.can.position, "boulder": game.boulder.position})

	# Actual collision rays, not mathematical tolerance labels.
	for index in [2, 3]:
		await spawn(index)
		game.boulder.position.x = 590
		game.player.position = Vector2(46, 100)
		await tick(3)
		var rotor: Node2D = game.machines.rotator
		var hits: Array[float] = []
		for i in range(-240, 281):
			rotor.angle = deg_to_rad(i * 0.25)
			rotor._update_beam()
			if game.machines.sensor.illuminated: hits.append(i * 0.25)
		var width: float = hits.back() - hits.front() if not hits.is_empty() else 0.0
		windows.append({"level": index + 1, "minimum_degrees": hits.front() if not hits.is_empty() else 0, "maximum_degrees": hits.back() if not hits.is_empty() else 0, "width_degrees": width, "seconds_at_rate": width / absf(rad_to_deg(rotor.rotation_rate))})
		check(width >= 26, "L%d optical window remains broad after real geometry occlusion" % (index + 1))
		print("WINDOW ", windows.back())

	# Wide early-start range, but a center-angle reaction is genuinely too late.
	for lead in [-2.0, 0.0, 8.0, 12.0, 18.0, 24.0, 28.0]:
		await spawn(2)
		game.boulder.position = Vector2(429, 302)
		game.player.position = Vector2(351, 272)
		game.player.velocity = Vector2.ZERO
		game.player.active = true
		game.can.position = Vector2(355, 306)
		game.can.velocity.y = 10
		game.can.move_and_slide()
		game.can.cooldown = 0
		game.can.suspended = false
		game.machines.rotator.suspended = false
		game.machines.sensor.suspended = false
		game.platforms.crossing.suspended = false
		var goal: float = (game.machines.sensor.position - game.machines.rotator.beam_origin()).angle()
		for i in 300:
			if game.machines.rotator.angle >= goal - deg_to_rad(lead): break
			await tick()
		Input.action_press("move_left")
		for i in 150:
			if game.player.position.x < 303: Input.action_release("move_left")
			await tick()
			if not game.machines.rotator.occupied: break
		Input.action_release("move_left")
		await tick(35)
		withdrawals.append({"lead_degrees": lead, "stopped_degrees": rad_to_deg(game.machines.rotator.angle), "sustained": game.machines.sensor.active})
		check(game.machines.sensor.active if lead >= 8 else not game.machines.sensor.active, "L3 lead %.0f exposes delay with forgiving early starts" % lead)

	await spawn(3)
	game.machines.rotator.suspended = false
	game.machines.fan.suspended = false
	await tick(3)
	check(game.machines.rotator.beam_hit == game.boulder and game.machines.fan.flow_blocked, "L4 retains the physical cover/nozzle relationship learned in L2")
	check(not game.platforms.has("can_lift") and game.machines.sensor.targets.size() == 1, "L4 does not solve withdrawal with an automatic new linkage")
	game.player.position = Vector2(225, 239)
	game.can.position = Vector2(284, 306)
	game.can.velocity.y = 10
	game.can.move_and_slide()
	game.machines.rotator.angle = deg_to_rad(4)
	await tick(3)
	var before: float = game.machines.rotator.angle
	await tick(20)
	check(game.machines.rotator.occupied and game.machines.rotator.angle < before, "L4 kept Can availability continuously changes future beam state")
	game.can.position.x = 325
	await tick(3)
	before = game.machines.rotator.angle
	await tick(20)
	check(not game.machines.rotator.occupied and is_equal_approx(before, game.machines.rotator.angle), "L4 spending Can position freezes actual angle without a solved flag")
	var file := FileAccess.open("res://artifacts/strategic_depth/systems.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"controlled_fixtures": true, "checks": checks, "failures": failures, "windows": windows, "withdrawals": withdrawals, "states": states, "deterministic_endpoints": endpoints}, "\t"))
	game.free()
	print("STRATEGIC SYSTEMS ", checks.size(), " checks; failures ", failures)
	quit(0 if failures.is_empty() else 1)
