extends SceneTree
var game: Node2D
var failures: Array[String] = []
var checks: Array[String] = []
func _initialize() -> void: call_deferred("run")
func tick(count: int = 1) -> void:
	for i in count: await physics_frame
func spawn(index: int) -> void:
	if game != null: game.free()
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = index
	game.hit_pause_enabled = false # isolate fixtures from presentation pause
	root.add_child(game)
	await tick(5)
	game.player.active = false
	game.can.suspended = true
func check(value: bool, label: String) -> void:
	checks.append(label)
	if not value: failures.append(label)
	print("PASS " if value else "FAIL ", label)
func run() -> void:
	await spawn(0)
	game.player.position = Vector2(200, 309)
	game.can.cooldown = 0
	game.can.suspended = false
	await tick(3)
	check(game.can.state == "windup", "A telegraph precedes charge")
	await tick(15)
	check(game.can.intent_locked and game.can.facing == 1, "B visible direction locks")
	game.player.position.x = 30
	await tick(20)
	check(game.can.state == "charging" and game.can.facing == 1 and game.can.velocity.x > 200, "C moving after lock cannot redirect charge")
	await tick(45)
	check(game.platforms.shutter.powered and game.stats.impacts > 0, "D signed force operates a generic physical receiver")
	await spawn(0)
	game.can.position = Vector2(160, 306)
	game.can.state = "charging"
	game.can.state_time = 1
	game.can.facing = 1
	game.can.suspended = false
	game.player.position = Vector2(169, 273)
	game.player.velocity = Vector2(0, 170)
	game.player.active = true
	await tick(4)
	print("bounce fixture ", game.stats.rebounds, " velocity ", game.player.velocity)
	check(game.stats.rebounds == 1 and game.player.velocity.y < -250 and game.player.health == 3, "E generous actual falling rebound is consistent")
	check(game.can.state == "charging" and game.can.position.x > 160, "E rebound preserves committed Can motion")
	game.player.active = false
	game.can.state = "idle"
	game.can.receive_kinetic_strike(0)
	await tick(28)
	check(game.can.state != "stagger", "normal stomp reuses Can within half a second")
	await spawn(1)
	game.can.position = Vector2(170, 306)
	game.can.state = "charging"
	game.can.facing = 1
	game.can.state_time = 1.1
	game.can.suspended = false
	await tick(65)
	check(game.boulder.position.x > 300 and game.stats.boulder_impacts == 1, "F one committed force rolls Boulder without repeated impulses")
	check(absf(game.boulder.position.x - 319) < 12 and absf(game.boulder.velocity.x) < 1, "G deterministic Boulder settling position")
	check(game.machines.button.active and game.machines.button.mass >= 3, "H Boulder physically holds weight switch")
	check(game.machines.fan.active and game.platforms.shuttle.powered, "I one visible pressure circuit powers Fan and linked sweep")
	game.player.position = Vector2(409, 309)
	game.player.velocity = Vector2.ZERO
	game.player.active = true
	await tick(27)
	check(game.player.position.y < 275 and game.player.velocity.y < -100, "J Fan applies real readable upward force")
	game.player.active = false
	game.boulder.receive_impact(-230)
	await tick(65)
	check(not game.machines.button.active and not game.machines.fan.active, "K pressure and Fan deactivate when weight leaves")
	await spawn(2)
	game.can.position = Vector2(355, 306)
	game.can.move_and_slide()
	await tick(5)
	var angle: float = game.machines.rotator.angle
	await tick(30)
	check(game.machines.rotator.occupied and absf(game.machines.rotator.angle - angle - deg_to_rad(14)) < 0.03, "L sustained physical weight rotates continuously at fixed rate")
	game.can.position.x = 260
	await tick(3)
	angle = game.machines.rotator.angle
	await tick(30)
	check(not game.machines.rotator.occupied and is_equal_approx(game.machines.rotator.angle, angle), "M leaving freezes actual angle without snap or completion flag")
	game.machines.rotator.angle = (game.machines.sensor.position - game.machines.rotator.beam_origin()).angle()
	await tick(10)
	check(game.machines.sensor.active, "N ray physically contacts optical sensor")
	await tick(50)
	check(game.platforms.crossing.position.is_equal_approx(Vector2(521, 227)), "O sensor moves platform quickly to visible destination")
	game.machines.rotator.angle = deg_to_rad(-115)
	await tick(50)
	check(not game.machines.sensor.active and game.platforms.crossing.position.is_equal_approx(game.platforms.crossing.home), "optical mechanism follows beam contact continuously")
	await spawn(3)
	game.player.position = Vector2(605, 300)
	game.can.position = Vector2(281, 306)
	game.can.move_and_slide()
	await tick(5)
	game.can.suspended = false
	game.can.cooldown = 3
	# Player location makes search right, so hold the actor physically on the
	# lift using ordinary floor motion; no lift-specific Can AI is installed.
	game.player.position = Vector2(281, 150)
	game.machines.rotator.angle = (game.machines.sensor.position - game.machines.rotator.beam_origin()).angle()
	await tick(2)
	game.machines.rotator.suspended = true
	game.machines.rotator._update_beam()
	await tick(55)
	print("FIXTURE ", game.can.position, " beam hit ", game.machines.rotator.beam_hit, " at ", game.machines.rotator.beam_end, " sensor ", game.machines.sensor.active, " lift ", game.platforms.can_lift.position)
	check(game.can.position.y < 275 and game.can.is_on_floor(), "L4 powered platform physically carries Can into upper environment")
	check(game.platforms.crossing.powered and game.platforms.can_lift.powered, "L4 same sensor has two visible consequences")
	# Heavy/blocking are general physical properties, not Boulder identity tests.
	game.boulder.position = Vector2(400, 173.5)
	game.boulder.suspended = true
	await tick(2)
	game.machines.rotator._update_beam()
	check(game.machines.rotator.beam_hit == game.boulder and not game.machines.sensor.active, "Boulder is generic optical cover as well as weight")
	game.boulder.position = Vector2(342, 302)
	game.boulder.suspended = false
	await tick(8)
	check(game.machines.button.active, "L4 identical force/weight/Fan rule, no new mechanic")
	# Deliberately wrong laser aim never activates a hidden progress flag.
	game.machines.rotator.angle = deg_to_rad(-115)
	game.machines.rotator._update_beam()
	check(not game.machines.sensor.active, "visible world rules determine sensor state")
	game.free()
	var file := FileAccess.open("res://artifacts/final_demo/systems.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks": checks, "failures": failures}, "\t"))
	file.close()
	print("FINAL SYSTEMS ", checks.size(), " checks; failures ", failures)
	quit(0 if failures.is_empty() else 1)
