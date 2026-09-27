extends Node2D

const PlayerScene = preload("res://scripts/player.gd")
const EnemyScene = preload("res://scripts/enemy.gd")
const ReceiverScene = preload("res://scripts/circuit_receiver.gd")
const BulletScene = preload("res://scripts/reflectable_bullet.gd")
const SawScene = preload("res://scripts/clockwork_saw.gd")
const PlatformScene = preload("res://scripts/moving_platform.gd")
const EffectsScene = preload("res://scripts/effects.gd")
const SfxScene = preload("res://scripts/sfx.gd")

const START_POSITION := Vector2(650, 489)
const GOAL_POSITION := Vector2(650, 170)
const FLOOR_COLOR := Color("344d58")
const BRASS := Color("d7a35b")
const POWER := Color("65e8c8")
const DANGER := Color("e87759")

var blocks: Array[Rect2] = []
var step_blocks: Array[Rect2] = []
var spike_rects: Array[Rect2] = []
var pressure_teeth: Area2D
var gates: Dictionary = {}
var gate_rects: Dictionary = {}
var receivers: Dictionary = {}
var enemies: Array[Area2D] = []
var projectiles: Array[Area2D] = []
var player: CharacterBody2D
var camera: Camera2D
var effects: Node2D
var sfx: Node
var hud: Label
var checkpoint_position := START_POSITION
var checkpoint_stage := 0
var checkpoint_snapshot: Dictionary = {}
var finished := false
var started := false
var overlay: ColorRect
var title_label: Label
var health_label: Label
var health_segments: Array[ColorRect] = []
var hud_layer: CanvasLayer
var retry_hint: Label
var play_time := 0.0
var gate_open_fraction: Dictionary = {}
var machine_flash: Dictionary = {}
var guard_last_state := ""
var shooter_last_state := ""

func _ready() -> void:
	_setup_inputs()
	_build_geometry()
	_build_machines()
	_build_hazards()
	_spawn_actors()
	_build_player()
	_build_checkpoints()
	_build_goal()
	effects = EffectsScene.new()
	add_child(effects)
	sfx = SfxScene.new()
	add_child(sfx)
	_build_hud()
	_record_checkpoint(START_POSITION)
	_show_title()
	_update_hud()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not started and (event.is_action_pressed("jump") or event.is_action_pressed("attack")):
		_start_game()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart") and not event.is_echo():
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
	if not is_instance_valid(camera) or not is_instance_valid(player):
		return
	if started and not finished:
		play_time += delta
		if is_instance_valid(enemies[0]) and enemies[0].alive:
			var guard_state: String = enemies[0].state
			if guard_state == "windup" and guard_last_state != "windup":
				sfx.play("windup")
			guard_last_state = guard_state
		if is_instance_valid(enemies[1]) and enemies[1].alive:
			var shooter_state: String = enemies[1].state
			if shooter_state == "aim" and shooter_last_state != "aim":
				sfx.play("windup")
			shooter_last_state = shooter_state
	var intake_view := player.global_position.y > 410.0
	var blend := clampf(delta * 3.0, 0.0, 1.0)
	camera.zoom = camera.zoom.lerp(Vector2(0.76, 0.76), blend)
	camera.position.y = lerpf(camera.position.y, -84.0 if intake_view else -52.0, blend)
	var side_focus := 32.0 if player.global_position.x < 550.0 else -32.0 if player.global_position.x > 750.0 else 0.0
	camera.position.x = lerpf(camera.position.x, side_focus, blend)
	var animating := false
	for key in gates:
		var receiver := receivers[key] as Area2D
		var target := 1.0 if receiver.charge >= receiver.required_charge else 0.0
		var current := float(gate_open_fraction.get(key, 0.0))
		var next := move_toward(current, target, delta * 3.0)
		gate_open_fraction[key] = next
		animating = animating or absf(next - target) > 0.001
	for key in machine_flash:
		var next := maxf(0.0, float(machine_flash[key]) - delta * 2.2)
		machine_flash[key] = next
		animating = animating or next > 0.0
	if animating or _branches_powered() or play_time < 3.0:
		queue_redraw()

