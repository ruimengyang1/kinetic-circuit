extends SceneTree

# Geometry inspection before authoring completion routes. With a renderer,
# captures the four fresh layouts; headless prints machine/exit positions.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://artifacts/final_demo/screenshots")
	var maps: Array[Dictionary] = []
	for index in 4:
		var level = load("res://scenes/final_demo.tscn").instantiate()
		level.start_level = index
		root.add_child(level)
		for i in 4: await physics_frame
		level.set_physics_process(false)
		level._freeze(true)
		level.controls.hide()
		var machines: Dictionary = {}
		for id in level.machines: machines[id] = level.machines[id].position
		maps.append({"level": index + 1, "geometry": level.geometry, "machines": machines, "exit": level.exit_rect, "can": level.can.position})
		if DisplayServer.get_name() != "headless":
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://artifacts/final_demo/screenshots/layout_%d.png" % (index + 1))
		for voice in level.sound.get_children():
			if voice is AudioStreamPlayer: voice.stop()
		level.free()
		await process_frame
	var file := FileAccess.open("res://artifacts/final_demo/layouts.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(maps, "\t"))
	file.close()
	print("FINAL DEMO LAYOUT INSPECTION: four maps, before completion-route scripts")
	quit()
