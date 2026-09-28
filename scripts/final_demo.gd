extends Node2D

const Player = preload("res://scripts/demo_player.gd")
const Can = preload("res://scripts/demo_can.gd")
const Boulder = preload("res://scripts/demo_boulder.gd")
const Machine = preload("res://scripts/demo_machine.gd")
const Platform = preload("res://scripts/demo_platform.gd")
const Effects = preload("res://scripts/effects.gd")
const Sound = preload("res://scripts/sfx.gd")
const PixelUI = preload("res://scripts/pixel_ui.gd")
const InputSetup = preload("res://scripts/foundry.gd")
const TITLES := ["1 — REDIRECT", "2 — WEIGHT", "3 — TIMING", "4 — COMBINE"]

@export var start_level := 0
var level_index := 0
var room: Node2D
var player: CharacterBody2D
var can: CharacterBody2D
var boulder: CharacterBody2D
var machines: Dictionary = {}
var platforms: Dictionary = {}
var geometry: Array[Rect2] = []
var exit_floor := 190.0
var exit_rect := Rect2()
var mode := "play"
var delay := 0.0
var elapsed := 0.0
var level_time := 0.0
var controls_time := 4.0
var pause_frames := 0
var hit_pause_enabled := true
var shake := 0.0
var clock := 0.0
var stats: Dictionary = {}
var completed: Array[Dictionary] = []
var attempts: Array[Dictionary] = []
var total_resets := 0
var total_deaths := 0
var events: Array[Dictionary] = []
var sound: Node
var effects: Node2D
var camera: Camera2D
var hud: Label
var controls: Label
var overlay: Label
var font: Font

func _ready() -> void:
	get_window().title = "Foundry / Future States — Learn the Can"
	get_window().content_scale_size = Vector2i(640, 360)
	var setup := InputSetup.new()
	setup._setup_inputs()
	setup.free()
	font = PixelUI.make_font()
	sound = Sound.new()
	add_child(sound)
	for item in [["commit", 105, 0.12, true], ["lock", 740, 0.06, false], ["clunk", 90, 0.19, true], ["roll", 126, 0.15, true], ["motor", 240, 0.11, true], ["light", 810, 0.16, false]]:
		sound.samples[item[0]] = sound._make_sound(item[1], item[2], 0.20, item[3])
	effects = Effects.new()
	effects.z_index = 9
	add_child(effects)
	camera = Camera2D.new()
	camera.position = Vector2(320, 180)
	add_child(camera)
	camera.make_current()
	_create_ui()
	_build_level(clampi(start_level, 0, 3))

func _build_level(index: int) -> void:
	if room != null: room.free()
	level_index = index
	room = Node2D.new()
	room.name = "FactoryLevel%d" % (index + 1)
	add_child(room)
	machines.clear()
	platforms.clear()
	geometry.clear()
	boulder = null
	level_time = 0
	stats = {"charges": 0, "impacts": 0, "boulder_impacts": 0, "rebounds": 0, "charging_rebounds": 0, "hits": 0, "resets": 0, "deaths": 0, "sensor_activations": 0, "idle_seconds": 0.0, "rotator_hold_seconds": 0.0}
	events.clear()
	pause_frames = 0
	shake = 0
	effects.particles.clear()
	_block(Rect2(-20, -10, 20, 410))
	_block(Rect2(640, -10, 20, 410))
	_block(Rect2(0, 50, 640, 10))
	if index == 3:
		_block(Rect2(0, 318, 245, 60))
		_block(Rect2(317, 318, 323, 60))
		_block(Rect2(245, 350, 72, 28))
	else: _block(Rect2(0, 318, 640, 60))
	match index:
		0: _redirect()
		1: _weight()
		2: _timing()
		3: _combine()
	player = Player.new()
	player.position = Vector2(46, 309)
	player.air_acceleration = 1700
	player.jumped.connect(func(_at: Vector2) -> void: sound.play("jump"))
	player.rebounded.connect(func(at: Vector2) -> void:
		stats.rebounds += 1
		if can.state == "charging": stats.charging_rebounds += 1
		_record("rebound")
		_feedback(at, "bounce", Color("fff1b3"), 10, 2)
	)
	player.health_changed.connect(func(value: int) -> void:
		if value < 3:
			stats.hits += 1
			_record("hurt")
			_feedback(player.position, "hit", Color("ff9470"), 8, 0)
	)
	player.died.connect(_death)
	room.add_child(player)
	player.strike_shape.size = Vector2(22, 14)
	can = Can.new()
	can.position = Vector2(90, 306)
	can.rail_right = [526.0, 278.0, 355.0, 610.0][index]
	can.telegraphed.connect(func() -> void: sound.play("telegraph"))
	can.direction_locked.connect(func(_side: int) -> void:
		sound.play("lock")
		_record("locked")
	)
	can.committed.connect(func() -> void:
		stats.charges += 1
		sound.play("commit")
		_record("charge")
	)
	can.impacted.connect(func(object: Node2D, _momentum: float) -> void:
		stats.impacts += 1
		_record("force")
		_feedback(object.position, "roll" if object == boulder else "clunk", Color("edb374"), 15, 3)
	)
	can.wall_impacted.connect(func(at: Vector2) -> void: _feedback(at, "hit", Color("edb374"), 6, 2))
	room.add_child(can)
	exit_rect = Rect2(601, exit_floor - 37, 33, 37)
	mode = "play"
	overlay.hide()
	_freeze(false)
	queue_redraw()

