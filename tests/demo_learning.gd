extends SceneTree
# These controlled timing fixtures examine the same stable AI delay; they are
# separate from the input-only completion recordings.
var game: Node2D
var failures: Array[String] = []
var outcomes: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func tick(count: int = 1) -> void:
	for i in count:
		await process_frame
		await physics_frame
func fixture() -> void:
	if game != null: game.free()
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = 2
	game.hit_pause_enabled = false
	root.add_child(game)
	await tick(3)
	game.player.position = Vector2(351, 272)
	game.player.velocity = Vector2.ZERO
	game.can.position = Vector2(355, 306)
	game.can.state = "idle"
	game.can.cooldown = 0
	await tick(6)
func run() -> void:
	for late in [true, false]:
		await fixture()
		var rotator: Node2D = game.machines.rotator
		var target: float = (game.machines.sensor.position - rotator.beam_origin()).angle()
		for i in 350:
			if (late and game.machines.sensor.active) or (not late and rotator.angle >= target - deg_to_rad(26)): break
			await tick()
		var began: float = rad_to_deg(rotator.angle)
		Input.action_press("move_left")
		for i in 120:
			if game.player.position.x < 303: Input.action_release("move_left")
			await tick()
			if not rotator.occupied: break
		await tick(3)
		var result := {"late": late, "bait_started_angle": began, "stopped_angle": rad_to_deg(rotator.angle), "sensor_angle": rad_to_deg(target), "sensor_active": game.machines.sensor.active, "can": game.can.position}
		outcomes.append(result)
		if late and game.machines.sensor.active: failures.append("late bait must overshoot")
		if not late and not game.machines.sensor.active: failures.append("anticipatory bait must sustain alignment")
		print("TIMING ", result)
		Input.action_release("move_left")
	game.free()
	var file := FileAccess.open("res://artifacts/final_demo/learning.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"outcomes": outcomes, "failures": failures}, "\t"))
	file.close()
	print("FINAL LEARNING failures ", failures)
	quit(0 if failures.is_empty() else 1)
