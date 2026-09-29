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
const TITLES := ["1 — DIRECTION", "2 — POSITION", "3 — TIMING", "4 — COMBINATION"]

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
var observed_can_state := "idle"
var observed_rotor_occupied := false
var rotor_visits := 0
var charge_effects: Dictionary = {}
var observed_air_blocked := false
var sound: Node
var effects: Node2D
var camera: Camera2D
var hud: Label
var controls: Label
var lesson: Label
var overlay: Label
var font: Font

func _ready() -> void:
	# Apply impact pauses at a frame boundary, before moving supports. Freezing
	# midway through a force-transfer callback can strand Boulder on a panel.
	process_physics_priority = -20
	get_window().title = "Foundry — Direction / Position / Timing"
	get_window().content_scale_size = Vector2i(640, 360)
	var setup := InputSetup.new()
	setup._setup_inputs()
	setup.free()
	font = PixelUI.make_font()
	sound = Sound.new()
	add_child(sound)
	for item in [["commit", 105, 0.12, true], ["lock", 740, 0.06, false], ["clunk", 90, 0.14, true], ["roll", 126, 0.15, true], ["motor", 240, 0.11, true], ["light", 810, 0.16, false], ["telegraph", 325, 0.48, true], ["engage", 210, 0.09, true], ["stop", 160, 0.06, true], ["transfer", 68, 0.16, true]]:
		sound.samples[item[0]] = sound._make_sound(item[1], item[2], 0.20, item[3])
	effects = Effects.new()
	effects.particle_limit = 128
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
	observed_can_state = "idle"
	observed_rotor_occupied = false
	rotor_visits = 0
	charge_effects.clear()
	observed_air_blocked = false
	pause_frames = 0
	shake = 0
	camera.offset = Vector2.ZERO
	effects.particles.clear()
	_block(Rect2(-20, -10, 20, 410))
	_block(Rect2(640, -10, 20, 410))
	_block(Rect2(0, 50, 640, 10))
	_block(Rect2(0, 318, 640, 60))
	_block(Rect2(0, 290, 12, 28))
	_block(Rect2(628, 290, 12, 28))
	match index:
		0: _redirect()
		1: _weight()
		2: _timing()
		3: _combine()
	player = Player.new()
	player.position = [Vector2(185, 272), Vector2(185, 272), Vector2(116, 309), Vector2(50, 309)][index]
	player.air_acceleration = 1700
	player.floor_snap_length = 4
	player.safe_margin = 0.04
	player.jumped.connect(func(_at: Vector2) -> void: sound.play("jump"))
	player.rebounded.connect(func(at: Vector2) -> void:
		stats.rebounds += 1
		if can.state == "charging": stats.charging_rebounds += 1
		_record("rebound")
		_feedback(at, "bounce", Color("fff1b3"), 10, 0, 0.7)
	)
	player.health_changed.connect(func(value: int) -> void:
		if value < 3:
			stats.hits += 1
			_record("hurt")
			_feedback(player.position, "hit", Color("ff9470"), 8, 0, 1.2)
	)
	player.died.connect(_death)
	room.add_child(player)
	player.strike_shape.size = Vector2(22, 14)
	can = Can.new()
	can.position = [Vector2(160, 306), Vector2(160, 306), Vector2(90, 306), Vector2(24.1, 305.9)][index]
	can.rail_left = 24
	can.rail_right = 616
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
		_feedback(_impact_point(can, object), "roll" if object == boulder else "clunk", Color("edb374"), 15, 3)
	)
	can.wall_impacted.connect(func(at: Vector2) -> void: _feedback(at, "clunk", Color("edb374"), 8, 3, 1.2))
	room.add_child(can)
	exit_rect = Rect2(428 if index == 0 else 601, exit_floor - 37, 33, 37)
	hud.text = TITLES[index] + "     ●●●"
	lesson.text = ["STAND TO AIM. WHITE ARROW = LOCKED. THEN MOVE.", "MOVING CAN SPENDS ONE SETUP AND PREPARES THE NEXT.", "TWO BEAM SETUPS. KEEP YOUR PLACE WHEN THE FIRST CHANGES.", "CHOOSE YOUR RETURN POSITION. IT CHANGES THE NEXT TIMING."][index]
	mode = "play"
	overlay.hide()
	_freeze(false)
	queue_redraw()