func _redirect() -> void:
	# Worker service gap = 20 px; Can body = 24 px. Force opens the Can lane.
	_platform("shutter", Rect2(232, 160, 18, 138), [Vector2(241, 99)], 210, true)
	_platform("freight", Rect2(451, 300, 76, 18), [Vector2(489, 199)], 180, true)
	_block(Rect2(360, 262, 52, 8), true)
	_block(Rect2(423, 229, 52, 8), true)
	_block(Rect2(566, 168, 74, 12), true)
	exit_floor = 168

func _weight() -> void:
	_add_boulder(Vector2(200, 302))
	var button := _machine("button", "button", Rect2(288, 313, 76, 9))
	var fan := _machine("fan", "fan", Rect2(376, 82, 66, 236))
	var shuttle := _platform("shuttle", Rect2(552, 198, 66, 14), [Vector2(409, 205), Vector2(327, 205)], 160)
	shuttle.hazard = true
	button.targets.assign([fan, shuttle])
	_block(Rect2(450, 146, 90, 9), true)
	_block(Rect2(574, 124, 66, 12), true)
	exit_floor = 124

func _timing() -> void:
	_machine("rotator", "rotator", Rect2(325, 312, 60, 9))
	var sensor := _machine("sensor", "sensor", Rect2(471, 158, 32, 32))
	var crossing := _platform("crossing", Rect2(385, 222, 76, 10), [Vector2(521, 227)], 170)
	sensor.targets.assign([crossing])
	_block(Rect2(281, 281, 94, 8), true)
	_block(Rect2(365, 249, 48, 8), true)
	_block(Rect2(584, 194, 56, 12), true)
	exit_floor = 194

func _combine() -> void:
	_add_boulder(Vector2(220, 302))
	var button := _machine("button", "button", Rect2(304, 313, 76, 9))
	var fan := _machine("fan", "fan", Rect2(464, 82, 66, 236))
	button.targets.assign([fan])
	_machine("rotator", "rotator", Rect2(240, 312, 60, 9))
	var sensor := _machine("sensor", "sensor", Rect2(448, 162, 32, 32))
	var lift := _platform("can_lift", Rect2(245, 318, 72, 10), [Vector2(281, 229)], 150)
	var crossing := _platform("crossing", Rect2(400, 180, 72, 10), [Vector2(542, 185)], 170)
	sensor.targets.assign([crossing, lift])
	_block(Rect2(246, 199, 98, 8), true)
	_block(Rect2(225, 280, 90, 8), true)
	_block(Rect2(317, 224, 99, 8), true)
	_block(Rect2(416, 206, 52, 8), true)
	_block(Rect2(588, 142, 52, 12), true)
	exit_floor = 142

func _add_boulder(at: Vector2) -> void:
	boulder = Boulder.new()
	boulder.position = at
	boulder.rolled.connect(func(_force: float) -> void:
		stats.boulder_impacts += 1
	)
	boulder.settled.connect(func() -> void:
		_feedback(boulder.position + Vector2(0, 12), "clunk", Color("c3ad83"), 5, 0)
		_record("Boulder settled")
	)
	room.add_child(boulder)

func _machine(id: String, kind: String, area: Rect2) -> Node2D:
	var machine := Machine.new()
	machine.configure(kind, area)
	machine.changed.connect(func(on: bool) -> void:
		if kind == "button":
			_feedback(machine.position, "clunk", Color("a9f4dd"), 7, 1)
		elif kind == "sensor" and on:
			stats.sensor_activations += 1
			_feedback(machine.position, "light", Color("a9f4dd"), 8, 1)
		_record(id + (" on" if on else " off"))
	)
	room.add_child(machine)
	machines[id] = machine
	if kind == "fan" and DisplayServer.get_name() != "headless":
		var stream: AudioStreamWAV = sound._make_sound(72, 0.6, 0.10, true)
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = stream.data.size() / 2
		machine.wind = AudioStreamPlayer.new()
		machine.wind.stream = stream
		machine.wind.volume_db = -17
		machine.add_child(machine.wind)
	return machine