func _physics_process(_delta: float) -> void:
	if not finished and is_instance_valid(player) and player.active and player.global_position.y > 560.0:
		_on_hazard()

func _build_geometry() -> void:
	# Intake is a bowl below one shared level. Both side loops return to the Core.
	_add_block(Rect2(540, 500, 225, 24))
	for ledge in [Rect2(718, 470, 78, 9), Rect2(755, 440, 78, 9), Rect2(718, 410, 78, 9), Rect2(680, 380, 78, 9)]:
		_add_step(ledge)
	_add_step(Rect2(240, 340, 830, 9))
	_add_step(Rect2(540, 302, 90, 9))
	_add_step(Rect2(625, 270, 95, 9))
	_add_step(Rect2(540, 238, 100, 9))
	_add_step(Rect2(625, 206, 95, 9))
	_add_step(Rect2(560, 184, 180, 9))
	_add_step(Rect2(370, 303, 80, 9))
	_add_step(Rect2(925, 303, 80, 9))

func _add_block(rect: Rect2) -> void:
	blocks.append(rect)
	_make_solid(rect, false)

func _add_step(rect: Rect2) -> void:
	step_blocks.append(rect)
	_make_solid(rect, true)

func _make_solid(rect: Rect2, one_way: bool) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.one_way_collision = one_way
	body.add_child(collision)
	add_child(body)
	return body

func _build_machines() -> void:
	_add_receiver("intake", Vector2(650, 482), 1)
	_add_gate("intake", Rect2(742, 382, 12, 88))
	_add_receiver("pressure", Vector2(450, 330), 3)
	_add_gate("pressure", Rect2(543, 238, 12, 52))
	_add_receiver("gallery", Vector2(800, 330), 2)
	_add_gate("gallery", Rect2(752, 238, 12, 52))
	_add_receiver("core", Vector2(650, 330), 3)
	_add_gate("core", Rect2(645, 191, 12, 47))
	(receivers["core"] as Area2D).enabled = false
	var ferry := PlatformScene.new()
	ferry.name = "ServiceFerry"
	ferry.configure(Vector2(885, 304), 58.0)
	add_child(ferry)

func _add_receiver(key: String, at: Vector2, threshold: int) -> void:
	var receiver := ReceiverScene.new()
	receiver.name = key.capitalize() + "Socket"
	receiver.configure(at, threshold, key)
	receiver.activated.connect(_on_receiver_activated.bind(key))
	receiver.impact_applied.connect(_on_receiver_impact.bind(key))
	receiver.charge_changed.connect(func(_value: int) -> void: _sync_gate(key))
	add_child(receiver)
	receivers[key] = receiver
	machine_flash[key] = 0.0

func _on_receiver_impact(_force: int, source: String, value: int, key: String) -> void:
	machine_flash[key] = 1.0
	var at: Vector2 = (receivers[key] as Area2D).global_position
	if source == "charge":
		sfx.play("attack_hit")
		effects.impact(at, BRASS, Vector2.RIGHT)
	elif source == "projectile":
		effects.impact(at, POWER, Vector2.LEFT)
	else:
		effects.burst(at, BRASS, 4)
	if value < (receivers[key] as Area2D).required_charge and source != "player":
		sfx.play("checkpoint")
	queue_redraw()

func _add_gate(key: String, rect: Rect2) -> void:
	var gate := _make_solid(rect, false)
	gate.name = key.capitalize() + "Shutter"
	gate_rects[key] = rect
	gates[key] = gate
	gate_open_fraction[key] = 0.0

