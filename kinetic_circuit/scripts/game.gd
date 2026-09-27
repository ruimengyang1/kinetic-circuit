extends Node2D

const LevelScene = preload("res://scripts/level.gd")
const PlayerScene = preload("res://scripts/player.gd")
const EffectsScene = preload("res://scripts/effects.gd")
const SfxScene = preload("res://scripts/sfx.gd")

const START_POSITION := Vector2(48, 470)
const PROGRESS_PATH := "user://progress.cfg"
const LEVEL_COUNT := 2
const SLOW_MOTION_SCALE := 0.35
const SLOW_MOTION_CAPACITY := 4.0
const SLOW_MOTION_RECHARGE_RATE := 0.7
const DEATH_RESPAWN_DELAY := 0.72
const DEATH_CAMERA_ZOOM := Vector2(1.42, 1.42)

var level: Node2D
var player: CharacterBody2D
var effects: Node2D
var sfx: Node
var camera: Camera2D
var mode := "level_select"
var checkpoint := START_POSITION
var checkpoint_index := 0
var stage_number := 1
var unlocked_level := 1
var selected_level := 1
var completed_levels := 0
var elapsed := 0.0
var slow_motion_active := false
var slow_motion_energy := SLOW_MOTION_CAPACITY
var slow_motion_button_down := false

var hud_label: Label
var help_label: Label
var slow_tint: ColorRect
var slow_label: Label
var slow_bar: ProgressBar
var overlay: ColorRect
var overlay_title: Label
var overlay_body: Label
var death_label: Label
var death_camera_tween: Tween

func _ready() -> void:
	_restore_time_scale()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_inputs()
	sfx = SfxScene.new()
	add_child(sfx)
	_create_level()
	player = PlayerScene.new()
	player.position = START_POSITION
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	player.rebounded.connect(_on_rebounded)
	player.attack_connected.connect(_on_attack_connected)
	player.dashed.connect(_on_dashed)
	player.dash_connected.connect(_on_dash_connected)
	player.jumped.connect(func(_point: Vector2) -> void: sfx.play("jump"))
	add_child(player)
	camera = Camera2D.new()
	camera.position = Vector2(0, -12)
	camera.limit_left = 0
	camera.limit_right = int(level.world_width)
	camera.limit_top = 160
	camera.limit_bottom = 530
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	camera.make_current()
	effects = EffectsScene.new()
	add_child(effects)
	_create_ui()
	_load_progress()
	selected_level = unlocked_level
	_open_level_select("CLOCKWORK ASCENT")
	get_tree().paused = true

func _exit_tree() -> void:
	_restore_time_scale()

func _process(delta: float) -> void:
	var real_delta := delta / SLOW_MOTION_SCALE if slow_motion_active else delta
	_update_slow_motion(delta)
	if mode == "play":
		elapsed += real_delta
		if Input.is_action_just_pressed("pause"):
			_set_slow_motion(false)
			mode = "paused"
			get_tree().paused = true
			_show_overlay("PAUSED", "ESC / START  TO RESUME\nR  TO RETRY FROM CHECKPOINT")
		elif Input.is_action_just_pressed("restart"):
			_retry_checkpoint()
	elif mode == "level_select":
		if Input.is_action_just_pressed("move_left"):
			selected_level = maxi(1, selected_level - 1)
			_update_level_select()
		elif Input.is_action_just_pressed("move_right"):
			selected_level = mini(unlocked_level, selected_level + 1)
			_update_level_select()
		elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
			_start_selected_level()
	elif mode == "paused":
		if Input.is_action_just_pressed("pause"):
			mode = "play"
			get_tree().paused = false
			overlay.hide()
		elif Input.is_action_just_pressed("restart"):
			get_tree().paused = false
			_retry_checkpoint()
	if mode == "play" and player.global_position.y > 565.0:
		_on_lethal_hazard()
	_update_hud()

func _set_slow_motion(active: bool) -> void:
	slow_motion_active = active
	Engine.time_scale = SLOW_MOTION_SCALE if active else 1.0
	AudioServer.playback_speed_scale = SLOW_MOTION_SCALE if active else 1.0
	if slow_tint != null:
		slow_tint.visible = active
	_update_slow_motion_ui()

