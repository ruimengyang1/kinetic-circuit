extends "res://scripts/final_demo.gd"

# Objective-free feel fixture. Uses the shipping actors, sounds and impact
# scheduler; it adds no mechanic and is never part of the four-room progression.
func _build_level(_index: int) -> void:
	super._build_level(0)
	for child in room.get_children():
		if child is StaticBody2D or child is AnimatableBody2D: child.free()
	platforms.clear()
	geometry.clear()
	_block(Rect2(-20, -10, 20, 410))
	_block(Rect2(640, -10, 20, 410))
	_block(Rect2(0, 318, 640, 60))
	player.position = Vector2(220, 309)
	player.previous_position = player.position
	player.previous_feet = 318
	can.position = Vector2(320, 306)
	can.rail_right = 616
	exit_rect = Rect2()
	hud.hide()
	controls.text = "A/D MOVE   SPACE JUMP   J/X STOMP   R RESET   ESC PAUSE"
	controls_time = 9999

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("101e2b"))
	draw_rect(Rect2(0, 318, 640, 42), Color("2c4554"))
	draw_line(Vector2(0, 318), Vector2(640, 318), Color("c59762"), 3)
