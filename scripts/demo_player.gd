extends "res://scripts/yard_player.gd"

func _draw() -> void:
	super._draw()
	# Headlamp and scarf remain visible against beam/airflow, without changing
	# collision size, movement abilities or rebound height between levels.
	draw_rect(Rect2(-5, -10, 10, 3), Color("f2c879"))
	draw_rect(Rect2(facing * 3 - 1, -10, 3, 2), Color("fff3c6"))
	if velocity.y < -150:
		draw_line(Vector2(-facing * 4, 1), Vector2(-facing * 10, 6), Color("e77e65"), 2)