func _platform(id: String, area: Rect2, path: Array[Vector2], speed: float, force: bool = false) -> Node2D:
	var platform := Platform.new()
	platform.configure(area, path, speed)
	platform.force_operated = force
	platform.started.connect(func() -> void: sound.play("motor"))
	platform.arrived.connect(func() -> void: sound.play("clunk"))
	room.add_child(platform)
	platforms[id] = platform
	return platform

func _block(area: Rect2, one_way: bool = false) -> void:
	geometry.append(area)
	var body := StaticBody2D.new()
	body.position = area.get_center()
	body.collision_layer = 1
	var shape := RectangleShape2D.new()
	shape.size = area.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.one_way_collision = one_way
	body.add_child(collision)
	room.add_child(body)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		if Input.is_key_pressed(KEY_SHIFT) or mode == "complete":
			completed.clear()
			elapsed = 0
			_reload(0)
		else:
			total_resets += 1
			stats.resets += 1
			attempts.append(metrics())
			_reload(level_index)
	if Input.is_action_just_pressed("pause") and mode in ["play", "paused"]:
		mode = "paused" if mode == "play" else "play"
		_freeze(mode == "paused")
		overlay.text = "PAUSED\n\nESC RESUME   R RETRY LEVEL"
		overlay.visible = mode == "paused"
	if Input.is_action_just_pressed("hint"): controls_time = 4
	if mode in ["clear", "dead"]:
		delay -= delta
		if delay <= 0:
			if mode == "clear" and level_index == 3:
				mode = "complete"
				overlay.text = "YOU KNOW THE MACHINE\n\nOUT OF THE FOUNDRY\n\nR PLAY AGAIN"
				overlay.show()
			else: _reload(level_index + 1 if mode == "clear" else level_index)
		return
	if mode != "play": return
	elapsed += delta
	level_time += delta
	clock += delta
	controls_time = maxf(0, controls_time - delta)
	controls.visible = controls_time > 0
	if pause_frames > 0:
		pause_frames -= 1
		_freeze(pause_frames > 0)
	shake = maxf(0, shake - delta * 4)
	camera.offset = Vector2(sin(clock * 83), cos(clock * 71)) * shake * 5
	if absf(player.velocity.x) < 8 and absf(player.velocity.y) < 8: stats.idle_seconds += delta
	if machines.has("rotator") and machines.rotator.occupied: stats.rotator_hold_seconds += delta
	if boulder != null and absf(boulder.velocity.x) > 35 and int(clock * 18) != int((clock - delta) * 18):
		effects.burst(boulder.position + Vector2(0, 13), Color("8c7e6d"), 2)
	if player.position.y > 388 or can.position.y > 388: player.kill()
	# Intentional walk into an actual exit alcove on its real floor. No
	# mechanism flags; grazing the doorway in midair cannot complete a level.
	if player.is_on_floor() and exit_rect.has_point(player.position) and absf(player.position.y + 9 - exit_floor) < 2 and Input.is_action_pressed("move_right"):
		_success()
	hud.text = TITLES[level_index] + "     " + ("●".repeat(player.health) if player.health > 0 else "")
	queue_redraw()

func _reload(index: int) -> void:
	mode = "loading"
	_freeze(true)
	call_deferred("_build_level", index)

func _death() -> void:
	if mode != "play": return
	stats.deaths += 1
	total_deaths += 1
	_record("death")
	attempts.append(metrics())
	mode = "dead"
	delay = 0.25
	_freeze(true)
	sound.play("death")

func _success() -> void:
	_record("exit")
	completed.append(metrics())
	mode = "clear"
	delay = 0.65
	_freeze(true)
	sound.play("win")
	effects.burst(player.position, Color("a9f4dd"), 16)

func _freeze(value: bool) -> void:
	if player != null: player.active = not value
	if can != null: can.suspended = value
	if boulder != null: boulder.suspended = value
	for platform in platforms.values(): platform.suspended = value
	for machine in machines.values():
		machine.suspended = value
		if machine.wind != null: machine.wind.stream_paused = value

