extends SceneTree

# Controlled fixtures for meaningful actor behavior. These never count as
# player completion routes or evidence about human enjoyment.
var game: Node2D
var failures: Array[String] = []
var measurements: Dictionary = {}
var checks: Array[String] = []
var output_dir := "res://artifacts/precision_progression/revision"
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output_dir = arg.substr(9)
	call_deferred("run")
func tick(count: int = 1) -> void:
	for i in count:
		await physics_frame
		await process_frame
func check(value: bool, message: String) -> void:
	checks.append(message)
	if not value: failures.append(message)
	print("PASS " if value else "FAIL ", message)
func spawn(sandbox: bool = true, index: int = 0) -> void:
	if game != null: game.free()
	for action in ["move_left", "move_right", "jump", "attack", "restart"]:
		if InputMap.has_action(action): Input.action_release(action)
	game = load("res://scenes/polish_sandbox.tscn" if sandbox else "res://scenes/final_demo.tscn").instantiate()
	game.start_level = index
	root.add_child(game)
	await tick(3)
	game._freeze(true)
	game.player.active = true
	game.player.position = Vector2(200, 309)
	game.player.velocity = Vector2.ZERO
	await tick(3)
func run() -> void:
	await spawn()
	Input.action_press("move_right")
	await tick(6)
	check(game.player.velocity.x > 150, "full ground speed within 100 ms")
	Input.action_release("move_right")
	Input.action_press("move_left")
	await tick(6)
	check(game.player.velocity.x < 0, "ground reversal within 100 ms")
	await tick(6)
	Input.action_release("move_left")
	var stop_x: float = game.player.position.x
	await tick(6)
	measurements.stop_distance = absf(game.player.position.x - stop_x)
	check(absf(game.player.velocity.x) < 0.1 and measurements.stop_distance < 8, "predictable ground stop under eight pixels")
	await spawn()
	game.player.position = Vector2(250, 285)
	game.player.velocity = Vector2(0, 180)
	game.player.coyote_time = 0
	await tick()
	game.player.coyote_time = 0
	Input.action_press("jump")
	await tick()
	check(game.player.jump_buffer_time > 0, "prelanding press buffers")
	for i in 10:
		await tick()
		if game.player.velocity.y < -200: break
	check(game.player.velocity.y < -200, "buffered jump launches on landing")
	for delay_frames in [3, 8]:
		await spawn()
		game._block(Rect2(250, 270, 60, 8), true)
		game.player.position = Vector2(302, 261)
		await tick(3)
		Input.action_press("move_right")
		for i in 18:
			await tick()
			if not game.player.is_on_floor(): break
		await tick(delay_frames)
		Input.action_press("jump")
		await tick()
		check((game.player.velocity.y < -200) == (delay_frames == 3), "physical coyote window %d frames after ledge" % delay_frames)
	await spawn()
	game.player.position = Vector2(200, 309)
	var empty_path: Array[Vector2] = []
	game._platform("underside", Rect2(180, 275, 80, 10), empty_path, 100)
	Input.action_press("jump")
	await tick(8)
	check(game.player.velocity.y < -140 and game.player.position.y - 9 < 285, "thin platform underside does not cancel jump")
	await spawn()
	game.player.position = Vector2(200, 309)
	var lift_path: Array[Vector2] = [Vector2(220, 255)]
	var lift: Node2D = game._platform("riding", Rect2(180, 318, 80, 10), lift_path, 120)
	lift.set_power(true)
	await tick(12)
	Input.action_press("jump")
	await tick()
	check(game.player.velocity.y < -220 and game.player.velocity.y > -230, "jump leaving a moving support has ordinary vertical impulse")
	await spawn()
	game.hit_pause_enabled = true
	game._feedback(game.can.position, "clunk", Color.WHITE, 6, 3)
	await tick()
	Input.action_press("jump")
	await tick()
	Input.action_release("jump")
	await tick(5)
	check(game.player.velocity.y < -40 and not game.player.impact_paused, "press/release through hit-stop survives")
	await spawn()
	game.player.active = false
	game.can.suspended = false
	game.can.position = Vector2(200, 305.9)
	game.can.cooldown = 100
	game.player.active = true
	game.player.set_physics_process(false)
	game.player.position = Vector2(360, 309)
	await tick(120)
	check(absf(game.can.position.x - 200) < 0.01, "search and cooldown never creep")
	var endpoints: Array[float] = []
	for attempt in 3:
		await spawn()
		game.player.active = false
		game.can.suspended = false
		game.can.position = Vector2(200, 305.9)
		game.player.position = Vector2(400, 309)
		game.can.state = "windup"
		game.can.state_time = game.can.ANTICIPATION
		game.can.facing = 1
		await tick(31)
		check(game.can.intent_locked and game.can.state == "lock", "explicit lock phase run%d" % attempt)
		var preview: float = game.can.predicted_endpoint()
		check(game.can.predicted_endpoint(-1) == preview and game.can.facing == 1, "locked preview cannot propose the uncommitted direction run%d" % attempt)
		game.player.position.x = 50
		await tick(80)
		endpoints.append(game.can.position.x)
		check(game.can.facing == 1 and absf(game.can.position.x - 448) < 0.1, "post-lock crossing cannot redirect; fixed travel run%d" % attempt)
		check(absf(preview - game.can.position.x) < 0.25, "free endpoint preview matches result run%d" % attempt)
	measurements.repeated_can_endpoints = endpoints
	check(endpoints[0] == endpoints[1] and endpoints[1] == endpoints[2], "identical setup has identical Can endpoint")
	for origin in [24.1, 615.9]:
		await spawn()
		game.player.active = false
		game.can.suspended = false
		game.can.position = Vector2(origin, 305.9)
		game.can.facing = 1 if origin < 100 else -1
		game.can.state = "lock"
		game.can.intent_locked = true
		game.can.state_time = 0.05
		await tick(80)
		check(absf(game.can.position.x - origin - game.can.facing * 248) < 0.1, "Can can depart either end bumper into a full charge %.1f" % origin)
	await spawn(false)
	game.hit_pause_enabled = false # Separate fixture; hit-stop input is checked above.
	game.player.active = false
	game.can.suspended = false
	game.can.position = Vector2(160, 305.9)
	game.player.position = Vector2(300, 309)
	game.can.state = "windup"
	game.can.state_time = game.can.ANTICIPATION
	game.can.facing = 1
	await tick(31)
	var wall_preview: float = game.can.predicted_endpoint()
	await tick(70)
	measurements.force_endpoint = game.can.position.x
	measurements.force_preview = wall_preview
	check(game.platforms.shutter.powered and absf(game.can.position.x - 220) < 0.1, "force impact stops at actual bumper")
	check(absf(wall_preview - game.can.position.x) < 0.5, "collision-aware endpoint preview matches force stop")
	var before: float = game.can.position.x
	await tick(60)
	check(absf(game.can.position.x - before) < 0.01, "no slide, recoil displacement or search drift after impact")
	await spawn()
	for side in [-1, 1]:
		game.can.state = "lock"
		game.can.intent_locked = true
		game.can.state_time = 0.08
		game.player.position = Vector2(game.can.position.x + side * 18, 290)
		game.player.previous_position = Vector2(game.can.position.x + side * 18, 270)
		game.player.previous_feet = 279
		game.player.velocity = Vector2(side * 70, 150)
		var bounced: bool = game.player.try_can_rebound(game.can, 294, 1.0 / 60, game.can.position.x)
		check(bounced and game.player.velocity.y == -305 and game.player.velocity.x == side * 70, "forgiving bounce has fixed height and no side launch %d" % side)
		check(game.can.state == "lock" and game.can.state_time == 0.08, "bounce preserves committed preparation %d" % side)
	await spawn(false, 2)
	var rotor: Node2D = game.machines.rotator
	for sign_value in [-1, 1]:
		rotor.angle = rotor.sweep_min + deg_to_rad(2) if sign_value < 0 else rotor.sweep_max - deg_to_rad(2)
		rotor.rotation_rate = sign_value * deg_to_rad(14)
		var predicted: float = rotor.predicted_angle(0.6)
		var actual: float = rotor.angle
		var rate: float = rotor.rotation_rate
		# Independent reflected-step simulation, crossing the mechanical bound.
		for i in 36:
			actual += rate / 60
			if actual > rotor.sweep_max:
				actual = 2 * rotor.sweep_max - actual
				rate = -absf(rate)
			if actual < rotor.sweep_min:
				actual = 2 * rotor.sweep_min - actual
				rate = absf(rate)
		check(absf(actual - predicted) < 0.0001, "reflected rotor prediction matches independent motion %d" % sign_value)
	rotor.angle = rotor.sweep_min + deg_to_rad(14) / 120
	rotor.rotation_rate = -deg_to_rad(14)
	rotor._advance_sweep(1.0 / 60)
	check(rotor.rotation_rate > 0, "equal-position reflection still reverses rotation direction")
	var rolls: Array[float] = []
	for attempt in 3:
		await spawn()
		game.player.active = false
		var boulder: CharacterBody2D = load("res://scripts/demo_boulder.gd").new()
		boulder.position = Vector2(320, 301.9)
		game.room.add_child(boulder)
		await tick(4)
		boulder.receive_impact(300)
		var monotonic := true
		var previous: float = boulder.position.x
		for i in 90:
			await tick()
			monotonic = monotonic and boulder.position.x >= previous - 0.01
			previous = boulder.position.x
		rolls.append(boulder.position.x)
		check(monotonic and absf(boulder.velocity.x) < 0.01, "heavy signed roll stops without random bounce run%d" % attempt)
	measurements.repeated_boulder_endpoints = rolls
	check(rolls[0] == rolls[1] and rolls[1] == rolls[2], "identical force has identical Boulder endpoint")
	await spawn()
	game.player.active = false
	var stationary_path: Array[Vector2] = []
	var bumper: Node2D = game._platform("boulder_stop", Rect2(430, 288, 20, 30), stationary_path, 0, true)
	var rolling_body: CharacterBody2D = load("res://scripts/demo_boulder.gd").new()
	rolling_body.position = Vector2(320, 301.9)
	game.room.add_child(rolling_body)
	await tick(4)
	rolling_body.receive_impact(300)
	await tick(80)
	check(bumper.powered and absf(rolling_body.position.x - 414) < 0.3 and absf(rolling_body.velocity.x) < 0.01, "Boulder transfer contacts exact bumper then stops without elastic reversal")
	await spawn(false, 3)
	game.player.active = false
	await tick(20)
	check(game.can.is_on_floor(), "final-room bumper spawn establishes floor contact")
	for index in 4:
		await spawn(false, index)
		check(game.boulder == null, "L%d keeps no redundant Boulder" % (index + 1))
		check(game.camera.position == Vector2(320, 180), "L%d camera shows the full decision room" % (index + 1))
	await extra_checks()
	DirAccess.make_dir_recursive_absolute(output_dir)
	var file := FileAccess.open(output_dir + "/systems.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks": checks, "measurements": measurements, "failures": failures}, "\t"))
	game.free()
	print("PRECISION SYSTEMS failures=", failures)
	quit(0 if failures.is_empty() else 1)

func extra_checks() -> void:
	pass