func _redirect() -> void:
	# Two opposite lures; both visible mechanisms are needed for the high route.
	_platform("shutter", Rect2(232, 130, 18, 188), [Vector2(241, 32)], 240, true)
	var service := _platform("service", Rect2(66, 308, 68, 10), [Vector2(100, 255)], 160, true)
	service.force_direction = -1
	_block(Rect2(20, 281, 46, 8), true)
	_block(Rect2(134, 281, 74, 8), true)
	_block(Rect2(134, 248, 74, 8), true)
	_block(Rect2(86, 214, 386, 10), true)
	exit_floor = 214

func _weight() -> void:
	# First lower the boarding lift. Spend that position only after boarding:
	# departure lifts the player, and the next endpoint powers the crossing.
	_platform("shutter", Rect2(232, 130, 18, 188), [Vector2(241, 32)], 240, true)
	var pedal := _machine("button", "button", Rect2(14, 312, 78, 9))
	var boarding := _platform("boarding", Rect2(84, 180, 92, 10), [Vector2(130, 286)], 130)
	pedal.targets.assign([boarding])
	var next_pedal := _machine("crossing_button", "button", Rect2(252, 312, 56, 9))
	var crossing := _platform("crossing", Rect2(371, 180, 88, 10), [Vector2(548, 185)], 90)
	next_pedal.targets.assign([crossing])
	_block(Rect2(134, 281, 74, 8), true)
	_block(Rect2(134, 248, 74, 8), true)
	_block(Rect2(164, 180, 266, 10), true)
	_block(Rect2(584, 144, 56, 12), true)
	exit_floor = 144

func _timing() -> void:
	# The first beam lowers boarding. Return Can while aboard, then time a
	# second departure as the lift rises. The upper crossing alone gives no height.
	var rotor := _machine("rotator", "rotator", Rect2(316, 312, 78, 9))
	rotor.mast_height = 220
	rotor.angle = deg_to_rad(-22)
	rotor.rotation_rate = deg_to_rad(14)
	rotor.sweep_min = deg_to_rad(-28)
	rotor.sweep_max = deg_to_rad(56)
	var boarding_sensor := _machine("boarding_sensor", "sensor", Rect2(414, 99, 32, 32), 17)
	var boarding := _platform("boarding", Rect2(210, 214, 140, 10), [Vector2(280, 286)], 80)
	boarding_sensor.targets.assign([boarding])
	var sensor := _machine("sensor", "sensor", Rect2(414, 139, 32, 32), 13)
	var crossing := _platform("crossing", Rect2(371, 281, 88, 10), [Vector2(548, 185)], 75)
	sensor.targets.assign([crossing])
	_block(Rect2(318, 281, 64, 8), true)
	_block(Rect2(402, 281, 64, 8), true)
	_block(Rect2(310, 214, 120, 10), true)
	_block(Rect2(584, 144, 56, 12), true)
	exit_floor = 144

func _combine() -> void:
	# Two valid plans: clear the force shutter early and return to x170, or
	# reserve it for the final departure and return to x272. Both must board.
	var rotor := _machine("rotator", "rotator", Rect2(145, 312, 160, 9))
	rotor.mast_height = 220
	rotor.mast_offset_x = 130
	rotor.angle = deg_to_rad(72)
	rotor.rotation_rate = deg_to_rad(-14)
	rotor.sweep_min = deg_to_rad(-16)
	rotor.sweep_max = deg_to_rad(76)
	var boarding_sensor := _machine("boarding_sensor", "sensor", Rect2(414, 139, 32, 32), 17)
	var boarding := _platform("boarding", Rect2(260, 214, 100, 10), [Vector2(310, 286)], 80)
	var other_boarding := _platform("other_boarding", Rect2(90, 214, 140, 10), [Vector2(160, 286)], 80)
	boarding_sensor.targets.assign([boarding, other_boarding])
	var sensor := _machine("sensor", "sensor", Rect2(414, 99, 32, 32), 11)
	var crossing := _platform("crossing", Rect2(371, 281, 88, 10), [Vector2(548, 185)], 75)
	sensor.targets.assign([crossing])
	_platform("shutter", Rect2(430, 146, 18, 172), [Vector2(439, 404)], 240, true)
	var exit_pedal := _machine("exit_button", "button", Rect2(394, 312, 50, 9))
	var exit_lift := _platform("exit_lift", Rect2(514, 214, 68, 10), [Vector2(548, 149)], 130)
	exit_pedal.targets.assign([exit_lift])
	_block(Rect2(70, 281, 190, 8), true)
	_block(Rect2(338, 281, 82, 8), true)
	_block(Rect2(180, 214, 250, 10), true)
	_block(Rect2(448, 214, 18, 10), true)
	_block(Rect2(584, 108, 56, 12), true)
	exit_floor = 108

