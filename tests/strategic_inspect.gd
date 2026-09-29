extends SceneTree

func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/strategic_depth/screenshots")
	var maps: Array[Dictionary] = []
	for index in 4:
		var game = load("res://scenes/final_demo.tscn").instantiate()
		game.start_level = index
		root.add_child(game)
		for i in 4: await physics_frame
		game.set_physics_process(false)
		game._freeze(true)
		game.controls.hide()
		maps.append({"level": index + 1, "geometry": game.geometry, "exit": game.exit_rect, "can": game.can.position,
			"machines": game.machines.keys(), "platforms": game.platforms.keys()})
		if DisplayServer.get_name() != "headless":
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://artifacts/strategic_depth/screenshots/layout_%d.png" % (index + 1))
		game.free()
		await process_frame
	var file := FileAccess.open("res://artifacts/strategic_depth/layouts.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(maps, "\t"))
	print("REBALANCE four fresh layouts inspected")
	quit()
