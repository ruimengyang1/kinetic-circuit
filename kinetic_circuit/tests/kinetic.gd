extends SceneTree

const RamScript = preload("res://scripts/enemy.gd")
const CarriageScript = preload("res://scripts/moving_platform.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_strike_transfer()
	_test_playthrough_states()
	_test_counter_outcomes()
	_test_deterministic_damping()
	await _test_kinetic_ram_health()
	await _test_room_strikes_collision_and_reset()
	if failures.is_empty():
		print("KINETIC PASS: transfer bands, stop rebound, direct correction, collision, relaunch recovery, reset, and exit")
		quit(0)
	else:
		for failure in failures:
			printerr("KINETIC FAIL: ", failure)
		quit(1)

func _test_strike_transfer() -> void:
	var weak := _ram_speed_after_strike(0.0)
	var medium := _ram_speed_after_strike(60.0)
	var strong := _ram_speed_after_strike(150.0)
	var opposite := _ram_speed_after_strike(-150.0)
	_check(is_equal_approx(weak, 60.0), "near-vertical strike damps a 150 ram charge to 60 (found %.2f)" % weak)
	_check(is_equal_approx(medium, 126.0), "medium strike produces a distinct 126 ram speed (found %.2f)" % medium)
	_check(is_equal_approx(strong, 225.0), "strong strike produces a distinct 225 ram speed (found %.2f)" % strong)
	_check(opposite < 0.0 and is_equal_approx(opposite, -105.0), "opposite strike reverses the ram (found %.2f)" % opposite)
	_check(strong - medium > 70.0 and medium - weak > 60.0, "weak, medium, and strong bands remain clearly separated")

func _test_playthrough_states() -> void:
	var weak_carriage = _new_carriage()
	weak_carriage.receive_ram_impact(_ram_speed_after_strike(0.0))
	_settle(weak_carriage)
	_check(weak_carriage.position.x > 190.0 and weak_carriage.position.x < 200.0, "B undershoot stops near the left side (x %.2f)" % weak_carriage.position.x)

	var medium_carriage = _new_carriage()
	medium_carriage.receive_ram_impact(_ram_speed_after_strike(60.0))
	_settle(medium_carriage)
	_check(medium_carriage.position.x > 248.0 and medium_carriage.position.x < 264.0, "C controlled push settles in the useful jump window (x %.2f)" % medium_carriage.position.x)

	var strong_carriage = _new_carriage()
	var stop_trace := {"hits": 0, "speed": 0.0}
	strong_carriage.stop_rebounded.connect(func(side: int, _incoming: float, outgoing: float) -> void:
		if side > 0:
			stop_trace["hits"] = int(stop_trace["hits"]) + 1
			stop_trace["speed"] = outgoing
	)
	strong_carriage.receive_ram_impact(_ram_speed_after_strike(150.0))
	for _step in 600:
		strong_carriage.advance_kinetic(1.0 / 120.0)
		if int(stop_trace["hits"]) > 0:
			break
	_check(int(stop_trace["hits"]) == 1, "A strong push reaches the far stop")
	_check(float(stop_trace["speed"]) < -50.0, "A far stop returns substantial leftward speed (%.2f)" % float(stop_trace["speed"]))

	var speed_before_recovery: float = strong_carriage.velocity_x
	strong_carriage.receive_kinetic_strike(155.0)
	_check(absf(strong_carriage.velocity_x) < absf(speed_before_recovery), "D opposite carriage strike brakes the rebound (%.2f -> %.2f)" % [speed_before_recovery, strong_carriage.velocity_x])
	_settle(strong_carriage)
	_check(strong_carriage.position.x > 265.0, "D corrected carriage remains in a recoverable exit position (x %.2f)" % strong_carriage.position.x)
	weak_carriage.free()
	medium_carriage.free()
	strong_carriage.free()

func _test_deterministic_damping() -> void:
	var first = _new_carriage()
	var second = _new_carriage()
	first.velocity_x = 73.0
	second.velocity_x = 73.0
	for _step in 240:
		first.advance_kinetic(1.0 / 120.0)
		second.advance_kinetic(1.0 / 120.0)
	_check(is_equal_approx(first.position.x, second.position.x) and is_equal_approx(first.velocity_x, second.velocity_x), "carriage damping is deterministic")
	first.free()
	second.free()

func _test_counter_outcomes() -> void:
	var head_on = _new_carriage()
	head_on.velocity_x = 100.0
	head_on.receive_ram_impact(-150.0)
	_check(head_on.velocity_x < 0.0, "an untouched opposing ram reverses a rightward carriage (found %.2f)" % head_on.velocity_x)

	var redirected_ram = RamScript.new()
	redirected_ram.configure_kinetic_ram(Vector2.ZERO, -100.0, 100.0)
	redirected_ram.velocity_x = -150.0
	redirected_ram.receive_kinetic_strike(155.0)
	_check(redirected_ram.velocity_x > 100.0, "a fast rightward strike turns the opposing ram into a rightward pacer (found %.2f)" % redirected_ram.velocity_x)

	var recovered = _new_carriage()
	recovered.velocity_x = -80.0
	recovered.receive_ram_impact(150.0)
	_check(recovered.velocity_x > 20.0, "a later launch-ram impact turns a failed leftward state back into progress (found %.2f)" % recovered.velocity_x)
	head_on.free()
	redirected_ram.free()
	recovered.free()

func _test_kinetic_ram_health() -> void:
	var destructible_ram = RamScript.new()
	destructible_ram.configure_kinetic_ram(Vector2.ZERO, -100.0, 100.0)
	root.add_child(destructible_ram)
	await physics_frame
	_check(destructible_ram.health == destructible_ram.KINETIC_RAM_HEALTH, "opening rams start with two visible hit points")
	_check(destructible_ram.receive_kinetic_strike(100.0) and destructible_ram.health == 1 and destructible_ram.alive, "the first ram hit transfers momentum and removes one health")
	_check(destructible_ram.receive_kinetic_strike(100.0) and not destructible_ram.alive and destructible_ram.state == "dying", "the second ram hit defeats it")
	await create_timer(destructible_ram.DEATH_ANIMATION_DURATION + 0.06).timeout
	_check(is_instance_valid(destructible_ram) and destructible_ram.state == "defeated" and not destructible_ram.visible, "a defeated opening ram remains available for encounter restoration")
	destructible_ram.reset_kinetic()
	_check(destructible_ram.alive and destructible_ram.visible and destructible_ram.health == destructible_ram.KINETIC_RAM_HEALTH and destructible_ram.collision_layer == 16, "reset restores the ram's health, visuals, and collision")
	destructible_ram.free()

func _test_room_strikes_collision_and_reset() -> void:
	var scene := load("res://scenes/kinetic_prototype.tscn") as PackedScene
	var prototype = scene.instantiate()
	root.add_child(prototype)
	await physics_frame
	await physics_frame
	_check(prototype.slow_bar.size == Vector2(45, 4), "the top-right slow-motion bar leaves more of the playfield visible (size %s, minimum %s)" % [prototype.slow_bar.size, prototype.slow_bar.get_combined_minimum_size()])
	_check(prototype.health_icons.size() == 3 and prototype.health_icons.all(func(icon: Label) -> bool: return icon.text == "◆"), "three compact icons display player health at the top left")
	_check("WASD  MOVE" in prototype.result_label.text and "J  ATTACK" in prototype.result_label.text, "a one-time opening message presents only the move and attack controls")
	_check(prototype.timer_label.position.x < prototype.slow_label.position.x, "the timer sits immediately left of the top-right slow-motion meter")
	var opening_distance: float = prototype.player.global_position.distance_to(prototype.ram.global_position)
	await create_timer(0.38).timeout
	_check(opening_distance > 95.0, "the launch ram begins outside its detection range (distance %.2f)" % opening_distance)
	_check(prototype.ram.state == "idle" and prototype.player.health == 3, "the launch ram leaves the stationary player safe during the opening pause")
	_check(prototype.elapsed > 0.2 and "00:00." in prototype.timer_label.text and "TIME" not in prototype.timer_label.text, "Kinetic Clockwork displays a concise live run timer to tenths of a second")
	var full_slow_charge: float = prototype.slow_motion_energy
	Input.action_press("slow_motion")
	await process_frame
	await process_frame
	Input.action_release("slow_motion")
	for _frame in 6:
		await process_frame
	_check(prototype.slow_motion_active and is_equal_approx(Engine.time_scale, prototype.SLOW_MOTION_SCALE), "one Q press toggles the entire simulation to 35 percent")
	_check(is_equal_approx(AudioServer.playback_speed_scale, prototype.SLOW_MOTION_SCALE) and prototype.slow_tint.visible, "slow motion also slows audio and displays its visual indicator")
	_check(prototype.slow_motion_energy < full_slow_charge and absf(prototype.slow_bar.value - prototype.slow_motion_energy) < 0.002, "the visible slow-motion bar drains while active")
	var elapsed_before_slow_wait: float = prototype.elapsed
	await create_timer(0.1, true, false, true).timeout
	_check(prototype.elapsed - elapsed_before_slow_wait > 0.075, "the run timer continues at real speed during slow motion")
	var drained_slow_charge: float = prototype.slow_motion_energy
	Input.action_press("slow_motion")
	await process_frame
	await process_frame
	Input.action_release("slow_motion")
	for _frame in 6:
		await process_frame
	_check(not prototype.slow_motion_active and is_equal_approx(Engine.time_scale, 1.0) and is_equal_approx(AudioServer.playback_speed_scale, 1.0), "a second Q press restores normal game and audio speed")
	_check(prototype.slow_motion_energy > drained_slow_charge, "the slow-motion bar recharges while normal time is active")
	Input.action_press("slow_motion")
	await process_frame
	await process_frame
	Input.action_release("slow_motion")
	prototype.slow_motion_energy = 0.001
	await process_frame
	await process_frame
	_check(not prototype.slow_motion_active and is_equal_approx(Engine.time_scale, 1.0), "emptying the slow-motion bar automatically restores normal speed")
	prototype._reset_slow_motion_meter()
	Input.action_press("move_right")
	for _frame in 4:
		await physics_frame
	Input.action_release("move_right")
	var medium_input_speed: float = prototype.player.velocity.x
	prototype.reset_encounter()
	await process_frame
	_check(prototype.result_label.text.is_empty(), "the compact control instructions appear only once at game startup")
	Input.action_press("move_right")
	for _frame in 14:
		await physics_frame
	Input.action_release("move_right")
	var strong_input_speed: float = prototype.player.velocity.x
	_check(medium_input_speed > 45.0 and medium_input_speed < 90.0, "a short directional press reproducibly creates a medium-speed band (%.2f)" % medium_input_speed)
	_check(strong_input_speed > 145.0, "a held direction reproducibly reaches the strong-speed band (%.2f)" % strong_input_speed)

	prototype.reset_encounter()
	await process_frame
	prototype.ram.state = "recover"
	prototype.ram.state_time = 10.0
	prototype.counter_ram.state = "recover"
	prototype.counter_ram.state_time = 10.0
	prototype.carriage.position = Vector2(450, prototype.CARRIAGE_START.y)
	prototype.carriage.velocity_x = 0.0
	prototype.carriage._sync_kinetic_transform()
	prototype.player.reset_at(Vector2(414, 173))
	prototype.player.facing = 1
	await physics_frame
	Input.action_press("attack")
	await physics_frame
	await physics_frame
	Input.action_release("attack")
	_check(prototype.carriage.velocity_x > 75.0 and prototype.carriage.velocity_x < 90.0, "a grounded forward attack gives the carriage a ram-strength push (%.2f)" % prototype.carriage.velocity_x)
	_check(prototype.player.velocity.x < 0.0, "carriage impact rebounds the forward-attacking player (%.2f)" % prototype.player.velocity.x)

	prototype.reset_encounter()
	await process_frame
	prototype.player.invulnerable_time = 0.0
	prototype._on_ram_touched_player(prototype.ram.global_position)
	_check(prototype.player.health == 2 and prototype.player.active and prototype.mode == "play", "ram contact removes one health instead of defeating the player")
	_check(prototype.health_icons[2].get_theme_color("font_color") == Color("35434b"), "the top-left health icons empty as health is lost")
	prototype._on_ram_touched_player(prototype.ram.global_position)
	_check(prototype.player.health == 2, "brief invulnerability prevents repeated contact damage")
	prototype.player.invulnerable_time = 0.0
	prototype._on_ram_touched_player(prototype.ram.global_position)
	_check(prototype.player.health == 1 and prototype.player.active, "the player survives a second separated ram hit")
	prototype.carriage.position = Vector2(760, prototype.CARRIAGE_START.y)
	prototype.carriage.velocity_x = 80.0
	prototype.player.invulnerable_time = 0.0
	prototype._on_ram_touched_player(prototype.ram.global_position)
	_check(prototype.mode == "dead", "the third separated ram hit defeats the player")
	_check(prototype.player.death_animation_time > 0.0 and "SYSTEM FAILURE" in prototype.result_label.text, "kinetic death starts the player ragdoll and failure message")
	await create_timer(0.22).timeout
	_check(prototype.camera.zoom.x > 1.2, "kinetic death zooms the camera toward the player")
	await create_timer(0.54).timeout
	_check(prototype.mode == "play" and prototype.player.health == 3, "death restores all three health points")
	_check(prototype.health_icons.all(func(icon: Label) -> bool: return icon.get_theme_color("font_color") == Color("e9876c")), "revival restores all three health icons")
	_check(is_equal_approx(prototype.camera.zoom.x, 1.0) and prototype.result_label.text.is_empty(), "kinetic revival resets the death camera and message")
	_check(prototype.carriage.position.distance_to(prototype.CARRIAGE_START) < 1.0 and is_zero_approx(prototype.carriage.velocity_x), "death restores the carriage spawn position and clears its velocity (position %s, spawn %s, velocity %.2f, ram %s/%s/%.1f)" % [prototype.carriage.position, prototype.carriage.spawn_position, prototype.carriage.velocity_x, prototype.ram.position, prototype.ram.state, prototype.ram.velocity_x])

	var spike_area := prototype.get_tree().get_first_node_in_group("kinetic_spikes") as Area2D
	var spike_shape := spike_area.get_child(0) as CollisionShape2D
	_check(spike_shape.shape.size == prototype.spike_rects[0].size - Vector2(4, 2), "spike collision is inset from the visible spike rectangle")
	var spike_foundation := prototype.get_tree().get_first_node_in_group("spike_foundations") as StaticBody2D
	var foundation_shape := spike_foundation.get_child(0) as CollisionShape2D
	_check(foundation_shape.shape.size.x == prototype.spike_rects[0].size.x and foundation_shape.shape.size.y > 20.0, "a solid foundation prevents invulnerable players from falling through spike beds")
	prototype.player.reset_at(Vector2(250, 174))
	prototype.player.invulnerable_time = 1.0
	prototype.player.hazard_recovery_time = 0.0
	prototype._on_environmental_hazard()
	_check(prototype.player.health == 2 and prototype.player.invulnerable_time > 0.0, "spikes still damage and recover the player during ordinary invulnerability frames")
	prototype.player.reset_at(Vector2(250, 174))
	await physics_frame
	_check(prototype.mode == "play", "near-tip spike contact has a small grace margin")
	prototype.player.reset_at(Vector2(300, 165))
	prototype.player.velocity = Vector2(0, 40)
	await physics_frame
	Input.action_press("aim_down")
	Input.action_press("attack")
	await create_timer(0.07).timeout
	Input.action_release("attack")
	Input.action_release("aim_down")
	_check(prototype.mode == "play" and prototype.player.velocity.y < -180.0 and prototype.player.pogo_safety_time > 0.0, "a downward strike safely pogos from kinetic spikes (mode %s, velocity %s)" % [prototype.mode, prototype.player.velocity])
	prototype.reset_encounter()
	await physics_frame
	await physics_frame
	var kinetic_safe_position: Vector2 = prototype.player._safe_recovery_position()
	prototype.player.global_position.y = 245.0
	await physics_frame
	_check(prototype.mode == "play" and prototype.player.health == 2 and prototype.player.global_position.distance_to(kinetic_safe_position) < 4.0, "falling in Kinetic Clockwork costs one health and restores the last platform")

	prototype.reset_encounter()
	await process_frame
	prototype.ram.state = "coast"
	prototype.ram.velocity_x = 150.0
	prototype.player.global_position = prototype.ram.global_position + Vector2(0, -28)
	prototype.player.velocity = Vector2(60, 0)
	await physics_frame
	Input.action_press("aim_down")
	Input.action_press("attack")
	await physics_frame
	await physics_frame
	Input.action_release("attack")
	Input.action_release("aim_down")
	_check(prototype.player.velocity.y < -180.0, "real downward strike rebounds from the kinetic ram")
	_check(prototype.ram.velocity_x > 90.0 and prototype.ram.velocity_x < 145.0, "real medium-speed strike changes ram momentum (%.2f)" % prototype.ram.velocity_x)

	prototype.reset_encounter()
	await process_frame
	prototype.ram.state = "recover"
	prototype.ram.state_time = 10.0
	prototype.player.global_position = prototype.carriage.global_position + Vector2(0, -34)
	prototype.player.velocity = Vector2(155, 0)
	await physics_frame
	Input.action_press("aim_down")
	Input.action_press("attack")
	await physics_frame
	await physics_frame
	Input.action_release("attack")
	Input.action_release("aim_down")
	_check(prototype.player.velocity.y < -180.0, "real downward strike rebounds from the carriage")
	_check(prototype.carriage.velocity_x > 25.0 and prototype.carriage.velocity_x < 40.0, "direct carriage strike makes a smaller correction (%.2f)" % prototype.carriage.velocity_x)

	prototype.reset_encounter()
	await process_frame
	prototype.player.active = false
	prototype.ram.position = Vector2(prototype.carriage.position.x - 43.0, prototype.ram.position.y)
	prototype.ram.velocity_x = 120.0
	prototype.ram.state = "coast"
	prototype.carriage.velocity_x = 0.0
	await physics_frame
	await physics_frame
	_check(prototype.carriage.velocity_x > 60.0, "physical ram/carriage contact transfers current velocity (carriage %.2f)" % prototype.carriage.velocity_x)
	_check(prototype.ram.velocity_x < 0.0, "ram remains and rebounds after carriage contact (ram %.2f)" % prototype.ram.velocity_x)
	prototype.carriage.position.x = 245.0
	prototype.carriage.velocity_x = -31.0
	prototype.ram.position.x = 250.0
	prototype.ram.velocity_x = 90.0
	prototype.counter_ram.position.x = 820.0
	prototype.counter_ram.velocity_x = -70.0
	prototype.reset_encounter()
	_check(prototype.carriage.position.distance_to(prototype.CARRIAGE_START) < 2.0 and absf(prototype.carriage.velocity_x) < 1.0, "reset restores carriage position and velocity")
	_check(prototype.ram.position == prototype.RAM_START and is_zero_approx(prototype.ram.velocity_x), "reset restores ram position and velocity")
	_check(prototype.counter_ram.position == prototype.COUNTER_RAM_START and is_zero_approx(prototype.counter_ram.velocity_x), "reset restores the opposing ram")
	_check(prototype.player.position == prototype.START_POSITION and prototype.player.active, "reset restores the player")
	await process_frame

	prototype.player.active = false
	prototype.counter_ram.state = "recover"
	prototype.counter_ram.state_time = 10.0
	prototype.carriage.velocity_x = -80.0
	prototype.carriage.receive_ram_impact(150.0)
	_check(prototype.carriage.velocity_x > 20.0, "the original ram can relaunch a carriage sent backward by the opposing ram (carriage %.2f)" % prototype.carriage.velocity_x)

	prototype.reset_encounter()
	await process_frame
	prototype.ram.state = "recover"
	prototype.ram.state_time = 10.0
	prototype.counter_ram.state = "recover"
	prototype.counter_ram.state_time = 10.0
	prototype.carriage.set_physics_process(false)
	prototype.carriage.sync_to_physics = false
	prototype.carriage.position = Vector2(1075, prototype.carriage.position.y)
	prototype.carriage.velocity_x = -16.0
	prototype.player.reset_at(Vector2(1075, 140))
	await create_timer(0.1).timeout
	Input.action_press("jump")
	await create_timer(0.3).timeout
	Input.action_release("jump")
	_check(prototype.dash_pickup_collected and prototype.player.dash_enabled, "the returning carriage carries the player through the gantry and into the Dash Core")
	prototype.player.reset_at(prototype.FINAL_GOAL_POSITION + Vector2(0, 14))
	await create_timer(0.08).timeout
	_check(prototype.mode == "complete" and prototype.clockwork_core_collected, "collecting the Clockwork Core completes the extended level")
	prototype.mode = "complete"
	prototype.player.active = false
	await create_timer(0.5).timeout
	prototype.free()
	await process_frame

func _ram_speed_after_strike(player_speed: float) -> float:
	var ram = RamScript.new()
	ram.configure_kinetic_ram(Vector2.ZERO, -100.0, 100.0)
	ram.velocity_x = 150.0
	ram.receive_kinetic_strike(player_speed)
	var result: float = ram.velocity_x
	ram.free()
	return result

func _new_carriage():
	var carriage = CarriageScript.new()
	carriage.configure_kinetic(Vector2(176, 166), 176.0, 280.0)
	return carriage

func _settle(carriage) -> void:
	for _step in 2400:
		carriage.advance_kinetic(1.0 / 120.0)
		if is_zero_approx(carriage.velocity_x):
			return

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