func _add_boulder(at: Vector2) -> void:
	boulder = Boulder.new()
	boulder.position = at
	boulder.rolled.connect(func(_force: float) -> void:
		stats.boulder_impacts += 1
	)
	boulder.settled.connect(func() -> void:
		_feedback(boulder.position + Vector2(0, 12), "clunk", Color("c3ad83"), 5, 0, 0)
		_record("Boulder settled")
	)
	boulder.transferred.connect(func(receiver: Node2D, _force: float) -> void:
		_record("Boulder force transfer")
		_feedback(_impact_point(boulder, receiver), "transfer", Color("fff1b3"), 12, 3, 1.8)
	)
	room.add_child(boulder)
	if DisplayServer.get_name() != "headless":
		boulder.roll_voice = _loop_voice(boulder, 58, 0.35, -40)
		boulder.roll_voice.stream_paused = true

func _machine(id: String, kind: String, area: Rect2, radius: float = 30) -> Node2D:
	var machine := Machine.new()
	machine.configure(kind, area)
	machine.optical_radius = radius
	machine.exposed.connect(func() -> void:
		_record("beam cover removed")
		sound.play("alarm")
		effects.burst(machine.beam_end, Color("fff1b3"), 9)
	)
	machine.changed.connect(func(on: bool) -> void:
		if kind == "button":
			_feedback(machine.position, "clunk", Color("a9f4dd"), 7, 1)
		elif kind == "sensor" and on:
			stats.sensor_activations += 1
			_feedback(machine.position, "light", Color("a9f4dd"), 8, 0, 0.5)
		elif kind == "rotator":
			sound.play("engage" if on else "stop")
		_record(id + (" on" if on else " off"))
	)
	room.add_child(machine)
	machines[id] = machine
	if kind == "fan" and DisplayServer.get_name() != "headless":
		machine.wind = _loop_voice(machine, 72, 0.6, -24)
	return machine

func _loop_voice(owner_node: Node, frequency: float, duration: float, gain: float) -> AudioStreamPlayer:
	var stream: AudioStreamWAV = sound._make_sound(frequency, duration, 0.10, true)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = stream.data.size() / 2
	var voice := AudioStreamPlayer.new()
	voice.stream = stream
	voice.volume_db = gain
	owner_node.add_child(voice)
	voice.play()
	return voice

func _platform(id: String, area: Rect2, path: Array[Vector2], speed: float, force: bool = false) -> Node2D:
	var platform := Platform.new()
	platform.configure(area, path, speed)
	platform.force_operated = force
	platform.one_way = not force and area.size.y <= 12
	platform.started.connect(func() -> void: sound.play("motor"))
	platform.arrived.connect(func() -> void: sound.play("clunk"))
	platform.started.connect(func() -> void: _record(id + " moving"))
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
	if mode != "paused":
		clock += delta
		shake = maxf(0, shake - delta * 14)
		camera.offset = Vector2(sin(clock * 83), cos(clock * 71)) * shake
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
	_observe_strategy()
	elapsed += delta
	level_time += delta
	controls_time = maxf(0, controls_time - delta)
	controls.visible = controls_time > 0
	if pause_frames > 0:
		pause_frames -= 1
		_freeze(pause_frames > 0, true)
	if player.get_real_velocity().length() < 8: stats.idle_seconds += delta
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

func _freeze(value: bool, impact_pause: bool = false) -> void:
	if player != null:
		player.impact_paused = value and impact_pause
		player.active = not value or impact_pause
		if value and not impact_pause:
			player.pending_jump = false
			player.pending_attack = false
			player.pending_jump_release = false
	if can != null: can.suspended = value
	if boulder != null:
		boulder.suspended = value
		if boulder.roll_voice != null: boulder.roll_voice.stream_paused = value or not boulder.rolling
	for platform in platforms.values(): platform.suspended = value
	for machine in machines.values():
		machine.suspended = value
		if machine.wind != null: machine.wind.stream_paused = value

