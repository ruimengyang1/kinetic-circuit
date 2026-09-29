extends "res://tests/precision_route.gd"

# Fresh starts, identical abilities/information, player inputs only. These are
# rehearsals; no assertion about first-time human learning or enjoyment.
func run() -> void:
	output_dir = "res://artifacts/final_rescue"
	await super.run()

func inspect() -> void:
	if not expert or "--equal-inspection" in OS.get_cmdline_user_args():
		mark("inspect result")
		for i in inspect_frames: await step()

func position_room() -> void:
	if not expert:
		mark("choose immediate door progress before boarding preparation")
		await super.position_room()
		return
	mark("same initial state; prepare useful future impact endpoint")
	await walk(110)
	await settle(110, 318)
	for i in 120:
		if game.can.state == "lock" and game.can.facing < 0: break
		await step()
	await safe_perch(175)
	for i in 180:
		if game.machines.button.active: break
		await step()
	if not game.machines.button.active: fail("left endpoint must lower boarding")
	await inspect()
	for i in 160:
		if game.platforms.boarding.position.y >= 280: break
		await step()
	mark("board before opening; next impact also supplies crossing")
	await walk(110)
	await settle(110, 281)
	for i in 200:
		if game.player.position.y + 9 <= 219: break
		await step()
	await wait_power("shutter")
	if not game.machines.crossing_button.active: fail("impact endpoint must remain useful weight")
	await leap(192, 180)
	await upper_crossing()

func combination_room() -> void:
	# Earlier rooms have no gate-order modifier. The reactive style selects
	# valid immediate door progress here, then deals with its farther return.
	early_gate = not expert or "--early-gate" in OS.get_cmdline_user_args()
	mark("choose early gate / farther return" if early_gate else "reserve impact / prepare close next departure")
	await super.combination_room()