func _on_receiver_activated(source: String, key: String) -> void:
	_sync_gate(key)
	if key == "pressure":
		if is_instance_valid(enemies[0]):
			enemies[0].patrol_right_override = 0.0
		_retract_teeth_after_charge()
	if key in ["pressure", "gallery"]:
		(receivers["core"] as Area2D).enabled = _branches_powered()
	if key == "gallery":
		checkpoint_stage = 3
		_record_checkpoint(Vector2(755, 329))
	if key == "core":
		player.invulnerable_time = 5.0
		player.hurt_lock = 0.0
		for enemy in enemies:
			if is_instance_valid(enemy):
				enemy.set_physics_process(false)
				enemy.collision_layer = 0
				enemy.collision_mask = 0
				enemy.set_deferred("monitoring", false)
				enemy.set_deferred("monitorable", false)
		for projectile in projectiles:
			if is_instance_valid(projectile):
				projectile.queue_free()
		var wheel := get_node_or_null("CorePowerWheel") as Area2D
		if is_instance_valid(wheel):
			wheel.inert = true
			wheel.collision_layer = 0
			wheel.collision_mask = 0
			wheel.set_deferred("monitoring", false)
	if is_instance_valid(sfx):
		sfx.play("powerup" if key == "core" else "gate_open")
	if is_instance_valid(effects):
		effects.burst((receivers[key] as Area2D).global_position, POWER, 9)
	queue_redraw()
	_update_hud()

func _branches_powered() -> bool:
	return receivers.has("pressure") and receivers.has("gallery") and (receivers["pressure"] as Area2D).charge >= 3 and (receivers["gallery"] as Area2D).charge >= 2

func _sync_gate(key: String) -> void:
	if not gates.has(key):
		return
	var gate := gates[key] as StaticBody2D
	var receiver := receivers[key] as Area2D
	var powered: bool = receiver.charge >= receiver.required_charge
	gate.collision_layer = 0 if powered else 1
	(gate.get_child(0) as CollisionShape2D).set_deferred("disabled", powered)
	queue_redraw()

func _build_hazards() -> void:
	pressure_teeth = _add_teeth(Rect2(515, 330, 24, 10))
	var saw := SawScene.new()
	saw.name = "CorePowerWheel"
	saw.configure(Vector2(710, 330), Vector2(16, 0), 1.8, 10.0)
	saw.hit_player.connect(func(_at: Vector2) -> void: _on_hazard())
	add_child(saw)

func _add_teeth(rect: Rect2) -> Area2D:
	spike_rects.append(rect)
	var area := Area2D.new()
	area.name = "PressureTeeth"
	area.position = rect.get_center()
	area.collision_layer = 32
	area.collision_mask = 2
	area.add_to_group("pogo_spikes")
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	area.add_child(collision)
	area.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and not body.is_pogo_safe():
			_on_hazard()
	)
	add_child(area)
	return area

func _retract_teeth_after_charge() -> void:
	await get_tree().create_timer(0.55).timeout
	if not is_inside_tree() or (receivers["pressure"] as Area2D).charge < 3:
		return
	pressure_teeth.collision_layer = 0
	pressure_teeth.collision_mask = 0
	pressure_teeth.set_deferred("monitoring", false)
	spike_rects.clear()
	checkpoint_stage = maxi(checkpoint_stage, 2)
	_record_checkpoint(Vector2(650, 329))
	queue_redraw()

func _spawn_actors() -> void:
	_spawn_enemy("tower_guard", "MaintenanceAutomaton", Vector2(325, 330), 275.0, 720.0)
	_spawn_enemy("shooter", "BoltEmitter", Vector2(895, 330), 875.0, 915.0)

func _spawn_enemy(kind: String, node_name: String, at: Vector2, left: float, right: float) -> void:
	var actor := EnemyScene.new() as Area2D
	actor.name = node_name
	actor.configure(kind, at, left, right)
	actor.circuit_style = true
	if kind == "tower_guard" and (receivers["pressure"] as Area2D).charge < 3:
		actor.patrol_right_override = 390.0
	if kind == "tower_guard":
		actor.trigger_range_override = 220.0
		actor.charge_time_override = 0.85
	if kind == "shooter":
		actor.trigger_range_override = 180.0
		actor.burst_gap_override = 0.5
	actor.touched_player.connect(func(source: Vector2) -> void: player.take_damage(source))
	actor.projectile_fired.connect(func(at: Vector2, direction: Vector2) -> void: _spawn_bullet(at, direction, actor))
	actor.hazard_struck.connect(func(point: Vector2) -> void:
		if is_instance_valid(effects):
			sfx.play("attack_hit")
			effects.impact(point, DANGER, Vector2.LEFT)
	)
	actor.defeated.connect(func(point: Vector2) -> void:
		if is_instance_valid(effects):
			effects.burst(point, BRASS, 7)
	)
	add_child(actor)
	enemies.append(actor)

