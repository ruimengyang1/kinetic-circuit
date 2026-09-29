extends "res://tests/rebalance_route.gd"

class PhysicsBracket extends Node:
	var started := 0
	var samples: Array[float] = []
	var partner: Node
	func _physics_process(_delta: float) -> void:
		if partner == null: started = Time.get_ticks_usec()
		else: partner.samples.append((Time.get_ticks_usec() - partner.started) / 1000.0)

# Normal-input 30-second exercise. Repetition evidence, never a claim of fun.
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/polish/screenshots")
	capture_run = "--capture" in OS.get_cmdline_user_args()
	game = load("res://scenes/polish_sandbox.tscn").instantiate()
	root.add_child(game)
	await step()
	var begin := PhysicsBracket.new()
	begin.process_physics_priority = -100
	game.add_child(begin)
	var end := PhysicsBracket.new()
	end.partner = begin
	end.process_physics_priority = 100
	game.add_child(end)
	var peak_particles := 0
	var peak_nodes := 0
	var peak_physics_ms := 0.0
	var peak_process_ms := 0.0
	var active_physics_ms := 0.0
	var active_process_ms := 0.0
	for i in 1800:
		var dx: float = game.can.position.x - game.player.position.x
		var jump: bool = game.player.is_on_floor() and ((game.can.state == "charging" and absf(dx) < 85) or (game.can.state == "windup" and game.can.intent_locked and absf(dx) < 70))
		var move := 0.0
		if i % 360 >= 180:
			move = direction(100 if int(i / 360) % 2 == 0 else 540)
		elif not game.player.is_on_floor():
			move = signf(dx) if absf(dx) > 6 else 0.0
		elif absf(dx) < 48: move = -signf(dx)
		elif absf(dx) > 115: move = signf(dx)
		await step(move, jump)
		peak_particles = maxi(peak_particles, game.effects.particles.size())
		peak_nodes = maxi(peak_nodes, int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
		peak_physics_ms = maxf(peak_physics_ms, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000)
		peak_process_ms = maxf(peak_process_ms, Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
		if i >= 120:
			active_physics_ms = maxf(active_physics_ms, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000)
			active_process_ms = maxf(active_process_ms, Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
	if game.stats.charges < 6: fail("repeat charge rhythm")
	if game.stats.rebounds < 2: fail("repeat normal-input rebound")
	if game.total_deaths > 0: fail("sandbox exercise survived without reset")
	begin.samples.sort()
	var physics_cost := {"samples": begin.samples.size(), "maximum_ms": begin.samples.back() if not begin.samples.is_empty() else 0.0,
		"p95_ms": begin.samples[int(begin.samples.size() * 0.95)] if not begin.samples.is_empty() else 0.0}
	var file := FileAccess.open("res://artifacts/polish/sandbox.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"simulated_seconds": game.level_time, "requested_input_seconds": 30, "input_only": true, "human_playtest": false, "metrics": game.metrics(), "peak_particles": peak_particles, "peak_nodes": peak_nodes, "audio_voices": game.sound.voices.size(), "peak_physics_ms": peak_physics_ms, "peak_process_ms": peak_process_ms, "physics_ms_after_2s": active_physics_ms, "process_ms_after_2s": active_process_ms, "physics_callback_bracket": physics_cost, "failures": failures, "trace": trace}, "\t"))
	for action in ["move_left", "move_right", "jump", "attack"]: Input.action_release(action)
	print("POLISH SANDBOX ", game.stats, " failures ", failures)
	game.free()
	quit(0 if failures.is_empty() else 1)

func live_capture() -> void:
	if frame < 10: await capture("sandbox_start")
	if game.can.state == "windup" and game.can.intent_locked: await capture("sandbox_lock")
	if game.can.state == "charging": await capture("sandbox_charge")
	if game.player.bounce_pose > 0: await capture("sandbox_bounce")
	if frame == 1800: await capture("sandbox_30_seconds")

func capture(name: String) -> void:
	if name in captures: return
	captures.append(name)
	# Background windows may delay a frame-post-draw signal. Pause the fixture
	# after this physics tick so a screenshot wait cannot add unactuated play.
	await process_frame
	paused = true
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/polish/screenshots/" + name + ".png")
	paused = false
