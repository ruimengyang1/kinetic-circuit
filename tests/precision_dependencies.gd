extends "res://tests/precision_audit.gd"

# Explicit counterfactual world fixtures, not completion demonstrations.
# Give later machinery its useful state and verify the preceding state still
# has a physical purpose. No arbitrary puzzle prerequisite is consulted.
func hold_can(x: float) -> void:
	game.can.position = Vector2(x, 305.9)
	game.can.state = "recover"
	game.can.state_time = 1000

func set_beam(receiver: String) -> void:
	game.machines.rotator.angle = (game.machines[receiver].position - game.machines.rotator.beam_origin()).angle()

func shallow_right(count: int = 900) -> void:
	for f in count:
		await step(1, f % 43 < 23)
		if not game.completed.is_empty(): break

func run() -> void:
	await spawn(1)
	hold_can(272)
	game.platforms.shutter.set_power(true)
	await shallow_right()
	check(game.completed.is_empty(), "L2 final parked crossing cannot replace boarding setup")
	cases.append({"case": "L2 crossing-only", "controlled_fixture": true, "completed": not game.completed.is_empty()})
	for index in [2, 3]:
		await spawn(index)
		hold_can(90 if index == 2 else 418)
		set_beam("sensor")
		if index == 3: game.platforms.shutter.set_power(true)
		for f in 160: await step()
		check(game.machines.sensor.illuminated and not game.machines.boarding_sensor.illuminated, "L%d final beam excludes boarding beam" % (index + 1))
		await shallow_right()
		check(game.completed.is_empty(), "L%d final beam cannot replace acquired boarding height" % (index + 1))
		cases.append({"case": "L%d final-beam-only" % (index + 1), "controlled_fixture": true, "completed": not game.completed.is_empty()})
		await spawn(index)
		hold_can(90 if index == 2 else 24.1)
		set_beam("boarding_sensor")
		if index == 3: game.platforms.shutter.set_power(true)
		game.player.position = Vector2(400, 205)
		game.player.previous_position = game.player.position
		game.player.previous_feet = 214
		await shallow_right()
		check(game.completed.is_empty(), "L%d boarding height alone cannot replace final beam" % (index + 1))
	# Deliberately grant the crossing and shutter, but leave Can at the wrong
	# final endpoint. The same physical exit lift must remain low.
	await spawn(3)
	hold_can(24.1)
	set_beam("sensor")
	game.platforms.shutter.set_power(true)
	for f in 160: await step()
	game.player.position = Vector2(553, 171)
	game.player.previous_position = game.player.position
	game.player.previous_feet = 180
	await shallow_right(360)
	check(game.completed.is_empty() and not game.machines.exit_button.active, "L4 wrong final endpoint fails even with crossing and gate ready")
	cases.append({"case": "L4 wrong final endpoint", "controlled_fixture": true, "completed": not game.completed.is_empty(), "exit_weight": game.machines.exit_button.active})
	DirAccess.make_dir_recursive_absolute(output_dir)
	var file := FileAccess.open(output_dir + "/dependencies.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"counterfactual_fixtures": true, "cases": cases, "failures": failures}, "\t"))
	game.free()
	quit(0 if failures.is_empty() else 1)
