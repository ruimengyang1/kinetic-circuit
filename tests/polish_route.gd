extends "res://tests/rebalance_route.gd"

# Reuse the same input-only routes while preserving rebalance evidence.
func run() -> void:
	evidence_directory = "res://artifacts/polish/after"
	await super.run()

func live_capture() -> void:
	await super.live_capture()
	if game.player.bounce_pose > 0: await capture("L%d_bounce" % (game.level_index + 1))