func _impact_point(source: Node2D, target: Node2D) -> Vector2:
	var bounds: Rect2 = target.impact_rect()
	return Vector2(clampf(source.position.x, bounds.position.x, bounds.end.x), clampf(source.position.y, bounds.position.y, bounds.end.y))

func _feedback(at: Vector2, cue: String, color: Color, count: int, hit_pause: int, strength: float = 2.0) -> void:
	if sound == null: return
	sound.play(cue)
	effects.burst(at, color, count, Vector2.UP if cue == "bounce" else Vector2.ZERO)
	shake = maxf(shake, strength)
	pause_frames = maxi(pause_frames, hit_pause + 1) if hit_pause > 0 and hit_pause_enabled else pause_frames

func _record(event: String) -> void:
	if can == null or player == null: return
	var laser: Node2D = machines.get("rotator", machines.get("laser"))
	events.append({"event": event, "seconds": snappedf(level_time, 0.01), "player": player.position, "can": can.position, "can_state": can.state, "boulder": boulder.position if boulder != null else Vector2.ZERO, "laser_angle": rad_to_deg(laser.angle) if laser != null else 0, "beam_covered": laser.covered_by_heavy if laser != null else false, "air_blocked": machines.fan.flow_blocked if machines.has("fan") else false, "sensor": machines.sensor.active if machines.has("sensor") else false})
	if event == "hurt":
		events.back()["velocity_before_hit"] = player.velocity
		events.back()["previous_feet"] = player.previous_feet
	events.back()["charge_id"] = stats.charges
	if stats.charges > 0 and event in ["force", "rotator off", "rotator on", "sensor on", "airway opened", "exit_button on"]:
		if not charge_effects.has(stats.charges): charge_effects[stats.charges] = []
		if event not in charge_effects[stats.charges]: charge_effects[stats.charges].append(event)

func _observe_strategy() -> void:
	# Observation only: no puzzle flags, steering or success prerequisites.
	if observed_can_state == "charging" and can.state != "charging":
		_record("charge endpoint")
	observed_can_state = can.state
	if machines.has("fan"):
		if observed_air_blocked and not machines.fan.flow_blocked: _record("airway opened")
		observed_air_blocked = machines.fan.flow_blocked
	if machines.has("rotator"):
		var occupied: bool = machines.rotator.occupied
		if occupied and not observed_rotor_occupied:
			rotor_visits += 1
		observed_rotor_occupied = occupied

func metrics() -> Dictionary:
	var result := stats.duplicate()
	var cover_losses := 0
	var chains := 0
	var aligned_withdrawals: Dictionary = {}
	for event in events:
		if event.event == "beam cover removed": cover_losses += 1
		if event.event == "rotator off" and event.sensor: aligned_withdrawals[event.charge_id] = true
	for charge_id in charge_effects:
		if "force" in charge_effects[charge_id] and "exit_button on" in charge_effects[charge_id] and aligned_withdrawals.has(charge_id): chains += 1
	# These are observations, not an assertion that a planned sacrifice was bad.
	result.merge({"useful_cover_losses": cover_losses, "rotor_state_recreations": maxi(0, rotor_visits - 1), "chained_interactions": chains, "charge_effects": charge_effects.duplicate(true)})
	result.merge({"level": level_index + 1, "seconds": snappedf(level_time, 0.01), "events": events.duplicate(true)})
	return result