func _feedback(at: Vector2, cue: String, color: Color, count: int, hit_pause: int) -> void:
	if sound == null: return
	sound.play(cue)
	effects.burst(at, color, count)
	shake = 0.8
	pause_frames = maxi(pause_frames, hit_pause) if hit_pause_enabled else 0
	if hit_pause > 0 and hit_pause_enabled: _freeze(true)

func _record(event: String) -> void:
	if can == null or player == null: return
	events.append({"event": event, "seconds": snappedf(level_time, 0.01), "player": player.position, "can": can.position, "can_state": can.state, "boulder": boulder.position if boulder != null else Vector2.ZERO, "laser_angle": rad_to_deg(machines.rotator.angle) if machines.has("rotator") else 0, "sensor": machines.sensor.active if machines.has("sensor") else false})

func metrics() -> Dictionary:
	var result := stats.duplicate()
	result.merge({"level": level_index + 1, "seconds": snappedf(level_time, 0.01), "events": events.duplicate(true)})
	return result

func _create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(12, 10)
	PixelUI.style_label(hud, font, 11, Color("edc27a"))
	layer.add_child(hud)
	controls = Label.new()
	controls.position = Vector2(12, 29)
	controls.text = "A/D MOVE   SPACE JUMP   J/X STOMP   R RETRY   ESC PAUSE"
	PixelUI.style_label(controls, font, 9, Color("9ac6c7"))
	layer.add_child(controls)
	overlay = Label.new()
	overlay.position = Vector2(182, 112)
	overlay.size = Vector2(276, 110)
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	PixelUI.style_label(overlay, font, 12, Color("fff1b3"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("172937")
	panel.content_margin_top = 16
	overlay.add_theme_stylebox_override("normal", panel)
	layer.add_child(overlay)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 380), Color("101e2b"))
	for x in range(18, 640, 90):
		draw_rect(Rect2(x, 65, 6, 275), Color("213845"))
		draw_rect(Rect2(x - 4, 66, 14, 5), Color("385363"))
		draw_arc(Vector2(x + 44, 92), 21, 0, TAU, 24, Color("263f4c"), 3)
	draw_line(Vector2(0, 59), Vector2(640, 59), Color("385363"), 4)
	for area in geometry:
		draw_rect(area, Color("2c4554"))
		draw_rect(Rect2(area.position, Vector2(area.size.x, 3)), Color("c59762"))
		for x in range(int(area.position.x + 8), int(area.end.x), 20): draw_rect(Rect2(x, area.position.y + 1, 2, 2), Color("f0ca8a"))
	if can != null:
		draw_line(Vector2(24, 321), Vector2(can.rail_right, 321), Color("657e83"), 2)
		for x in [24.0, can.rail_right]:
			draw_rect(Rect2(x - 4, 318, 8, 7), Color("e3b774"))
		if can.state in ["windup", "charging"]:
			var color := Color("fff1b3", 0.5) if can.intent_locked else Color("ff785e", 0.4)
			var end := clampf(can.position.x + can.facing * 265, 24, can.rail_right)
			for x in range(int(minf(can.position.x, end)), int(maxf(can.position.x, end)), 13):
				draw_line(Vector2(x, can.position.y + 15), Vector2(x + 6, can.position.y + 15), color, 1)
	if machines.has("button"):
		var button: Node2D = machines.button
		var tint := Color("a9f4dd") if button.active else Color("5d747c")
		for target in button.targets:
			var base := Vector2(button.position.x, 335)
			var tip: Vector2 = target.home if target is AnimatableBody2D else target.position
			draw_line(button.position + Vector2(0, 8), base, tint, 2)
			draw_line(base, Vector2(tip.x, 335), tint, 2)
			draw_line(Vector2(tip.x, 335), tip, tint, 2)
	if machines.has("sensor"):
		var sensor: Node2D = machines.sensor
		var tint := Color("a9f4dd") if sensor.active else Color("5d747c")
		for target in sensor.targets:
			draw_line(sensor.position + Vector2(16, 0), Vector2(target.home.x, sensor.position.y), tint, 1)
			draw_line(Vector2(target.home.x, sensor.position.y), target.home, tint, 1)
	var entry := Vector2(598, exit_floor - 38)
	draw_rect(Rect2(entry, Vector2(38, 38)), Color("416d83"))
	draw_rect(Rect2(entry + Vector2(5, 5), Vector2(28, 33)), Color("a9f4dd"))
	draw_rect(Rect2(entry + Vector2(9, 8), Vector2(20, 30)), Color("203c46"))
	draw_string(font, entry + Vector2(-3, -7), "EXIT →", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a9f4dd"))
