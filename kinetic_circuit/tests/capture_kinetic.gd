extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/kinetic_prototype.tscn") as PackedScene
	var prototype = scene.instantiate()
	root.add_child(prototype)
	await process_frame
	prototype.player.invulnerable_time = 0.0
	await create_timer(0.2).timeout
	if not _save("/tmp/kinetic_relay_start.png"):
		printerr("KINETIC CAPTURE FAIL")
		quit(1)
		return
	prototype.carriage.set_physics_process(false)
	prototype.carriage.sync_to_physics = false
	prototype.carriage.position = Vector2(630, 166)
	prototype.carriage.velocity_x = 90.0
	prototype.counter_ram.position = Vector2(690, 172)
	prototype.counter_ram.state = "windup"
	prototype.counter_ram.state_time = 0.3
	prototype.player.global_position = Vector2(625, 140)
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_relay_counter.png"):
		quit(1)
		return
	prototype.carriage.position = Vector2(1070, 166)
	prototype.carriage.velocity_x = -45.0
	prototype.counter_ram.position = Vector2(1125, 172)
	prototype.counter_ram.state = "recover"
	prototype.counter_ram.state_time = 0.3
	prototype.player.global_position = Vector2(1070, 140)
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_relay_return.png"):
		quit(1)
		return
	prototype.player.reset_at(prototype.DASH_PICKUP_POSITION)
	await create_timer(0.08).timeout
	prototype.player.reset_at(Vector2(1365, 173))
	Input.action_press("move_right")
	Input.action_press("aim_up")
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_dash_chain.png"):
		quit(1)
		return
	Input.action_release("move_right")
	Input.action_release("aim_up")
	prototype.player.reset_at(Vector2(2365, -133))
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_vertical_works.png"):
		quit(1)
		return
	prototype.player.reset_at(Vector2(2800, -279))
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_summit.png"):
		quit(1)
		return
	prototype.player.reset_at(Vector2(5500, -300))
	prototype.player.active = false
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_descent_foundry.png"):
		quit(1)
		return
	prototype.player.reset_at(Vector2(6800, 65))
	prototype.player.active = false
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_razor_transit.png"):
		quit(1)
		return
	prototype.player.reset_at(Vector2(7530, 75))
	prototype.player.active = false
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_aerial_core.png"):
		quit(1)
		return
	prototype.player.reset_at(Vector2(8950, 0))
	prototype.player.active = false
	prototype.result_label.text = ""
	var titan := prototype.get_tree().get_first_node_in_group("arena_bosses") as Area2D
	if titan != null:
		titan.set_physics_process(false)
		titan.health = 15
		titan.state = "dash_windup"
		titan.state_time = titan.TITAN_DASH_WINDUP
		titan.facing = 1
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_titan_regulator.png"):
		quit(1)
		return
	if titan != null:
		titan.state = "combo_second"
		titan.state_time = 0.12
		titan.queue_redraw()
	await create_timer(0.08).timeout
	if not _save("/tmp/kinetic_titan_swing.png"):
		quit(1)
		return
	prototype.player.reset_at(Vector2(10320, -1040))
	prototype.player.active = false
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_summit_ascent.png"):
		quit(1)
		return
	prototype.player.reset_at(Vector2(10950, -1590))
	prototype.player.active = false
	prototype.camera.reset_smoothing()
	await create_timer(0.12).timeout
	if not _save("/tmp/kinetic_clockwork_core.png"):
		quit(1)
		return
	print("KINETIC CAPTURE PASS: relay, dash, tower, five expansion areas, and Clockwork Core summit")
	prototype.free()
	await process_frame
	quit(0)

func _save(path: String) -> bool:
	var image := root.get_texture().get_image()
	return image != null and image.save_png(path) == OK