func _spawn_bullet(at: Vector2, direction: Vector2, source_actor: Area2D = null) -> void:
	var bullet := BulletScene.new() as Area2D
	bullet.configure(at, direction * 175.0)
	bullet.source_actor = source_actor
	bullet.hit_player.connect(func(source: Vector2) -> void: player.take_damage(source))
	bullet.reflected.connect(func(point: Vector2) -> void:
		sfx.play("reflect")
		effects.burst(point, POWER, 5)
	)
	add_child(bullet)
	projectiles.append(bullet)
	sfx.play("shoot")

func _build_player() -> void:
	player = PlayerScene.new() as CharacterBody2D
	player.circuit_style = true
	player.position = START_POSITION
	player.last_safe_position = START_POSITION
	player.died.connect(_on_player_died)
	player.health_changed.connect(func(_value: int) -> void: _update_hud())
	player.jumped.connect(func(_point: Vector2) -> void: sfx.play("jump"))
	player.rebounded.connect(func(point: Vector2) -> void:
		sfx.play("bounce")
		effects.burst(point, POWER, 5)
	)
	player.attack_connected.connect(func(point: Vector2) -> void:
		sfx.play("attack_hit")
		effects.impact(point, BRASS, Vector2.UP)
	)
	add_child(player)
	camera = Camera2D.new()
	camera.position = Vector2(0, -84)
	camera.zoom = Vector2(0.76, 0.76)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.0
	camera.limit_left = 190
	camera.limit_right = 1120
	camera.limit_top = 100
	camera.limit_bottom = 545
	player.add_child(camera)
	camera.make_current()

func _build_checkpoints() -> void:
	_add_checkpoint(1, Vector2(650, 316), Vector2(650, 329))

func _add_checkpoint(stage: int, at: Vector2, respawn: Vector2) -> void:
	var marker := Area2D.new()
	marker.name = "ServiceMarker%d" % stage
	marker.position = at
	marker.collision_layer = 0
	marker.collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28, 45)
	collision.shape = shape
	marker.add_child(collision)
	marker.body_entered.connect(func(body: Node2D) -> void:
		if body == player and started and checkpoint_stage == 0:
			checkpoint_stage = stage
			_record_checkpoint(respawn)
			sfx.play("checkpoint")
			_update_hud()
			queue_redraw()
	)
	add_child(marker)

func _build_goal() -> void:
	var goal := Area2D.new()
	goal.name = "ClockworkCoreExit"
	goal.position = GOAL_POSITION
	goal.collision_layer = 0
	goal.collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(40, 52)
	collision.shape = shape
	goal.add_child(collision)
	goal.body_entered.connect(func(body: Node2D) -> void:
		if body == player and not finished and (receivers["core"] as Area2D).charge >= (receivers["core"] as Area2D).required_charge:
			finished = true
			player.active = false
			sfx.play("win")
			_show_result()
			_update_hud()
			queue_redraw()
	)
	add_child(goal)

func _on_hazard() -> void:
	if player.take_hazard_damage():
		sfx.play("hit")