func _update_slow_motion(delta: float) -> void:
	var real_delta := delta / SLOW_MOTION_SCALE if slow_motion_active else delta
	var button_pressed := Input.is_action_pressed("slow_motion")
	if mode != "play":
		if slow_motion_active:
			_set_slow_motion(false)
		slow_motion_button_down = button_pressed
		return
	if button_pressed and not slow_motion_button_down:
		_set_slow_motion(not slow_motion_active and slow_motion_energy > 0.0)
	slow_motion_button_down = button_pressed
	if slow_motion_active:
		slow_motion_energy = maxf(0.0, slow_motion_energy - real_delta)
		if is_zero_approx(slow_motion_energy):
			_set_slow_motion(false)
	else:
		slow_motion_energy = minf(SLOW_MOTION_CAPACITY, slow_motion_energy + delta * SLOW_MOTION_RECHARGE_RATE)
	_update_slow_motion_ui()

func _update_slow_motion_ui() -> void:
	if slow_bar != null:
		slow_bar.value = slow_motion_energy
	if slow_label != null:
		slow_label.add_theme_color_override("font_color", Color("fff1ac") if slow_motion_active else Color("7fa3aa"))

func _reset_slow_motion_meter() -> void:
	_set_slow_motion(false)
	slow_motion_energy = SLOW_MOTION_CAPACITY
	_update_slow_motion_ui()

func _restore_time_scale() -> void:
	slow_motion_active = false
	Engine.time_scale = 1.0
	AudioServer.playback_speed_scale = 1.0

func _start_game() -> void:
	_start_stage(1)

func _start_selected_level() -> void:
	_start_stage(selected_level)

func _start_stage(number: int) -> void:
	_reset_slow_motion_meter()
	stage_number = clampi(number, 1, unlocked_level)
	checkpoint = START_POSITION
	checkpoint_index = 0
	elapsed = 0.0
	player.dash_enabled = stage_number == 2
	_rebuild_level()
	player.reset_at(START_POSITION)
	_reset_death_presentation()
	camera.limit_right = int(level.world_width)
	camera.reset_smoothing()
	mode = "play"
	get_tree().paused = false
	overlay.hide()

func _new_run() -> void:
	_start_stage(1)

func _start_second_stage() -> void:
	_start_stage(2)

func _retry_checkpoint() -> void:
	if mode == "dead":
		return
	mode = "dead"
	get_tree().paused = false
	overlay.hide()
	player.kill()

func _on_player_died() -> void:
	if mode == "level_select":
		return
	_set_slow_motion(false)
	mode = "dead"
	effects.burst(player.global_position, Color("e9876c"), 15)
	sfx.play("death")
	death_label.text = "SYSTEM FAILURE\nREWINDING  %s" % _format_time(elapsed)
	death_label.show()
	if death_camera_tween != null and death_camera_tween.is_valid():
		death_camera_tween.kill()
	death_camera_tween = create_tween()
	death_camera_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	death_camera_tween.tween_property(camera, "zoom", DEATH_CAMERA_ZOOM, 0.2)
	get_tree().create_timer(DEATH_RESPAWN_DELAY).timeout.connect(_finish_respawn)

func _finish_respawn() -> void:
	if mode != "dead":
		return
	_reset_slow_motion_meter()
	player.reset_at(checkpoint)
	_rebuild_level()
	_reset_death_presentation()
	camera.reset_smoothing()
	mode = "play"

func _create_level() -> void:
	level = LevelScene.new()
	level.stage_number = stage_number
	add_child(level)
	move_child(level, 0)
	level.player_touched_enemy.connect(_on_player_touched_enemy)
	level.lethal_hazard.connect(_on_lethal_hazard)
	level.checkpoint_reached.connect(_on_checkpoint_reached)
	level.stage_finished.connect(_on_stage_finished)
	level.enemy_defeated.connect(_on_enemy_defeated)
	level.device_activated.connect(_on_device_activated)
	level.set_active_checkpoint(checkpoint_index)

func _rebuild_level() -> void:
	level.free()
	_create_level()

func _on_player_touched_enemy(source: Vector2) -> void:
	if mode == "play":
		player.take_damage(source)

func _on_lethal_hazard() -> void:
	if mode == "play":
		player.take_hazard_damage()

func _on_checkpoint_reached(at: Vector2, index: int) -> void:
	if mode != "play" or index <= checkpoint_index:
		return
	checkpoint = at
	checkpoint_index = index
	sfx.play("checkpoint")
	effects.burst(at + Vector2(0, -16), Color("a2f0cf"), 14)

