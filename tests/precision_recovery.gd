extends "res://tests/precision_route.gd"
# Input-only planning mistake and deliberate recovery. No world assignments.
func _initialize() -> void: call_deferred("exercise")
func wait_end(x: float) -> void:
	for i in 180:
		if absf(game.can.position.x - x) < 0.3 and game.can.state in ["impact", "recover", "idle"]: return
		await step()
	fail("recovery endpoint %.0f" % x)
func low_lure(x: float, side: int) -> void:
	await walk(x)
	await settle(x, 318)
	for i in 120:
		if game.can.state == "lock" and game.can.facing == side: break
		await step()
	await safe_perch(203)
func exercise() -> void:
	expert = true
	game = load("res://scenes/final_demo.tscn").instantiate()
	game.start_level = 1
	root.add_child(game)
	await step()
	await open_initial_shutter()
	await low_lure(110, -1)
	await wait_end(24)
	# Call Can away from the ground, before boarding the low lift.
	mark("planning mistake: spend boarding state while still below")
	await low_lure(220, 1)
	await wait_end(272)
	for i in 55: await step()
	if not game.machines.crossing_button.active or game.machines.button.active: fail("mistake should leave crossing ready and boarding unavailable")
	if not game.completed.is_empty(): fail("unboarded state cannot complete")
	var wrong: Vector2 = game.can.position
	mark("restore previous useful endpoint")
	await low_lure(220, -1)
	await wait_end(24)
	for i in 140:
		if game.platforms.boarding.position.y >= 280: break
		await step()
	mark("board before spending it again")
	await walk(110)
	await settle(110, 281)
	for i in 180:
		if game.player.position.y + 9 <= 219: break
		await step()
	await leap(192, 180)
	await upper_crossing()
	if game.mode != "clear" or game.stats.charges != 5 or game.stats.hits != 0: fail("restored plan must finish with two corrective charges and no damage")
	var file := FileAccess.open(output_dir + "/planning_recovery.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"input_only": true, "wrong_endpoint": wrong, "metrics": game.metrics(), "notes": notes, "failures": failures, "trace": trace}, "\t"))
	print("PLANNING RECOVERY charges=", game.stats.charges, " failures=", failures)
	game.free()
	quit(0 if failures.is_empty() else 1)