func _on_player_died() -> void:
	sfx.play("death")
	if is_instance_valid(retry_hint):
		retry_hint.visible = true
	await get_tree().create_timer(0.38).timeout
	if not is_inside_tree() or finished:
		return
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	projectiles.clear()
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)
			enemy.queue_free()
	enemies.clear()
	for key in receivers:
		(receivers[key] as Area2D).reset_receiver(int((checkpoint_snapshot.get("charges", {}) as Dictionary).get(key, 0)))
		machine_flash[key] = 0.0
	(receivers["core"] as Area2D).enabled = _branches_powered()
	var wheel := get_node_or_null("CorePowerWheel") as Area2D
	if is_instance_valid(wheel):
		var wheel_active: bool = (receivers["core"] as Area2D).charge < 3
		wheel.inert = not wheel_active
		wheel.collision_layer = 32 if wheel_active else 0
		wheel.collision_mask = 2 if wheel_active else 0
		wheel.set_deferred("monitoring", wheel_active)
		wheel.clock = 0.0
		wheel.position = wheel.home
	var ferry := get_node_or_null("ServiceFerry") as AnimatableBody2D
	if is_instance_valid(ferry):
		ferry.clock = 0.0
		ferry.position = ferry.home
	pressure_teeth.collision_layer = 0 if (receivers["pressure"] as Area2D).charge >= 3 else 32
	pressure_teeth.collision_mask = 0 if pressure_teeth.collision_layer == 0 else 2
	pressure_teeth.set_deferred("monitoring", pressure_teeth.collision_layer != 0)
	spike_rects.clear()
	if pressure_teeth.collision_layer == 32:
		spike_rects.append(Rect2(515, 330, 24, 10))
	for key in gates:
		_sync_gate(key)
	_spawn_actors()
	guard_last_state = ""
	shooter_last_state = ""
	var saved_enemies: Dictionary = checkpoint_snapshot.get("enemies", {})
	for enemy in enemies:
		var saved: Dictionary = saved_enemies.get(enemy.name, {})
		if not saved.get("alive", true):
			enemy.queue_free()
			continue
		enemy.health = int(saved.get("health", enemy.health))
		enemy.global_position = saved.get("position", enemy.global_position)
		enemy.facing = int(saved.get("facing", enemy.facing))
		enemy.state = "patrol"
		if enemy.name == "MaintenanceAutomaton":
			enemy.patrol_right_override = 0.0 if (receivers["pressure"] as Area2D).charge >= 3 else 390.0
	player.reset_at(checkpoint_position)
	if is_instance_valid(retry_hint):
		retry_hint.visible = false
	_update_hud()

func _record_checkpoint(at: Vector2) -> void:
	checkpoint_position = at
	var charges := {}
	for key in receivers:
		charges[key] = (receivers[key] as Area2D).charge
	var actor_states := {
		"MaintenanceAutomaton": {"alive": false},
		"BoltEmitter": {"alive": false}
	}
	for enemy in enemies:
		if is_instance_valid(enemy):
			actor_states[enemy.name] = {"alive": enemy.alive, "health": enemy.health, "position": enemy.global_position, "facing": enemy.facing}
	checkpoint_snapshot = {"charges": charges, "enemies": actor_states}

func _build_hud() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)
	health_label = Label.new()
	health_label.text = "INTEGRITY"
	health_label.position = Vector2(12, 7)
	health_label.add_theme_font_size_override("font_size", 8)
	health_label.add_theme_color_override("font_color", Color("b7e6bc"))
	hud_layer.add_child(health_label)
	for index in 3:
		var segment := ColorRect.new()
		segment.size = Vector2(18, 3)
		segment.position = Vector2(12 + index * 21, 23)
		hud_layer.add_child(segment)
		health_segments.append(segment)
	retry_hint = Label.new()
	retry_hint.text = "R  RESTART"
	retry_hint.position = Vector2(309, 185)
	retry_hint.visible = false
	retry_hint.add_theme_font_size_override("font_size", 8)
	retry_hint.add_theme_color_override("font_color", Color("a87950"))
	hud_layer.add_child(retry_hint)

func _update_hud() -> void:
	if not is_instance_valid(player):
		return
	for index in health_segments.size():
		health_segments[index].color = Color("b7e6bc") if index < player.health else Color("455763")