func _on_stage_finished() -> void:
	if mode != "play":
		return
	_set_slow_motion(false)
	sfx.play("win")
	effects.burst(player.global_position, Color("fff1ac"), 22)
	get_tree().paused = true
	completed_levels |= 1 << (stage_number - 1)
	unlocked_level = maxi(unlocked_level, mini(LEVEL_COUNT, stage_number + 1))
	selected_level = mini(LEVEL_COUNT, stage_number + 1)
	_save_progress()
	_open_level_select("LEVEL %d COMPLETE  %s" % [stage_number, _format_time(elapsed)])

func _on_enemy_defeated(at: Vector2) -> void:
	effects.burst(at, Color("e9b96f"), 12)
	sfx.play("hit")

func _on_device_activated(at: Vector2) -> void:
	effects.burst(at, Color("fff1ac"), 8)

func _on_rebounded(at: Vector2) -> void:
	effects.burst(at, Color("f6d68c"), 9)
	sfx.play("bounce")

func _on_attack_connected(at: Vector2) -> void:
	effects.impact(at, Color("f6d68c"), player.attack_direction)
	sfx.play("attack_hit")

func _on_dashed(at: Vector2) -> void:
	effects.burst(at, Color("a9f4dd"), 7)
	sfx.play("dash")

func _on_dash_connected(at: Vector2) -> void:
	effects.impact(at, Color("a9f4dd"), player.dash_direction)

func _on_health_changed(value: int) -> void:
	if value < 3 and value > 0:
		effects.burst(player.global_position, Color("e9876c"), 8)
		sfx.play("hit")
	_update_hud()

func _load_progress() -> void:
	var progress := ConfigFile.new()
	if progress.load(PROGRESS_PATH) == OK:
		unlocked_level = clampi(int(progress.get_value("progress", "unlocked_level", 1)), 1, LEVEL_COUNT)
		completed_levels = int(progress.get_value("progress", "completed_levels", 1 if unlocked_level >= 2 else 0))

func _save_progress() -> void:
	var progress := ConfigFile.new()
	progress.set_value("progress", "unlocked_level", unlocked_level)
	progress.set_value("progress", "completed_levels", completed_levels)
	progress.save(PROGRESS_PATH)

func _open_level_select(title: String) -> void:
	_set_slow_motion(false)
	mode = "level_select"
	get_tree().paused = true
	selected_level = clampi(selected_level, 1, unlocked_level)
	overlay_title.text = title
	_update_level_select()

func _update_level_select() -> void:
	var first_cursor := ">" if selected_level == 1 else " "
	var second_cursor := ">" if selected_level == 2 else " "
	var first_status := "  [CLEARED]" if completed_levels & 1 else ""
	var second_status := "  [LOCKED]" if unlocked_level < 2 else "  [CLEARED]" if completed_levels & 2 else ""
	overlay_body.text = "%s  LEVEL 1   FOUNDRY%s\n%s  LEVEL 2   RELAY SHAFT%s\n\nA / D OR ARROWS  SELECT\nENTER / SPACE / GAMEPAD A  START" % [first_cursor, first_status, second_cursor, second_status]
	overlay.show()

func _create_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	slow_tint = ColorRect.new()
	slow_tint.position = Vector2.ZERO
	slow_tint.size = Vector2(384, 216)
	slow_tint.color = Color(0.2, 0.55, 0.68, 0.1)
	slow_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slow_tint.hide()
	canvas.add_child(slow_tint)
	hud_label = _label(Vector2(10, 8), Vector2(365, 17), 10, Color("f5dfa8"))
	canvas.add_child(hud_label)
	slow_label = _label(Vector2(284, 27), Vector2(32, 12), 7, Color("7fa3aa"))
	slow_label.text = "SLOW"
	slow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	canvas.add_child(slow_label)
	slow_bar = _slow_motion_bar(Vector2(322, 30))
	canvas.add_child(slow_bar)
	slow_bar.size = Vector2(53, 5)
	help_label = _label(Vector2(9, 195), Vector2(366, 15), 8, Color("b6c4bf"))
	help_label.text = "WASD MOVE/AIM   SPACE JUMP   J/X ATTACK   ESC PAUSE"
	canvas.add_child(help_label)
	death_label = _label(Vector2(42, 67), Vector2(300, 58), 18, Color("ff9a78"))
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.hide()
	canvas.add_child(death_label)
	overlay = ColorRect.new()
	overlay.position = Vector2.ZERO
	overlay.size = Vector2(384, 216)
	overlay.color = Color(0.055, 0.1, 0.14, 0.91)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(overlay)
	overlay_title = _label(Vector2(22, 49), Vector2(340, 29), 21, Color("f1c883"))
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.add_child(overlay_title)
	overlay_body = _label(Vector2(25, 93), Vector2(334, 100), 10, Color("d1d9cb"))
	overlay_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay.add_child(overlay_body)
	_update_hud()

