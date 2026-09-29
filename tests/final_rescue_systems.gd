extends "res://tests/precision_systems.gd"

func run() -> void:
	output_dir = "res://artifacts/final_rescue"
	await super.run()

func extra_checks() -> void:
	var trials: Array[Dictionary] = []
	for setup in [[2, 338.0], [3, 272.1], [3, 170.1]]:
		for side in [-1, 1]:
			await spawn(false, setup[0])
			game.hit_pause_enabled = false
			game.can.position = Vector2(setup[1], 305.9)
			game.can.state = "idle"
			game.can.facing = -side
			game.can.cooldown = 0
			game.player.position = Vector2(setup[1] + side * 60, 309)
			game.player.active = false
			game.can.suspended = false
			await tick(3)
			var rotor: Node2D = game.machines.rotator
			var pedal := Rect2(rotor.position + rotor.rect.position, rotor.rect.size)
			var untouched_facing: int = game.can.facing
			var end: float = game.can.predicted_endpoint(side)
			var delay: float = game.can.withdrawal_delay(pedal, side)
			check(game.can.facing == untouched_facing and game.can.state == "idle", "prospective query never changes intent L%d x%.0f side%d" % [setup[0] + 1, setup[1], side])
			game.can.facing = side
			game.can.state = "windup"
			game.can.state_time = game.can.ANTICIPATION
			rotor.suspended = false
			rotor.angle = deg_to_rad(0)
			rotor.rotation_rate = deg_to_rad(14)
			await tick()
			var chosen: float = rotor.stop_previews.get(side, INF)
			var occupied_frames := 1
			for i in 130:
				await tick()
				if not rotor.occupied: break
				occupied_frames += 1
			check(absf(occupied_frames / 60.0 - delay) < 0.04, "preview delay matches actual pedal clearance L%d x%.0f side%d" % [setup[0] + 1, setup[1], side])
			check(absf(angle_difference(chosen, rotor.angle)) < deg_to_rad(0.6), "directional ghost matches actual stop angle L%d x%.0f side%d" % [setup[0] + 1, setup[1], side])
			await tick(90)
			check(absf(game.can.position.x - end) < 0.3, "prospective endpoint matches actual collision L%d x%.0f side%d" % [setup[0] + 1, setup[1], side])
			trials.append({"level": setup[0] + 1, "origin": setup[1], "direction": side, "preview_delay": delay, "measured_delay": occupied_frames / 60.0, "preview_endpoint": end, "endpoint": game.can.position.x})
	measurements.directional_previews = trials
