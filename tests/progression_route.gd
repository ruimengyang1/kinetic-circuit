extends "res://tests/strategic_route.gd"

var right_withdrawal := false
var immediate_clearance := false

func _initialize() -> void:
	evidence_directory = "res://artifacts/level_progression"
	call_deferred("run")

func run() -> void:
	right_withdrawal = "--right" in OS.get_cmdline_user_args()
	immediate_clearance = "--immediate" in OS.get_cmdline_user_args()
	if right_withdrawal: evidence_directory += "/right"
	if immediate_clearance: evidence_directory += "/immediate"
	await super.run()

func weight() -> void:
	if not immediate_clearance:
		await super.weight()
		return
	# Spending cover immediately is viable too. Continue into the opened jet
	# rather than observing from the now-exposed floor; preparation is optional.
	await walk(407, true)
	for i in 240:
		if game.stats.boulder_impacts > 0: break
		await step(direction(407), dodge())
	if game.stats.boulder_impacts == 0: fail("immediate clearance requires directed Can force")
	await walk(342)
	for i in 180:
		if game.player.position.y < 126: break
		await step(direction(342))
	await walk(405)
	await settle(405, 146)
	await walk(529)
	await leap(590, 124)
	await walk(616)

func timing() -> void:
	if not right_withdrawal:
		await super.timing()
		return
	await place_can_on_rotator(351, 281)
	var rotor: Node2D = game.machines.rotator
	var goal: float = (game.machines.sensor.position - rotor.beam_origin()).angle()
	for i in 500:
		if rotor.angle >= goal - deg_to_rad(18): break
		await step()
	await walk(403)
	# Rise out of the acquisition lane after the commitment. This preserves
	# the right endpoint instead of accidentally steering Can back over its pedal.
	for i in 180:
		if game.can.intent_locked and game.can.facing > 0: break
		await step()
	var rebounds_before: int = game.stats.rebounds
	await step(1, true)
	for i in 180:
		if game.stats.rebounds > rebounds_before: break
		await step(direction(442))
	if game.stats.rebounds == rebounds_before: fail("right endpoint supplies a traversal rebound")
	if not game.machines.sensor.active: fail("right withdrawal preserves optical state")
	await settle(472, 249)
	await leap(515, 222)
	await walk(547)
	await leap(598, 194)
	await walk(617)

func live_capture() -> void:
	if game.level_index == 2:
		if game.can.position.x > 420 and not game.machines.rotator.occupied and game.machines.sensor.active:
			await capture("L3_right_endpoint")
		if game.stats.rebounds > 0: await capture("L3_endpoint_rebound")
	await super.live_capture()
