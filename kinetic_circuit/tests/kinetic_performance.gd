extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var level: Node = (load("res://scenes/kinetic_prototype.tscn") as PackedScene).instantiate()
	root.add_child(level)
	await physics_frame
	await physics_frame
	level._update_runtime_activation(0.0, true)

	var cullables := get_nodes_in_group("runtime_cullables")
	var start_active: int = level.runtime_active_count
	var start_sleeping: int = level.runtime_sleeping_count
	_check(cullables.size() >= 60, "all animated enemies, lifts, carriage machinery, and saws participate in runtime culling")
	_check(start_sleeping >= 50 and start_active <= 12, "the opening only processes its local machinery (%d active, %d sleeping)" % [start_active, start_sleeping])
	var start_bounds: Rect2 = level._world_view_bounds(level.DRAW_MARGIN)
	_check(start_bounds.size.x <= 650.0 and start_bounds.size.y <= 420.0, "animated drawing is bounded to the viewport plus a small safety margin")
	var visible_blocks := 0
	for rect in level.blocks:
		if rect.grow(40.0).intersects(start_bounds):
			visible_blocks += 1
	_check(visible_blocks < level.blocks.size() / 3, "the renderer rejects most off-screen platform art at the opening (%d of %d visible)" % [visible_blocks, level.blocks.size()])

	var bosses: Array = get_nodes_in_group("arena_bosses")
	_check(bosses.size() == 1 and not bosses[0].is_physics_processing(), "the distant Titan Regulator begins asleep")
	level.player.reset_at(Vector2(9200, -120))
	await physics_frame
	level._update_runtime_activation(0.0, true)
	_check(bosses[0].is_physics_processing(), "the Titan Regulator wakes before entering interaction range")
	_check(not level.ram.is_physics_processing() and not level.carriage.is_physics_processing(), "opening machinery sleeps while the arena is active")

	level.player.reset_at(Vector2(10320, -1040))
	await physics_frame
	level._update_runtime_activation(0.0, true)
	_check(not bosses[0].is_physics_processing(), "the arena guardian returns to sleep during the Summit Ascent")
	_check(level.BACKGROUND_REDRAW_INTERVAL >= 1.0 / 30.0, "procedural background animation is capped at thirty refreshes per second")

	level.free()
	await process_frame
	if failures.is_empty():
		print("KINETIC PERFORMANCE PASS: viewport drawing, 30 Hz scenery, and distance-based runtime sleeping (%d active / %d sleeping at start)" % [start_active, start_sleeping])
		quit(0)
	else:
		for failure in failures:
			printerr("KINETIC PERFORMANCE FAIL: ", failure)
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
