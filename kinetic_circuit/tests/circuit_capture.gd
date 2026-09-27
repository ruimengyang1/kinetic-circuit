extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var level = (load("res://scenes/clockwork_tower.tscn") as PackedScene).instantiate()
	root.add_child(level)
	root.size = Vector2i(384, 216)
	for index in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_title.png")
	level._start_game()
	for index in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_intake.png")
	level.player.set_physics_process(false)
	level.player.global_position = Vector2(650, 329)
	level.camera.reset_smoothing()
	for index in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_core.png")
	level.player.global_position = Vector2(450, 329)
	level.camera.reset_smoothing()
	for index in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_pressure.png")
	level.player.global_position = Vector2(895, 329)
	level.camera.reset_smoothing()
	for index in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_signal.png")
	level.receivers["pressure"].add_impact(3, "charge")
	level.player.global_position = Vector2(520, 329)
	level.camera.reset_smoothing()
	for index in 14:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_guard_result.png")
	level.receivers["gallery"].add_impact(2, "projectile")
	level.receivers["core"].add_impact(3, "player")
	level.player.global_position = Vector2(650, 240)
	level.camera.reset_smoothing()
	for index in 25:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_core_ready.png")
	level.finished = true
	level._show_result()
	for index in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/private/tmp/circuit_victory.png")
	quit()
