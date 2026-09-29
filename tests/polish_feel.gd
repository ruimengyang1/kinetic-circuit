extends SceneTree

# Focused regression fixtures for actual input edges and physical consequences.
var game: Node2D
var failures: Array[String] = []
var checks: Array[String] = []
var measurements: Dictionary = {}
func _initialize() -> void: call_deferred("run")
func tick(count: int = 1) -> void:
	for i in count:
		await physics_frame
		await process_frame
func check(value: bool, label: String) -> void:
	checks.append(label)
	if not value: failures.append(label)
	print("PASS " if value else "FAIL ", label)
func spawn(index: int = 0) -> void:
	if game != null: game.free()
	for action in ["move_left", "move_right", "jump", "attack", "restart"]:
		if InputMap.has_action(action): Input.action_release(action)
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = index
	root.add_child(game)
	await tick(3)
	game._freeze(true)
	game.player.active = true
	game.player.position = Vector2(150, 309)
	game.player.velocity = Vector2.ZERO
	await tick(3)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/polish")
	await spawn()
	Input.action_press("move_right")
	await tick(6)
	check(game.player.velocity.x > 150, "ground movement reaches full useful speed within 100 ms")
	Input.action_release("move_right")
	Input.action_press("move_left")
	await tick(6)
	check(game.player.velocity.x < 0, "direction reverses within 100 ms")
	await tick(6)
	Input.action_release("move_left")
	var stop_x: float = game.player.position.x
	await tick(6)
	measurements.stop_distance = absf(game.player.position.x - stop_x)
	check(absf(game.player.velocity.x) < 1 and measurements.stop_distance < 8, "ground braking stops without a slippery tail")

	await spawn()
	var jumps := {"count": 0}
	game.player.jumped.connect(func(_at: Vector2) -> void: jumps.count += 1)
	game.player.position = Vector2(300, 285)
	game.player.velocity = Vector2(0, 180)
	game.player.coyote_time = 0
	await tick()
	game.player.coyote_time = 0
	Input.action_press("jump")
	await tick()
	check(game.player.jump_buffer_time > 0 and game.player.velocity.y > 0, "jump press before landing remains buffered")
	for i in 10:
		await tick()
		if jumps.count > 0: break
	check(jumps.count == 1 and game.player.velocity.y < -200, "prelanding input launches on contact without a landing lockout")
	await tick(4)
	check(jumps.count == 1, "held buffered jump is consumed once")
	Input.action_release("jump")
	await tick()
	check(game.player.velocity.y > -120, "jump release makes a shorter readable arc")

	await spawn()
	# Physically leave the end of the upper one-way catwalk.
	game.player.position = Vector2(147, 211)
	game.player.velocity = Vector2.ZERO
	await tick(3)
	Input.action_press("move_left")
	for i in 12:
		await tick()
		if not game.player.is_on_floor(): break
	await tick(3)
	Input.action_press("jump")
	await tick()
	check(game.player.velocity.y < -200, "late ledge jump uses the real coyote window")
	await spawn()
	game.player.position = Vector2(147, 211)
	game.player.velocity = Vector2.ZERO
	await tick(3)
	Input.action_press("move_left")
	for i in 12:
		await tick()
		if not game.player.is_on_floor(): break
	await tick(8)
	Input.action_press("jump")
	await tick()
	check(game.player.velocity.y >= 0, "coyote grace expires rather than creating an extra air jump")

	await spawn()
	game.hit_pause_enabled = true
	game._feedback(game.can.position, "clunk", Color.WHITE, 6, 3)
	await tick()
	check(game.player.impact_paused and game.player.active, "impact pause freezes simulation while keeping input capture active")
	Input.action_press("jump")
	await tick()
	Input.action_release("jump")
	await tick()
	await tick()
	check(game.player.velocity.y < -90 and game.player.velocity.y > -160, "press and release wholly inside hit-stop produce a short jump on resume")

	await spawn()
	game.player.position = Vector2(150, 250)
	game.player.velocity = Vector2.ZERO
	await tick()
	game.hit_pause_enabled = true
	game._feedback(game.can.position, "clunk", Color.WHITE, 6, 3)
	await tick()
	Input.action_press("attack")
	await tick()
	Input.action_release("attack")
	await tick(2)
	check(game.player.attack_time > 0 and game.player.velocity.y >= 170, "airborne stomp pressed during hit-stop executes on resume")

	await spawn()
	game.player.set_physics_process(false)
	game.can.position = Vector2(200, 306)
	for falling_speed in [25.0, 180.0, 390.0]:
		game.player.previous_position = Vector2(223, 276)
		game.player.previous_feet = 285
		game.player.position = Vector2(223, 286)
		game.player.velocity = Vector2(100, falling_speed)
		game.can.state = "charging"
		game.can.facing = 1
		game.can.state_time = 1
		check(game.player.try_can_rebound(game.can, 294, 1.0 / 60) and is_equal_approx(game.player.velocity.y, -305) and game.can.state == "charging", "descending corner rebound is consistent at %d px/s and preserves charge" % falling_speed)
	game.player.previous_position = Vector2(230, 276)
	game.player.previous_feet = 285
	game.player.position = Vector2(220, 286)
	game.player.velocity = Vector2(-155, 180)
	check(game.player.try_can_rebound(game.can, 294, 1.0 / 30), "fast diagonal top crossing is caught by swept contact")
	game.player.previous_position = Vector2(210, 281)
	game.player.previous_feet = 290
	game.player.position = Vector2(210, 281)
	game.player.velocity = Vector2(100, -20)
	game.can.position.y = 298
	check(game.player.try_can_rebound(game.can, 294, 1.0 / 60), "rising platform Can catches relative descending top contact")
	game.player.previous_feet = 310
	game.player.position = Vector2(210, 310)
	game.player.velocity.y = 180
	check(not game.player.try_can_rebound(game.can, 286, 1.0 / 60), "side and underside contact cannot become a free rebound")
	game.player.position = Vector2(210, 276)
	game.player.previous_feet = 270
	game.player.velocity.y = -235
	check(not game.player.try_can_rebound(game.can, 286, 1.0 / 60), "ascending jump cannot rebound before descending")

	await spawn()
	game.can.position = Vector2(500, 306)
	game.can.state = "recover"
	game.can.state_time = game.can.RECOVERY
	game.can.cooldown = 0
	game.can.suspended = false
	game.player.position = Vector2(560, 309)
	var frames := 0
	for i in 20:
		await tick()
		frames += 1
		if game.can.state == "windup": break
	measurements.recovery_to_preview = frames / 60.0
	check(frames <= 14, "Can is available for another decision within 0.24 s of recovery")

	await spawn(2)
	game.player.set_physics_process(false)
	game.can.position = Vector2(355, 306)
	game.can.velocity.y = 10
	game.can.move_and_slide()
	game.machines.rotator.suspended = false
	await tick(5)
	var before: float = game.machines.rotator.angle
	await tick(10)
	check(game.machines.rotator.angle > before, "weighted rotor moves continuously")
	game.can.position.x = 260
	await tick()
	before = game.machines.rotator.angle
	await tick(15)
	check(is_equal_approx(before, game.machines.rotator.angle) and game.machines.rotator.withdrawal_lead == 0, "leaving stops both beam angle and moving lead immediately")
	game.machines.rotator.angle = game.machines.rotator.sweep_max - 0.02
	check(game.machines.rotator.predicted_angle(1) <= game.machines.rotator.sweep_max, "withdrawal preview reflects at visible mechanical limits")

	await spawn(1)
	game.boulder.position.x = 100
	game.machines.fan.suspended = false
	game.player.position = Vector2(game.machines.fan.position.x, 309)
	game.player.velocity = Vector2.ZERO
	await tick(2)
	var early: float = game.player.velocity.y
	await tick(18)
	check(early > -80 and game.player.velocity.y < -100, "Fan entry ramps into strong continuous lift rather than instantly launching")
	game.player.position.x = 400
	await tick()
	check(game.machines.fan.entry_time == 0, "airflow ramp clears as soon as the player exits")

	await spawn(2)
	game._freeze(false)
	game.completed.assign([{"level": 1}, {"level": 2}])
	game.player.kill()
	frames = 0
	for i in 40:
		await tick()
		frames += 1
		if game.mode == "play": break
	measurements.death_to_control = frames / 60.0
	check(frames <= 18 and game.level_index == 2 and game.completed.size() == 2 and game.player.active, "death rebuilds current level in under 0.3 s and preserves progress")
	Input.action_press("restart")
	await tick(2)
	Input.action_release("restart")
	check(game.mode == "play" and game.level_index == 2 and not game.player.impact_paused, "quick R clears old hit-stop and returns current-level control")
	await spawn()
	game.player.position = Vector2(600, game.exit_floor - 9)
	game.player.velocity = Vector2.ZERO
	Input.action_press("move_right")
	for i in 15:
		await tick()
		if game.mode == "clear": break
	Input.action_press("jump")
	await tick()
	Input.action_release("jump")
	frames = 1
	for i in 50:
		await tick()
		frames += 1
		if game.level_index == 1: break
	await tick(3)
	measurements.transition_to_control = frames / 60.0
	check(game.level_index == 1 and game.mode == "play" and game.player.velocity.x > 0 and game.player.jump_buffer_time == 0, "held movement resumes after a short transition without replaying a stale jump")
	Input.action_release("move_right")
	for i in 100: game.effects.burst(Vector2.ZERO, Color.WHITE, 18)
	check(game.effects.particles.size() <= 128 and game.sound.get_child_count() <= 8, "repeat feedback stays within particle and audio node budgets")
	DirAccess.make_dir_recursive_absolute("res://artifacts/strategic_depth")
	var file := FileAccess.open("res://artifacts/strategic_depth/feel_checks.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"controlled_fixtures": true, "checks": checks, "measurements": measurements, "failures": failures}, "\t"))
	game.free()
	print("POLISH FEEL ", checks.size(), " checks; failures ", failures)
	quit(0 if failures.is_empty() else 1)
