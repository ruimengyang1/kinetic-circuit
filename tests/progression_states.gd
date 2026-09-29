extends "res://tests/rebalance_systems.gd"

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/level_progression/revision2/checks")
	for index in 4:
		await spawn(index)
		check((game.boulder != null) == (index in [1, 3]), "L%d Boulder only where cover and airflow trade off" % (index + 1))
		if game.boulder != null:
			var laser: Node2D = game.machines.get("laser", game.machines.get("rotator"))
			laser.suspended = false
			game.machines.fan.suspended = false
			await tick(3)
			check(laser.beam_hit == game.boulder and game.machines.fan.flow_blocked, "L%d initial Boulder has two physical jobs" % (index + 1))

	# Same optical state, two exits: endpoints differ; neither is a solved flag.
	for side in [-1, 1]:
		await spawn(2)
		game.can.position = Vector2(355, 306)
		game.can.velocity.y = 10
		game.can.move_and_slide()
		game.can.suspended = false
		game.can.cooldown = 0
		game.machines.rotator.suspended = false
		game.machines.sensor.suspended = false
		game.machines.rotator.angle = deg_to_rad(-12)
		game.player.position = Vector2(297 if side < 0 else 403, 277)
		game.player.set_physics_process(false)
		await tick(20)
		check(game.can.intent_locked and game.can.facing == side, "L3 withdrawal position locks selected side %d" % side)
		# Withdraw above the acquisition lane after lock to preserve the endpoint.
		game.player.position.y = 220
		await tick(110)
		check(not game.machines.rotator.occupied and game.machines.sensor.active, "L3 both withdrawal sides can preserve useful angle %d" % side)
		check(game.can.position.x < 150 if side < 0 else is_equal_approx(game.can.position.x, 429), "L3 withdrawal side changes future Can availability %d" % side)
		var angle: float = game.machines.rotator.angle
		await tick(30)
		check(is_equal_approx(angle, game.machines.rotator.angle), "L3 height preserves persistent angle %d" % side)
		if side > 0:
			game.player.position = Vector2(297, 277)
			await tick(70)
			check(not is_equal_approx(angle, game.machines.rotator.angle) and game.rotor_visits >= 2, "L3 careless low return spends angle and recreates rotor occupancy")
			check(game.metrics().rotor_state_recreations >= 1, "state recreation is recorded rather than hidden by a completion latch")
	var file := FileAccess.open("res://artifacts/level_progression/revision2/checks/states.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"controlled_fixtures": true, "checks": checks, "failures": failures}, "\t"))
	game.free()
	print("PROGRESSION STATES ", checks.size(), " checks; failures ", failures)
	quit(0 if failures.is_empty() else 1)
