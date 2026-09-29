extends SceneTree

var game: Node2D
var failures: Array[String] = []
var checks: Array[String] = []
var windows: Array[Dictionary] = []
var withdrawals: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func tick(count: int = 1) -> void:
	for i in count:
		await process_frame
		await physics_frame
func spawn(index: int) -> void:
	if game != null: game.free()
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = index
	game.hit_pause_enabled = false
	root.add_child(game)
	await tick(4)
	game._freeze(true)

func check(value: bool, label: String) -> void:
	checks.append(label)
	if not value: failures.append(label)
	print("PASS " if value else "FAIL ", label)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/rebalance")
	await spawn(0)
	game.player.position = Vector2(280, 309)
	game.can.cooldown = 0
	game.can.suspended = false
	await tick(3)
	check(game.can.state == "windup", "Can anticipates before committing")
	await tick(15)
	check(game.can.intent_locked and game.can.facing == 1, "position chooses a visible locked direction")
	game.player.position.x = 46
	await tick(22)
	check(game.can.state == "charging" and game.can.facing == 1 and game.can.velocity.x > 200, "crossing after lock preserves intent and maximum speed")
	game.platforms.shutter.suspended = false
	await tick(45)
	check(game.platforms.shutter.powered, "signed Can force operates the room shutter")

	await spawn(1)
	game.boulder.suspended = false
	game.boulder.position = Vector2(180, 302)
	game.boulder.receive_impact(-230)
	await tick(65)
	check(game.boulder.position.x < 80 and absf(game.boulder.velocity.x) < 1, "opposite signed force produces a different settled position")
	await spawn(1)
	check(game.machines.fan.active and game.machines.fan.flow_blocked, "initial solid duct panel seals the running nozzle")
	game.player.position = Vector2(46, 100)
	game.can.position = Vector2(470, 306)
	game.can.state = "charging"
	game.can.state_time = 1.1
	game.can.facing = -1
	game.can.suspended = false
	game.boulder.suspended = false
	game.platforms.duct.suspended = false
	game.machines.fan.suspended = false
	await tick(100)
	check(game.stats.boulder_impacts == 1 and game.platforms.duct.powered, "one Can impact chains through Boulder to a physical duct panel")
	check(game.boulder.position.x > 225 and game.boulder.position.x < 265 and absf(game.boulder.velocity.x) < 1, "panel motion and rolling leave Boulder at the nozzle")
	check(game.machines.fan.active and game.machines.fan.flow_blocked, "opening duct also obstructs its already-running airflow")
	check(not game.machines.has("button"), "Momentum room has no pressure-to-Fan key circuit")
	game.can.suspended = true
	game.boulder.receive_impact(-230)
	await tick(75)
	check(game.machines.fan.active and not game.machines.fan.flow_blocked, "second signed force clears airflow without toggling Fan power")
	game.player.position = Vector2(244, 309)
	game.player.velocity = Vector2.ZERO
	game.player.active = true
	await tick(25)
	check(game.player.position.y < 280 and game.player.velocity.y < -100, "exposed air physically lifts Player")
	check(game.machines.fan.flow_top > 140, "solid catwalk clips the visible and effective air column")

	await spawn(2)
	game.can.position = Vector2(355, 306)
	game.can.velocity.y = 10
	game.can.move_and_slide()
	game.machines.rotator.suspended = false
	await tick(3)
	var before: float = game.machines.rotator.angle
	await tick(30)
	check(game.machines.rotator.occupied and absf(game.machines.rotator.angle - before - deg_to_rad(9)) < 0.01, "supported occupancy continuously rotates at readable 18 degrees/second")
	game.can.position.x = 260
	await tick(3)
	before = game.machines.rotator.angle
	await tick(25)
	check(not game.machines.rotator.occupied and is_equal_approx(before, game.machines.rotator.angle), "leaving freezes actual angle without snapping")

	for index in [2, 3]:
		await spawn(index)
		game.boulder.position.x = 590
		game.player.position = Vector2(46, 100)
		await tick(3)
		var rotor: Node2D = game.machines.rotator
		var hits: Array[float] = []
		for i in range(-240, 161):
			rotor.angle = deg_to_rad(i * 0.25)
			rotor._update_beam()
			if game.machines.sensor.illuminated: hits.append(i * 0.25)
		var width: float = hits.back() - hits.front() if not hits.is_empty() else 0.0
		var rate := absf(rad_to_deg(rotor.rotation_rate))
		windows.append({"level": index + 1, "minimum_degrees": hits.front() if not hits.is_empty() else 0, "maximum_degrees": hits.back() if not hits.is_empty() else 0,
			"width_degrees": width, "seconds_at_rate": width / rate})
		check(width > (24 if index == 2 else 14), "L%d actual unoccluded optical window has generous margins" % (index + 1))
		print("WINDOW ", windows.back())

	# Input withdrawal follows controlled starting fixtures. A deliberately
	# late plan should fail; many earlier start times should hold the route.
	for lead in [-2.0, 10.0, 14.0, 18.0, 22.0, 26.0]:
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
		var target: float = (game.machines.sensor.position - game.machines.rotator.beam_origin()).angle()
		for i in 300:
			if game.machines.rotator.angle >= target - deg_to_rad(lead): break
			await tick()
		Input.action_press("move_left")
		for i in 150:
			if game.player.position.x < 303: Input.action_release("move_left")
			await tick()
			if not game.machines.rotator.occupied: break
		Input.action_release("move_left")
		await tick(35)
		withdrawals.append({"lead_degrees": lead, "stopped_degrees": rad_to_deg(game.machines.rotator.angle), "sustained": game.machines.sensor.active})
		check(game.machines.sensor.active if lead > 0 else not game.machines.sensor.active, "withdrawal lead %.0f gives expected planning outcome" % lead)

	await spawn(3)
	game.machines.rotator.suspended = false
	game.machines.fan.suspended = false
	game.machines.rotator.angle = deg_to_rad(2.4)
	await tick(3)
	check(game.machines.rotator.beam_hit == game.boulder and game.machines.fan.flow_blocked, "fresh final Boulder is actual optical cover and airflow obstruction")
	game.player.position = Vector2(400, 294)
	game.player.active = true
	game.player.set_physics_process(false)
	await tick(3)
	check(game.player.health == 3, "visible Boulder protects the later beam lane")
	game.boulder.suspended = false
	game.boulder.receive_impact(230)
	await tick(22)
	check(game.player.health == 3 and game.machines.rotator.exposure_time > 0, "moving cover gives readable confirmation before beam damage")
	await tick(60)
	check(game.player.health == 2, "player-caused cover movement exposes old danger and causes recoverable failure")
	check(not game.machines.fan.flow_blocked, "same movement also opens airflow")

	await spawn(3)
	game.player.position = Vector2(225, 271)
	game.player.active = true
	game.player.set_physics_process(false)
	game.machines.rotator.suspended = false
	game.machines.fan.suspended = false
	game.machines.rotator.angle = deg_to_rad(2.4)
	game.boulder.suspended = false
	game.boulder.receive_impact(230)
	await tick(90)
	check(game.player.health == 3, "preparing a safe position removes the reversal's execution demand")

	await spawn(3)
	game.boulder.position.x = 590
	game.player.position = Vector2(46, 100)
	game.can.position = Vector2(281, 306)
	game.can.velocity.y = 10
	game.can.move_and_slide()
	game.can.suspended = false
	game.can.cooldown = 5
	game.machines.rotator.angle = deg_to_rad(-24)
	# Isolate the physical sensor/carry relationship, not a full solution.
	game.machines.sensor.suspended = false
	game.platforms.can_lift.suspended = false
	game.platforms.crossing.suspended = false
	game.machines.rotator._update_beam()
	for i in 30:
		game.machines.rotator._update_beam()
		await tick()
	check(game.platforms.can_lift.warning_time > 0 and game.can.position.y > 300, "successful alignment confirms for 0.55 seconds before lifting Can")
	# Feed actual beam samples while the moving deck briefly crosses it.
	for i in 75:
		game.machines.rotator._update_beam()
		await tick()
	check(game.can.position.y < 245 and game.can.is_on_floor(), "same physical support carries Can into its new reachable lane")
	check(game.machines.sensor.active and game.stats.sensor_activations == 1, "heat coast prevents the moving lift chattering its own beam circuit")
	game.machines.rotator.angle = deg_to_rad(8)
	game.machines.rotator._update_beam()
	await tick(20)
	check(not game.machines.sensor.active, "wrong angle cools the winch quickly instead of latching completion")

	var file := FileAccess.open("res://artifacts/rebalance/systems.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"controlled_fixtures": true, "checks": checks, "windows": windows, "withdrawals": withdrawals, "failures": failures}, "\t"))
	game.free()
	Input.action_release("move_left")
	print("REBALANCE SYSTEMS ", checks.size(), " checks; failures ", failures)
	quit(0 if failures.is_empty() else 1)