func _show_title() -> void:
	player.active = false
	for enemy in enemies:
		enemy.set_physics_process(false)
	overlay = ColorRect.new()
	overlay.color = Color(0.035, 0.083, 0.11, 0.95)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_layer.add_child(overlay)
	var eyebrow := Label.new()
	eyebrow.text = "CLOCKWORK TOWER"
	eyebrow.position = Vector2(91, 37)
	eyebrow.add_theme_font_size_override("font_size", 10)
	eyebrow.add_theme_color_override("font_color", BRASS)
	overlay.add_child(eyebrow)
	title_label = Label.new()
	title_label.text = "KINETIC\nCIRCUIT"
	title_label.position = Vector2(88, 58)
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color("b7e6bc"))
	overlay.add_child(title_label)
	var rule := ColorRect.new()
	rule.color = POWER
	rule.position = Vector2(91, 136)
	rule.size = Vector2(197, 2)
	overlay.add_child(rule)
	var prompt := Label.new()
	prompt.text = "MOVE  A / D     JUMP  SPACE     STRIKE  J\n\nSPACE OR J TO BEGIN"
	prompt.position = Vector2(91, 149)
	prompt.add_theme_font_size_override("font_size", 8)
	prompt.add_theme_color_override("font_color", Color("a9c5bf"))
	overlay.add_child(prompt)

func _start_game() -> void:
	started = true
	player.active = true
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(true)
	if is_instance_valid(overlay):
		overlay.queue_free()

func _show_result() -> void:
	overlay = ColorRect.new()
	overlay.color = Color(0.035, 0.083, 0.11, 0.88)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_layer.add_child(overlay)
	var result := Label.new()
	result.text = "CIRCUIT IN PHASE\n\nTHE TOWER REMEMBERS\n\nR  RESTART"
	result.position = Vector2(85, 71)
	result.add_theme_font_size_override("font_size", 14)
	result.add_theme_color_override("font_color", Color("b7e6bc"))
	overlay.add_child(result)