func _label(at: Vector2, dimensions: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("162230"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label

func _slow_motion_bar(at: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = at
	bar.max_value = SLOW_MOTION_CAPACITY
	bar.step = 0.001
	bar.value = slow_motion_energy
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color("203945")
	background.border_width_left = 1
	background.border_width_top = 1
	background.border_width_right = 1
	background.border_width_bottom = 1
	background.border_color = Color("557681")
	bar.add_theme_stylebox_override("background", background)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("a9f4dd")
	bar.add_theme_stylebox_override("fill", fill)
	return bar

func _show_overlay(title: String, body: String) -> void:
	overlay_title.text = title
	overlay_body.text = body
	overlay.show()

func _reset_death_presentation() -> void:
	if death_camera_tween != null and death_camera_tween.is_valid():
		death_camera_tween.kill()
	death_camera_tween = null
	if is_instance_valid(camera):
		camera.zoom = Vector2.ONE
		camera.position = Vector2(0, -12)
	if death_label != null:
		death_label.hide()

func _format_time(value: float) -> String:
	var total_tenths := maxi(0, int(floor(value * 10.0)))
	var minutes := int(total_tenths / 600)
	var seconds := int(total_tenths / 10) % 60
	var tenths := total_tenths % 10
	return "%02d:%02d.%d" % [minutes, seconds, tenths]

func _update_hud() -> void:
	if hud_label == null or player == null:
		return
	hud_label.text = "HP %d/3   LEVEL %d   %s   TIME %s" % [player.health, stage_number, "DASH READY" if player.dash_ready else "DASH SPENT" if stage_number == 2 else "CLOCKWORK", _format_time(elapsed)]
	if help_label != null:
		help_label.text = "RMB OR WASD+K/C DASH  J/X ATTACK  Q SLOW  R RETRY" if stage_number == 2 else "WASD MOVE/AIM  SPACE JUMP  J/X ATTACK  Q SLOW"

func _setup_inputs() -> void:
	_add_action("move_left", 0.2)
	_add_action("move_right", 0.2)
	_add_action("aim_up", 0.2)
	_add_action("aim_down", 0.2)
	_add_action("jump")
	_add_action("attack")
	_add_action("dash")
	_add_action("slow_motion")
	_add_action("pause")
	_add_action("restart")
	_add_key("move_left", KEY_A)
	_add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_D)
	_add_key("move_right", KEY_RIGHT)
	_add_key("aim_up", KEY_W)
	_add_key("aim_up", KEY_UP)
	_add_key("aim_down", KEY_S)
	_add_key("aim_down", KEY_DOWN)
	_add_key("jump", KEY_SPACE)
	_add_key("attack", KEY_J)
	_add_key("attack", KEY_X)
	_add_key("dash", KEY_K)
	_add_key("dash", KEY_C)
	_add_key("slow_motion", KEY_Q)
	_add_key("pause", KEY_ESCAPE)
	_add_key("restart", KEY_R)
	_add_pad_button("move_left", 13)
	_add_pad_button("move_right", 14)
	_add_pad_button("aim_up", 11)
	_add_pad_button("aim_down", 12)
	_add_pad_axis("move_left", 0, -1.0)
	_add_pad_axis("move_right", 0, 1.0)
	_add_pad_axis("aim_up", 1, -1.0)
	_add_pad_axis("aim_down", 1, 1.0)
	_add_pad_button("jump", 0)
	_add_pad_button("attack", 2)
	_add_pad_button("dash", 1)
	_add_pad_button("pause", 6)
	_add_pad_button("restart", 3)

func _add_action(action: String, deadzone: float = 0.5) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, deadzone)

func _add_key(action: String, keycode: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _add_pad_button(action: String, button: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)

func _add_pad_axis(action: String, axis: int, axis_value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	InputMap.action_add_event(action, event)