func _create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var backing := ColorRect.new()
	backing.size = Vector2(640, 50)
	backing.color = Color("101e2b")
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(backing)
	hud = Label.new()
	hud.position = Vector2(12, 10)
	PixelUI.style_label(hud, font, 11, Color("edc27a"))
	layer.add_child(hud)
	controls = Label.new()
	controls.position = Vector2(12, 29)
	controls.text = "A/D MOVE   SPACE JUMP   R RETRY   H HELP   ESC PAUSE"
	PixelUI.style_label(controls, font, 9, Color("9ac6c7"))
	layer.add_child(controls)
	lesson = Label.new()
	lesson.position = Vector2(12, 43)
	PixelUI.style_label(lesson, font, 8, Color("a9f4dd"))
	layer.add_child(lesson)
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
	if boulder != null and machines.has("laser"):
		var emitter: Node2D = machines.laser
		if emitter != null and emitter.beam_hit == boulder:
			# This stationary horizontal ray protects the ground approach. A
			# rotating ray can leave that lane, so do not imply the same shadow.
			var edge := boulder.position.x + 17
			draw_rect(Rect2(edge, 287, 640 - edge, 30), Color("a9f4dd", 0.06))
			for x in range(int(edge), 634, 12):
				draw_line(Vector2(x, 315), Vector2(x + 6, 315), Color("a9f4dd", 0.48), 2)
	if can != null:
		draw_line(Vector2(can.rail_left, 321), Vector2(can.rail_right, 321), Color("657e83"), 2)
		for x in [can.rail_left, can.rail_right]:
			draw_rect(Rect2(x - 4, 318, 8, 7), Color("e3b774"))
		if can.state in ["windup", "lock", "charging"]:
			var color := Color("fff1b3", 0.5) if can.intent_locked else Color("ff785e", 0.4)
			var end: float = can.predicted_endpoint()
			for x in range(int(minf(can.position.x, end)), int(maxf(can.position.x, end)), 13):
				draw_line(Vector2(x, can.position.y + 15), Vector2(x + 6, can.position.y + 15), color, 1)
			draw_rect(Rect2(end - 12, can.position.y - 12, 24, 24), color, false, 1)
	for button in machines.values():
		if button.kind != "button": continue
		var tint := Color("a9f4dd") if button.active else Color("5d747c")
		for target in button.targets:
			var base := Vector2(button.position.x, 335)
			var tip: Vector2 = target.home if target is AnimatableBody2D else target.position
			draw_line(button.position + Vector2(0, 8), base, tint, 2)
			draw_line(base, Vector2(tip.x, 335), tint, 2)
			draw_line(Vector2(tip.x, 335), tip, tint, 2)
	for sensor in machines.values():
		if sensor.kind != "sensor": continue
		var tint := Color("a9f4dd") if sensor.active else Color("5d747c")
		for target in sensor.targets:
			draw_circle(Vector2(target.home.x, sensor.position.y), 4, tint)
			draw_line(sensor.position + Vector2(sensor.optical_radius, 0), Vector2(target.home.x, sensor.position.y), tint, 2)
			draw_line(Vector2(target.home.x, sensor.position.y), target.home, tint, 1)
	if level_index in [0, 1]:
		draw_string(font, Vector2(201, 122), "FORCE →", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("edc27a"))
	if level_index == 0:
		draw_string(font, Vector2(72, 296), "← FORCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("edc27a"))
	if level_index == 1:
		draw_string(font, Vector2(17, 287), "BOARDING", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("a9f4dd"))
		draw_string(font, Vector2(253, 341), "CROSSING", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("a9f4dd"))
	if level_index == 3:
		draw_string(font, Vector2(388, 341), "EXIT WEIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("a9f4dd"))
	if machines.has("boarding_sensor"):
		var receiver: Node2D = machines.boarding_sensor
		draw_string(font, receiver.position + Vector2(receiver.optical_radius + 9, 3), "BOARDING", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("edc27a"))
		var receiver_b: Node2D = machines.sensor
		draw_string(font, receiver_b.position + Vector2(receiver_b.optical_radius + 9, 3), "CROSSING", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("a9f4dd"))
	if machines.has("rotator"):
		var rotor: Node2D = machines.rotator
		draw_string(font, Vector2(rotor.position.x - 29, 341), "PARK / TURN", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("a9f4dd"))
	if machines.has("fan"):
		var fan: Node2D = machines.fan
		draw_string(font, Vector2(fan.position.x - 27, 344), "AIR DUCT", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("edc27a") if fan.flow_blocked else Color("a9f4dd"))
	var entry := Vector2(exit_rect.position.x - 3, exit_floor - 38)
	draw_rect(Rect2(entry, Vector2(38, 38)), Color("416d83"))
	draw_rect(Rect2(entry + Vector2(5, 5), Vector2(28, 33)), Color("a9f4dd"))
	draw_rect(Rect2(entry + Vector2(9, 8), Vector2(20, 30)), Color("203c46"))
	draw_string(font, entry + Vector2(-3, -7), "EXIT →", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a9f4dd"))
