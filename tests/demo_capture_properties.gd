extends SceneTree
# A declared fixture for secondary properties, separate from live route captures.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = 3
	game.hit_pause_enabled = false
	root.add_child(game)
	for i in 5: await physics_frame
	game.set_physics_process(false)
	game._freeze(true)
	game.boulder.position = Vector2(623, 302)
	game.player.position = Vector2(485, 308)
	game.can.position = Vector2(480, 306)
	game.machines.rotator.angle = (game.boulder.position - game.machines.rotator.beam_origin()).angle()
	for i in 3: await physics_frame
	game.machines.rotator._update_beam()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/final_demo/screenshots/L4_boulder_cover_fixture.png")
	print("SECONDARY BOULDER COVER actual ray hit Boulder: ", game.machines.rotator.beam_hit == game.boulder)
	var okay: bool = game.machines.rotator.beam_hit == game.boulder
	game.free()
	await process_frame
	quit(0 if okay else 1)