func _setup_inputs() -> void:
	for action in ["move_left", "move_right", "aim_up", "aim_down", "jump", "attack", "dash", "restart"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	_add_key("move_left", KEY_A)
	_add_key("move_left", KEY_LEFT)
	_add_key("move_right", KEY_D)
	_add_key("move_right", KEY_RIGHT)
	_add_key("aim_up", KEY_W)
	_add_key("aim_down", KEY_S)
	_add_key("aim_up", KEY_UP)
	_add_key("aim_down", KEY_DOWN)
	_add_key("jump", KEY_SPACE)
	_add_key("attack", KEY_J)
	_add_key("attack", KEY_X)
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
	_add_pad_button("restart", 3)

func _add_key(action: String, keycode: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)

func _add_pad_button(action: String, button: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)

func _add_pad_axis(action: String, axis: int, axis_value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)

func _draw() -> void:
	draw_rect(Rect2(180, 90, 950, 455), Color("0b1720"))
	_draw_chamber(Rect2(525, 365, 255, 170), Color("1b3038"))
	_draw_chamber(Rect2(205, 270, 370, 125), Color("172a34"))
	_draw_chamber(Rect2(750, 270, 355, 125), Color("182d38"))
	_draw_chamber(Rect2(520, 130, 260, 210), Color("21353e"))
	# Inlaid rails join each reusable source to its receiver.
	draw_line(Vector2(296, 330), Vector2(480, 330), Color("765f4e"), 2.0)
	draw_line(Vector2(783, 330), Vector2(923, 330), Color("765f4e"), 2.0)
	draw_circle(Vector2(450, 330), 27.0, Color("7e6550"), false, 1.0)
	draw_circle(Vector2(800, 330), 27.0, Color("7e6550"), false, 1.0)
	if started and play_time > 1.3 and (receivers["intake"] as Area2D).charge == 0 and player.global_position.y > 425.0 and absf(player.global_position.x - 650.0) < 65.0:
		draw_string(ThemeDB.fallback_font, Vector2(600, 445), "DOWN + STRIKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("b7e6bc"))
	for rect in blocks:
		_draw_platform(rect, false)
	for rect in step_blocks:
		_draw_platform(rect, true)
	var west: bool = (receivers["pressure"] as Area2D).charge >= 3
	var east: bool = (receivers["gallery"] as Area2D).charge >= 2
	_draw_conductor(PackedVector2Array([Vector2(450, 307), Vector2(450, 255), Vector2(600, 255), Vector2(620, 284)]), west)
	_draw_conductor(PackedVector2Array([Vector2(800, 307), Vector2(800, 255), Vector2(700, 255), Vector2(680, 284)]), east)
	_draw_conductor(PackedVector2Array([Vector2(650, 459), Vector2(650, 363)]), (receivers["intake"] as Area2D).charge > 0)
	for key in gates:
		var gate_rect: Rect2 = gate_rects[key]
		var opening := float(gate_open_fraction.get(key, 0.0))
		var half_height := gate_rect.size.y * 0.5 * (1.0 - opening)
		if half_height > 0.5:
			draw_rect(Rect2(gate_rect.position, Vector2(gate_rect.size.x, half_height)), BRASS)
			draw_rect(Rect2(Vector2(gate_rect.position.x, gate_rect.end.y - half_height), Vector2(gate_rect.size.x, half_height)), BRASS)
		draw_line(gate_rect.position - Vector2(2, 0), gate_rect.position + Vector2(-2, gate_rect.size.y), Color("668480"), 1.0)
		draw_line(Vector2(gate_rect.end.x + 2, gate_rect.position.y), gate_rect.end + Vector2(2, 0), Color("668480"), 1.0)
	for rect in spike_rects:
		for x in range(int(rect.position.x), int(rect.end.x), 7):
			draw_colored_polygon(PackedVector2Array([Vector2(x, rect.end.y), Vector2(x + 3, rect.position.y), Vector2(x + 7, rect.end.y)]), DANGER)
	var core_lit: bool = (receivers["core"] as Area2D).charge >= 3
	var core_phase := play_time * (1.1 if core_lit else 0.45)
	draw_arc(Vector2(650, 280), 27.0, core_phase, core_phase + TAU * 0.83, 40, Color("b7e6bc") if core_lit else Color("a87950"), 4.0)
	draw_arc(Vector2(650, 280), 17.0, -PI * 0.8 + (core_phase if west else 0.0), PI * 0.8 + (core_phase if west else 0.0), 24, Color("b7e6bc") if west else Color("53616a"), 3.0)
	draw_arc(Vector2(650, 280), 17.0, PI * 0.2 - (core_phase if east else 0.0), PI * 1.8 - (core_phase if east else 0.0), 24, Color("b7e6bc") if east else Color("53616a"), 3.0)
	for key in machine_flash:
		var flash := float(machine_flash[key])
		if flash > 0.0:
			var at: Vector2 = (receivers[key] as Area2D).global_position
			draw_arc(at, 27.0 + (1.0 - flash) * 26.0, 0.0, TAU, 32, Color(0.72, 0.98, 0.83, flash * 0.7), 2.0)
	draw_arc(GOAL_POSITION, 18.0, 0.0, TAU, 28, Color("b7e6bc") if core_lit else Color("53616a"), 3.0)

func _draw_conductor(points: PackedVector2Array, lit: bool) -> void:
	var ink := Color("b7e6bc") if lit else Color("765f4e")
	for index in range(points.size() - 1):
		draw_line(points[index], points[index + 1], ink, 3.0 if lit else 2.0)
		if not lit:
			for notch in 3:
				var at := points[index].lerp(points[index + 1], (notch + 1.0) / 4.0)
				draw_circle(at, 1.5, Color("0b1720"))

func _draw_chamber(rect: Rect2, color: Color) -> void:
	draw_rect(rect, color)

func _draw_platform(rect: Rect2, light: bool) -> void:
	draw_rect(rect, FLOOR_COLOR if not light else Color("486672"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2)), Color("7a9b9d") if light else Color("597783"))
