extends Node2D

const PlayerScene = preload("res://scripts/player.gd")
const EnemyScene = preload("res://scripts/enemy.gd")
const PlatformScene = preload("res://scripts/moving_platform.gd")
const EffectsScene = preload("res://scripts/effects.gd")
const SfxScene = preload("res://scripts/sfx.gd")
const BulletScene = preload("res://scripts/reflectable_bullet.gd")
const BossBombScene = preload("res://scripts/boss_bomb.gd")
const SawScene = preload("res://scripts/clockwork_saw.gd")

const WORLD_WIDTH := 11550.0
const WORLD_LEFT := -80.0
const WORLD_TOP := -1740.0
const WORLD_BOTTOM := 216.0
const VERTICAL_SECTION_LEFT := 1925.0
const POST_VERTICAL_SECTION_LEFT := 2800.0
const DESCENT_SECTION_LEFT := 5270.0
const GAUNTLET_SECTION_LEFT := 6100.0
const DOUBLE_JUMP_SECTION_LEFT := 7420.0
const ARENA_SECTION_LEFT := 8580.0
const SUMMIT_SECTION_LEFT := 9720.0
const CLIMB_CAMERA_OFFSET_Y := -65.0
const LATE_CAMERA_OFFSET_Y := 0.0
const CAMERA_OFFSET_EASE_SPEED := 120.0
const BACKGROUND_REDRAW_INTERVAL := 1.0 / 30.0
const RUNTIME_REFRESH_INTERVAL := 0.12
const RUNTIME_TELEPORT_REFRESH_DISTANCE := 96.0
const DRAW_MARGIN := Vector2(128, 96)
const RUNTIME_MARGIN := Vector2(260, 190)
const SLOW_MOTION_SCALE := 0.35
const SLOW_MOTION_CAPACITY := 4.0
const SLOW_MOTION_RECHARGE_RATE := 0.7
const STARTUP_INSTRUCTION_TIME := 3.0
const DEATH_RESPAWN_DELAY := 0.68
const DEATH_CAMERA_ZOOM := Vector2(1.42, 1.42)
const POGO_SPIKE_LAYER := 32
const START_POSITION := Vector2(-30, 173)
const TEST_PORTAL_POSITION := Vector2(-62, 160)
const ARENA_CHECKPOINT_POSITION := Vector2(8625, -343)
const DASH_CHECKPOINT_POSITION := Vector2(1250, 173)
const TOWER_CHECKPOINT_POSITION := Vector2(1970, 136)
const DASH_PICKUP_POSITION := Vector2(1070, 88)
const DOUBLE_JUMP_PICKUP_POSITION := Vector2(7500, 76)
const DASH_RELAY_POINTS := [Vector2(1455, 130), Vector2(1585, 90), Vector2(1715, 135), Vector2(1845, 95)]
const VERTICAL_SPRING_DRONE_POINTS := [Vector2(2270, 30), Vector2(2515, -140)]
const VERTICAL_GEARWING_CONFIGS := [
	{"position": Vector2(2350, -20), "left": 2310.0, "right": 2390.0},
	{"position": Vector2(2600, -205), "left": 2560.0, "right": 2640.0},
]
const CLIMB_PLATFORM_RECTS := [
	Rect2(2110, 105, 80, 12),
	Rect2(2220, 67, 78, 12),
	Rect2(2100, 29, 76, 12),
	Rect2(2330, -48, 82, 12),
	Rect2(2440, -86, 82, 12),
	Rect2(2325, -124, 78, 12),
	Rect2(2435, -162, 80, 12),
	Rect2(2650, -238, 100, 12),
	Rect2(2735, -270, 145, 12),
]
const PRECISION_FOUNDRY_RECTS := [
	Rect2(2880, -270, 75, 12),
	Rect2(3040, -315, 62, 12),
	Rect2(3165, -270, 72, 12),
	Rect2(3290, -330, 58, 12),
	Rect2(3410, -285, 72, 12),
	Rect2(3530, -340, 110, 12),
]
const CANNON_GALLERY_RECTS := [
	Rect2(3640, -340, 80, 12),
	Rect2(3765, -300, 70, 12),
	Rect2(3890, -365, 68, 12),
	Rect2(4015, -315, 72, 12),
	Rect2(4145, -390, 60, 12),
	Rect2(4270, -335, 76, 12),
	Rect2(4400, -380, 100, 12),
]
const CROWN_ASCENT_RECTS := [
	Rect2(4500, -380, 90, 12),
	Rect2(4620, -425, 58, 12),
	Rect2(4725, -470, 56, 12),
	Rect2(4605, -520, 62, 12),
	Rect2(4770, -560, 60, 12),
	Rect2(4900, -605, 60, 12),
	Rect2(5030, -650, 240, 12),
]
const DESCENT_RECTS := [
	Rect2(5270, -650, 150, 12),
	Rect2(5460, -570, 160, 12),
	Rect2(5285, -485, 150, 12),
	Rect2(5510, -400, 155, 12),
	Rect2(5310, -315, 155, 12),
	Rect2(5540, -230, 155, 12),
	Rect2(5340, -145, 155, 12),
	Rect2(5570, -60, 155, 12),
	Rect2(5370, 25, 155, 12),
	Rect2(5550, 110, 390, 16),
	Rect2(5900, 145, 240, 36),
]
const GAUNTLET_RECTS := [
	Rect2(6100, 145, 105, 36),
	Rect2(6290, 104, 78, 12),
	Rect2(6480, 54, 74, 12),
	Rect2(6685, 104, 72, 12),
	Rect2(6890, 42, 76, 12),
	Rect2(7100, 96, 76, 12),
	Rect2(7290, 42, 92, 12),
	Rect2(7420, 110, 150, 16),
]
const DOUBLE_JUMP_RECTS := [
	Rect2(7555, 110, 90, 16),
	Rect2(7600, 42, 74, 12),
	Rect2(7770, -36, 72, 12),
	Rect2(7935, -118, 70, 12),
	Rect2(8110, -196, 72, 12),
	Rect2(8285, -272, 76, 12),
	Rect2(8455, -330, 150, 16),
]
const ARENA_RECTS := [
	Rect2(8580, -330, 180, 16),
	Rect2(8700, -226, 115, 12),
	Rect2(8870, -142, 105, 12),
	Rect2(9025, -245, 112, 12),
	Rect2(9200, -150, 110, 12),
	Rect2(9370, -252, 112, 12),
	Rect2(9535, -165, 110, 12),
	Rect2(8580, 50, 1120, 40),
	Rect2(9690, -330, 125, 16),
]
const SUMMIT_ASCENT_RECTS := [
	Rect2(9690, -330, 145, 16),
	Rect2(9870, -410, 82, 12),
	Rect2(9725, -500, 78, 12),
	Rect2(10010, -590, 84, 12),
	Rect2(9850, -680, 80, 12),
	Rect2(10140, -770, 84, 12),
	Rect2(9970, -860, 82, 12),
	Rect2(10285, -950, 84, 12),
	Rect2(10100, -1040, 82, 12),
	Rect2(10430, -1130, 84, 12),
	Rect2(10255, -1220, 82, 12),
	Rect2(10570, -1310, 88, 12),
	Rect2(10755, -1400, 90, 12),
	Rect2(10855, -1445, 82, 12),
	Rect2(10955, -1490, 96, 12),
	Rect2(10920, -1535, 90, 12),
	Rect2(10880, -1580, 430, 22),
]
const ADVANCED_ENEMY_CONFIGS := [
	{"kind": "tower_guard", "position": Vector2(3200, -281), "left": 3178.0, "right": 3225.0},
	{"kind": "tower_guard", "position": Vector2(3448, -296), "left": 3422.0, "right": 3470.0},
	{"kind": "shooter", "position": Vector2(3798, -311), "left": 3778.0, "right": 3822.0},
	{"kind": "shooter", "position": Vector2(4052, -326), "left": 4028.0, "right": 4074.0},
	{"kind": "shooter", "position": Vector2(4307, -346), "left": 4283.0, "right": 4333.0},
	{"kind": "tower_guard", "position": Vector2(4538, -391), "left": 4512.0, "right": 4575.0},
	{"kind": "tower_guard", "position": Vector2(4798, -571), "left": 4780.0, "right": 4818.0},
	{"kind": "shooter", "position": Vector2(4928, -616), "left": 4912.0, "right": 4948.0},
]
const DESCENT_ENEMY_CONFIGS := [
	{"kind": "descent_guard", "position": Vector2(5520, -582), "left": 5475.0, "right": 5605.0},
	{"kind": "descent_guard", "position": Vector2(5340, -497), "left": 5300.0, "right": 5420.0},
	{"kind": "descent_guard", "position": Vector2(5570, -412), "left": 5525.0, "right": 5650.0},
	{"kind": "descent_guard", "position": Vector2(5370, -327), "left": 5325.0, "right": 5450.0},
	{"kind": "descent_guard", "position": Vector2(5600, -242), "left": 5555.0, "right": 5680.0},
	{"kind": "descent_guard", "position": Vector2(5400, -157), "left": 5355.0, "right": 5480.0},
	{"kind": "descent_guard", "position": Vector2(5630, -72), "left": 5585.0, "right": 5685.0},
	{"kind": "descent_guard", "position": Vector2(5430, 13), "left": 5385.0, "right": 5510.0},
	{"kind": "descent_guard", "position": Vector2(5750, 98), "left": 5570.0, "right": 5920.0},
]
const SKY_ENEMY_CONFIGS := [
	{"kind": "sky_hunter", "position": Vector2(7690, -75), "left": 7630.0, "right": 7760.0},
	{"kind": "sky_hunter", "position": Vector2(7860, -155), "left": 7800.0, "right": 7930.0},
	{"kind": "sky_hunter", "position": Vector2(8040, -235), "left": 7970.0, "right": 8110.0},
	{"kind": "sky_hunter", "position": Vector2(8220, -315), "left": 8150.0, "right": 8290.0},
	{"kind": "sky_hunter", "position": Vector2(8390, -385), "left": 8320.0, "right": 8460.0},
]
const SUMMIT_ENEMY_CONFIGS := [
	{"kind": "descent_guard", "position": Vector2(9882, -422), "left": 9878.0, "right": 9944.0},
	{"kind": "sky_hunter", "position": Vector2(9860, -540), "left": 9780.0, "right": 9940.0},
	{"kind": "shooter", "position": Vector2(10050, -602), "left": 10018.0, "right": 10088.0},
	{"kind": "sky_hunter", "position": Vector2(10055, -810), "left": 9975.0, "right": 10135.0},
	{"kind": "descent_guard", "position": Vector2(10298, -962), "left": 10293.0, "right": 10362.0},
	{"kind": "shooter", "position": Vector2(10470, -1142), "left": 10438.0, "right": 10508.0},
	{"kind": "sky_hunter", "position": Vector2(10440, -1270), "left": 10340.0, "right": 10540.0},
	{"kind": "descent_guard", "position": Vector2(10768, -1412), "left": 10762.0, "right": 10838.0},
]
const ARENA_BOSS_CONFIGS := [
	{"kind": "boss_titan", "position": Vector2(8880, 24), "left": 8640.0, "right": 9610.0},
]
const CLOCKWORK_CORE_POSITION := Vector2(11095, -1604)
const FINAL_GOAL_POSITION := CLOCKWORK_CORE_POSITION
const RAM_START := Vector2(92, 172)
const COUNTER_RAM_START := Vector2(690, 172)
const CARRIAGE_START := Vector2(216, 166)
const RAIL_LEFT := 216.0
const RAIL_RIGHT := 1176.0
const RAM_LEFT := 42.0
const RAM_RIGHT := 560.0
const COUNTER_RAM_LEFT := 480.0
const COUNTER_RAM_RIGHT := 1190.0

var player: CharacterBody2D
var ram: Area2D
var counter_ram: Area2D
var rams: Array[Area2D] = []
var dash_relays: Array[Area2D] = []
var vertical_enemies: Array[Area2D] = []
var advanced_enemies: Array[Area2D] = []
var expansion_enemies: Array[Area2D] = []
var dash_pickup: Area2D
var double_jump_pickup: Area2D
var clockwork_core: Area2D
var test_portal: Area2D
var carriage: AnimatableBody2D
var arena_gate: StaticBody2D
var camera: Camera2D
var effects: Node2D
var sfx: Node
var blocks: Array[Rect2] = []
var spike_rects: Array[Rect2] = []
var mode := "play"
var attempts := 1
var last_event := "Launch the ram, then catch the carriage while both are moving."
var reset_ticket := 0
var dash_pickup_collected := false
var double_jump_collected := false
var clockwork_core_collected := false
var tower_checkpoint_reached := false
var arena_cleared := false
var late_checkpoint_order := 0
var late_checkpoint_position := Vector2.ZERO
var slow_motion_active := false
var slow_motion_energy := SLOW_MOTION_CAPACITY
var slow_motion_button_down := false
var visual_clock := 0.0
var elapsed := 0.0
var projectile_sound_cooldown := 0.0
var draw_refresh_time := 0.0
var runtime_refresh_time := 0.0
var last_runtime_center := Vector2(INF, INF)
var runtime_active_count := 0
var runtime_sleeping_count := 0
var last_drawn_block_count := 0
var last_drawn_spike_count := 0

var health_icons: Array[Label] = []
var result_label: Label
var slow_tint: ColorRect
var slow_label: Label
var slow_bar: ProgressBar
var timer_label: Label
var death_camera_tween: Tween

func _ready() -> void:
	_restore_time_scale()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_inputs()
	_build_level()
	_create_actors()
	_create_ui()
	reset_encounter()
	_show_startup_instructions()

func _exit_tree() -> void:
	_restore_time_scale()

func _process(delta: float) -> void:
	var real_delta := delta / SLOW_MOTION_SCALE if slow_motion_active else delta
	visual_clock += delta
	projectile_sound_cooldown = maxf(0.0, projectile_sound_cooldown - delta)
	_update_slow_motion(delta)
	if mode == "play":
		elapsed += real_delta
	_update_timer()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		attempts += 1
		reset_encounter()
	if mode == "play" and player.global_position.y > 230.0:
		_on_environmental_hazard()
	_update_camera_limits(delta)
	_update_runtime_activation(delta)
	draw_refresh_time -= delta
	if draw_refresh_time <= 0.0:
		draw_refresh_time = BACKGROUND_REDRAW_INTERVAL
		queue_redraw()

func _world_view_bounds(margin: Vector2 = Vector2.ZERO) -> Rect2:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(384, 216)
	var view_zoom := camera.zoom if is_instance_valid(camera) else Vector2.ONE
	var world_size := Vector2(viewport_size.x / maxf(view_zoom.x, 0.01), viewport_size.y / maxf(view_zoom.y, 0.01))
	var center := player.global_position if is_instance_valid(player) else START_POSITION
	if is_instance_valid(camera):
		center += camera.position
	return Rect2(center - world_size * 0.5 - margin, world_size + margin * 2.0)

func _update_runtime_activation(delta: float = 0.0, force: bool = false) -> void:
	if not is_instance_valid(player):
		return
	runtime_refresh_time -= delta
	var player_moved_far := last_runtime_center.distance_squared_to(player.global_position) > RUNTIME_TELEPORT_REFRESH_DISTANCE * RUNTIME_TELEPORT_REFRESH_DISTANCE
	if not force and runtime_refresh_time > 0.0 and not player_moved_far:
		return
	runtime_refresh_time = RUNTIME_REFRESH_INTERVAL
	last_runtime_center = player.global_position
	var active_bounds := _world_view_bounds(RUNTIME_MARGIN)
	runtime_active_count = 0
	runtime_sleeping_count = 0
	for runtime_node in get_tree().get_nodes_in_group("runtime_cullables"):
		if not is_instance_valid(runtime_node) or not runtime_node is Node2D:
			continue
		var should_be_active := active_bounds.has_point((runtime_node as Node2D).global_position)
		var was_active := bool(runtime_node.get_meta("runtime_active", true))
		if not runtime_node.has_meta("runtime_active") or should_be_active != was_active:
			runtime_node.set_meta("runtime_active", should_be_active)
			runtime_node.set_physics_process(should_be_active)
		if should_be_active:
			runtime_active_count += 1
		else:
			runtime_sleeping_count += 1

func _update_camera_limits(delta: float) -> void:
	if not is_instance_valid(camera) or not is_instance_valid(player):
		return
	camera.limit_top = int(WORLD_TOP if player.global_position.x >= VERTICAL_SECTION_LEFT else 0.0)
	var target_offset_y := LATE_CAMERA_OFFSET_Y if player.global_position.x >= POST_VERTICAL_SECTION_LEFT else CLIMB_CAMERA_OFFSET_Y
	camera.position.y = move_toward(camera.position.y, target_offset_y, CAMERA_OFFSET_EASE_SPEED * delta)

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

func _build_level() -> void:
	# The first four islands divide the kinetic hazards without dividing their ongoing physical state.
	_add_block(Rect2(WORLD_LEFT, 182, 260, 34))
	_add_test_portal()
	_add_block(Rect2(400, 182, 190, 34))
	_add_block(Rect2(650, 182, 180, 34))
	_add_block(Rect2(830, 182, 160, 34))
	_add_block(Rect2(1220, 182, 170, 34))
	_add_block(Rect2(995, 112, 150, 12), true)
	_add_block(Rect2(VERTICAL_SECTION_LEFT, 145, 275, 71))
	for rect in CLIMB_PLATFORM_RECTS:
		_add_block(rect)
	_add_moving_platform(Vector2(2210, -4), 100.0, 0.0)
	_add_moving_platform(Vector2(2535, -195), 100.0, 2.2)
	_add_block(Rect2(WORLD_LEFT - 16, WORLD_TOP, 16, WORLD_BOTTOM - WORLD_TOP))
	_add_block(Rect2(WORLD_WIDTH, WORLD_TOP, 16, WORLD_BOTTOM - WORLD_TOP))
	_add_spikes(Rect2(180, 182, 220, 34))
	_add_spikes(Rect2(590, 182, 60, 34))
	_add_spikes(Rect2(990, 182, 230, 34))
	_add_spikes(Rect2(1390, 182, 535, 34))
	_add_spikes(Rect2(2024, 137, 40, 8))
	_add_spikes(Rect2(2254, 59, 20, 8))
	_add_spikes(Rect2(2475, -94, 20, 8))
	_add_spikes(Rect2(2720, -246, 20, 8))
	_add_tower_checkpoint()
	_build_post_vertical_areas()
	_build_expansion_areas()
	_create_clockwork_core()

func _build_post_vertical_areas() -> void:
	for rect in PRECISION_FOUNDRY_RECTS:
		_add_block(rect)
	for rect in CANNON_GALLERY_RECTS:
		_add_block(rect)
	for rect in CROWN_ASCENT_RECTS:
		_add_block(rect)
	_add_spikes(Rect2(2880, -220, 760, 32))
	_add_spikes(Rect2(3640, -240, 860, 32))
	_add_spikes(Rect2(4500, -315, 800, 32))
	_add_moving_platform(Vector2(2990, -292), 42.0, 0.7, "post_vertical_moving_platforms")
	_add_moving_platform(Vector2(3850, -332), 48.0, 1.8, "post_vertical_moving_platforms")
	_add_moving_platform(Vector2(4690, -495), 55.0, 2.6, "post_vertical_moving_platforms")
	_add_late_checkpoint(1, Vector2(2845, -300), Vector2(2835, -279))
	_add_late_checkpoint(2, Vector2(3590, -370), Vector2(3580, -349))
	_add_late_checkpoint(3, Vector2(4450, -410), Vector2(4450, -389))

func _build_expansion_areas() -> void:
	for rect in DESCENT_RECTS:
		_add_block(rect)
	for rect in GAUNTLET_RECTS:
		_add_block(rect)
	for rect in DOUBLE_JUMP_RECTS:
		_add_block(rect)
	for rect in ARENA_RECTS:
		_add_block(rect)
	for rect in SUMMIT_ASCENT_RECTS:
		_add_block(rect)

	# The Transit is deliberately crowded with narrow safe caps, moving machinery,
	# and pogoable saws over one continuous spike bed.
	_add_spikes(Rect2(6100, 181, 1470, 35))
	for rect in [Rect2(6330, 96, 24, 8), Rect2(6506, 46, 25, 8), Rect2(6710, 96, 25, 8), Rect2(6916, 34, 26, 8), Rect2(7125, 88, 25, 8), Rect2(7318, 34, 26, 8)]:
		_add_spikes(rect)
	_add_moving_platform(Vector2(6215, 118), 70.0, 0.1, "gauntlet_moving_platforms")
	_add_moving_platform(Vector2(6400, 72), 62.0, 1.1, "gauntlet_moving_platforms")
	_add_moving_platform(Vector2(6590, 124), 72.0, 2.3, "gauntlet_moving_platforms")
	_add_moving_platform(Vector2(6800, 64), 68.0, 0.8, "gauntlet_moving_platforms")
	_add_moving_platform(Vector2(7005, 118), 72.0, 1.8, "gauntlet_moving_platforms")
	_add_moving_platform(Vector2(7210, 67), 65.0, 2.8, "gauntlet_moving_platforms")
	_add_saw(Vector2(6370, 15), Vector2(0, 45), 2.1, 11.0, 0.0)
	_add_saw(Vector2(6760, 8), Vector2(0, 52), 2.4, 12.0, 1.2)
	_add_saw(Vector2(7160, 10), Vector2(0, 48), 2.6, 11.0, 2.2)

	# Double-jump trial ledges are spaced beyond a normal jump's reliable rise.
	_add_spikes(Rect2(7575, 181, 1005, 35))
	for rect in [Rect2(7790, -44, 28, 8), Rect2(8132, -204, 28, 8), Rect2(8475, -338, 28, 8)]:
		_add_spikes(rect)
	_add_moving_platform(Vector2(7688, 2), 46.0, 0.5, "double_jump_platforms")
	_add_moving_platform(Vector2(8025, -158), 52.0, 2.0, "double_jump_platforms")
	_add_moving_platform(Vector2(8370, -300), 48.0, 1.0, "double_jump_platforms")
	_create_double_jump_pickup()

	# The arena has a continuous walkable floor while its irregular platforms keep
	# dash, pogo, reflection, and double-jump routes available throughout combat.
	_add_spikes(Rect2(8780, -234, 26, 8))
	_add_spikes(Rect2(9250, -158, 28, 8))
	_add_moving_platform(Vector2(8815, -60), 85.0, 0.2, "arena_moving_platforms")
	_add_moving_platform(Vector2(9170, -65), 105.0, 1.7, "arena_moving_platforms")
	_add_moving_platform(Vector2(9500, -70), 72.0, 2.8, "arena_moving_platforms")
	_add_saw(Vector2(9000, -75), Vector2(0, 70), 1.7, 13.0, 0.4)
	_add_saw(Vector2(9400, -80), Vector2(0, 65), 1.9, 13.0, 2.4)
	_add_arena_gate(Rect2(9680, WORLD_TOP, 24, 1790))

	# The summit climb combines every hazard family and resolves at the Clockwork Core.
	for rect in [Rect2(9922, -418, 28, 8), Rect2(9748, -508, 28, 8), Rect2(10035, -598, 28, 8), Rect2(9875, -688, 28, 8), Rect2(10165, -778, 28, 8), Rect2(10339, -958, 28, 8), Rect2(10455, -1138, 28, 8), Rect2(10600, -1318, 28, 8), Rect2(10815, -1408, 28, 8)]:
		_add_spikes(rect)
	_add_moving_platform(Vector2(9800, -455), 58.0, 0.4, "summit_moving_platforms")
	_add_moving_platform(Vector2(10060, -725), 62.0, 1.4, "summit_moving_platforms")
	_add_moving_platform(Vector2(10230, -1085), 70.0, 2.1, "summit_moving_platforms")
	_add_moving_platform(Vector2(10690, -1355), 60.0, 2.8, "summit_moving_platforms")
	_add_saw(Vector2(9950, -535), Vector2(62, 0), 2.0, 12.0, 0.0)
	_add_saw(Vector2(10120, -900), Vector2(70, 0), 2.3, 12.0, 1.2)
	_add_saw(Vector2(10420, -1260), Vector2(72, 0), 2.5, 13.0, 2.3)

	_add_late_checkpoint(4, Vector2(5320, -675), Vector2(5320, -663))
	_add_late_checkpoint(5, Vector2(6135, 105), Vector2(6135, 130))
	_add_late_checkpoint(6, Vector2(7485, 70), Vector2(7460, 96))
	_add_late_checkpoint(7, Vector2(8625, -370), Vector2(8625, -343))
	_add_late_checkpoint(8, Vector2(9750, -370), Vector2(9750, -343))
	_add_late_checkpoint(9, Vector2(9890, -720), Vector2(9890, -693))
	_add_late_checkpoint(10, Vector2(10140, -1080), Vector2(10140, -1053))
	_add_late_checkpoint(11, Vector2(10620, -1350), Vector2(10620, -1323))
	_add_late_checkpoint(12, Vector2(10985, -1530), Vector2(10985, -1503))

func _add_moving_platform(at: Vector2, distance: float, phase: float, group_name: String = "kinetic_climb_platforms") -> void:
	var platform := PlatformScene.new()
	platform.configure(at, distance)
	platform.add_to_group(group_name)
	add_child(platform)
	platform.clock = phase

func _add_saw(at: Vector2, travel: Vector2, speed: float, radius: float, phase: float) -> void:
	var saw := SawScene.new() as Area2D
	saw.configure(at, travel, speed, radius, phase)
	saw.hit_player.connect(_on_ram_touched_player)
	add_child(saw)

func _add_late_checkpoint(order: int, at: Vector2, respawn: Vector2) -> void:
	var area := Area2D.new()
	area.position = at
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitoring = true
	area.set_meta("checkpoint_order", order)
	area.set_meta("respawn_position", respawn)
	area.add_to_group("post_vertical_checkpoints" if order <= 3 else "expansion_checkpoints")
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(54, 70)
	collision.shape = shape
	area.add_child(collision)
	area.body_entered.connect(_on_late_checkpoint_body.bind(order, respawn))
	add_child(area)

func _add_test_portal() -> void:
	test_portal = Area2D.new()
	test_portal.name = "BossTestPortal"
	test_portal.position = TEST_PORTAL_POSITION
	test_portal.collision_layer = 0
	test_portal.collision_mask = 2
	test_portal.monitoring = true
	test_portal.add_to_group("boss_test_portal")
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(22, 38)
	collision.shape = shape
	test_portal.add_child(collision)
	test_portal.body_entered.connect(_on_test_portal_body)
	add_child(test_portal)

func _on_test_portal_body(body: Node2D) -> void:
	if mode != "play" or not body.is_in_group("player"):
		return
	_set_slow_motion(false)
	_clear_projectiles()
	dash_pickup_collected = true
	double_jump_collected = true
	late_checkpoint_order = 7
	late_checkpoint_position = ARENA_CHECKPOINT_POSITION
	player.dash_enabled = true
	player.double_jump_enabled = true
	if is_instance_valid(dash_pickup):
		dash_pickup.hide()
		dash_pickup.set_deferred("monitoring", false)
	if is_instance_valid(double_jump_pickup):
		double_jump_pickup.hide()
		double_jump_pickup.set_deferred("monitoring", false)
	player.reset_at(ARENA_CHECKPOINT_POSITION)
	last_event = "TEST WARP  all cores online  Titan arena checkpoint loaded."
	result_label.text = "ALL CORES\nTITAN WARP"
	effects.burst(ARENA_CHECKPOINT_POSITION + Vector2(0, -8), Color("d7a9ff"), 20)
	sfx.play("powerup")
	if is_instance_valid(camera):
		camera.reset_smoothing()
	_update_runtime_activation(0.0, true)
	_update_health_icons()
	queue_redraw()
	var ticket := reset_ticket
	await get_tree().create_timer(1.4).timeout
	if mode == "play" and ticket == reset_ticket and result_label.text == "ALL CORES\nTITAN WARP":
		result_label.text = ""

func _on_late_checkpoint_body(body: Node2D, order: int, respawn: Vector2) -> void:
	if not dash_pickup_collected or not body.is_in_group("player") or order <= late_checkpoint_order:
		return
	late_checkpoint_order = order
	late_checkpoint_position = respawn
	last_event = "AREA CHECKPOINT  %d/12 post-tower sectors secured." % order
	if order >= 8:
		arena_cleared = true
		result_label.text = ""
	effects.burst(respawn + Vector2(0, -10), Color("f0bd68"), 16)
	sfx.play("checkpoint")
	_update_health_icons()
	queue_redraw()

func _add_tower_checkpoint() -> void:
	var area := Area2D.new()
	area.position = Vector2(2060, 120)
	area.collision_layer = 0
	area.collision_mask = 2
	area.monitoring = true
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(260, 50)
	collision.shape = shape
	area.add_child(collision)
	area.body_entered.connect(_on_tower_checkpoint_body)
	add_child(area)

func _on_tower_checkpoint_body(body: Node2D) -> void:
	if tower_checkpoint_reached or not dash_pickup_collected or not body.is_in_group("player"):
		return
	tower_checkpoint_reached = true
	last_event = "TOWER CHECKPOINT  the vertical works are now the restart point."
	effects.burst(TOWER_CHECKPOINT_POSITION + Vector2(0, -12), Color("a9f4dd"), 14)
	sfx.play("checkpoint")
	queue_redraw()

func _create_actors() -> void:
	carriage = PlatformScene.new()
	carriage.name = "RelayCarriage"
	carriage.configure_kinetic(CARRIAGE_START, RAIL_LEFT, RAIL_RIGHT)
	carriage.kinetic_friction = 3.0
	carriage.ram_impact.connect(_on_ram_hit_carriage)
	carriage.directly_struck.connect(_on_carriage_struck)
	carriage.stop_rebounded.connect(_on_carriage_stop)
	add_child(carriage)

	ram = _create_ram("LaunchRam", RAM_START, RAM_LEFT, RAM_RIGHT, "LAUNCH")
	counter_ram = _create_ram("CounterRam", COUNTER_RAM_START, COUNTER_RAM_LEFT, COUNTER_RAM_RIGHT, "COUNTER")

	player = PlayerScene.new()
	player.position = START_POSITION
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	player.rebounded.connect(_on_player_rebounded)
	player.attack_connected.connect(_on_player_attack_connected)
	player.dashed.connect(_on_player_dashed)
	player.dash_connected.connect(_on_dash_connected)
	player.jumped.connect(func(_point: Vector2) -> void: sfx.play("jump"))
	player.double_jumped.connect(_on_player_double_jumped)
	add_child(player)

	camera = Camera2D.new()
	camera.position = Vector2(0, CLIMB_CAMERA_OFFSET_Y)
	camera.limit_left = int(WORLD_LEFT)
	camera.limit_right = int(WORLD_WIDTH)
	camera.limit_top = 0
	camera.limit_bottom = int(WORLD_BOTTOM)
	camera.limit_smoothed = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)

	effects = EffectsScene.new()
	add_child(effects)
	sfx = SfxScene.new()
	add_child(sfx)

func _create_ram(node_name: String, at: Vector2, left: float, right: float, label: String) -> Area2D:
	var actor := EnemyScene.new() as Area2D
	actor.name = node_name
	actor.configure_kinetic_ram(at, left, right)
	actor.touched_player.connect(_on_ram_touched_player)
	actor.kinetic_struck.connect(func(player_speed: float, ram_speed: float) -> void:
		_on_ram_struck(label, actor, player_speed, ram_speed)
	)
	actor.carriage_hit.connect(func(_ram_speed: float, _carriage_speed: float) -> void: sfx.play("hit"))
	actor.defeated.connect(func(at: Vector2) -> void:
		last_event = "%s RAM DESTROYED  threat removed." % label
		effects.burst(at, Color("f0bd68"), 14)
		sfx.play("hit")
	)
	add_child(actor)
	rams.append(actor)
	return actor

func _recreate_dash_section(include_pickup: bool) -> void:
	for relay in dash_relays:
		if is_instance_valid(relay):
			relay.free()
	dash_relays.clear()
	if is_instance_valid(dash_pickup):
		dash_pickup.free()
	dash_pickup = null
	for point in DASH_RELAY_POINTS:
		var relay := EnemyScene.new() as Area2D
		relay.configure("dash_relay", point, point.x, point.x)
		relay.touched_player.connect(_on_ram_touched_player)
		relay.defeated.connect(func(at: Vector2) -> void:
			effects.burst(at, Color("a9f4dd"), 10)
			sfx.play("hit")
		)
		add_child(relay)
		dash_relays.append(relay)
	if include_pickup:
		_create_dash_pickup()

func _recreate_vertical_enemies() -> void:
	for enemy in vertical_enemies:
		if is_instance_valid(enemy):
			enemy.free()
	vertical_enemies.clear()
	for point in VERTICAL_SPRING_DRONE_POINTS:
		_create_vertical_enemy("spring_drone", point, point.x, point.x)
	for config in VERTICAL_GEARWING_CONFIGS:
		_create_vertical_enemy("gearwing", config["position"], config["left"], config["right"])

func _create_vertical_enemy(kind: String, at: Vector2, left: float, right: float) -> void:
	var enemy := EnemyScene.new() as Area2D
	enemy.configure(kind, at, left, right)
	enemy.touched_player.connect(_on_ram_touched_player)
	enemy.defeated.connect(func(point: Vector2) -> void:
		effects.burst(point, Color("a9f4dd"), 10)
		sfx.play("attack_hit")
	)
	add_child(enemy)
	vertical_enemies.append(enemy)

func _recreate_advanced_enemies() -> void:
	for enemy in advanced_enemies:
		if is_instance_valid(enemy):
			enemy.free()
	advanced_enemies.clear()
	for config in ADVANCED_ENEMY_CONFIGS:
		var enemy := EnemyScene.new() as Area2D
		enemy.configure(config["kind"], config["position"], config["left"], config["right"])
		enemy.touched_player.connect(_on_ram_touched_player)
		enemy.defeated.connect(func(point: Vector2) -> void:
			effects.burst(point, Color("f0bd68"), 12)
			sfx.play("attack_hit")
		)
		if config["kind"] == "shooter":
			enemy.projectile_fired.connect(_spawn_reflectable_projectile)
		add_child(enemy)
		advanced_enemies.append(enemy)

func _recreate_expansion_enemies() -> void:
	for enemy in expansion_enemies:
		if is_instance_valid(enemy):
			enemy.free()
	expansion_enemies.clear()
	for config in DESCENT_ENEMY_CONFIGS:
		_create_expansion_enemy(config, "descent_enemies")
	for config in SKY_ENEMY_CONFIGS:
		_create_expansion_enemy(config, "sky_hunters")
	for config in SUMMIT_ENEMY_CONFIGS:
		_create_expansion_enemy(config, "summit_enemies")
	if not arena_cleared:
		for config in ARENA_BOSS_CONFIGS:
			_create_expansion_enemy(config, "arena_bosses")
	_set_arena_gate_open(arena_cleared)

func _create_expansion_enemy(config: Dictionary, group_name: String) -> void:
	var enemy := EnemyScene.new() as Area2D
	enemy.configure(config["kind"], config["position"], config["left"], config["right"])
	enemy.add_to_group(group_name)
	enemy.touched_player.connect(_on_ram_touched_player)
	enemy.defeated.connect(_on_expansion_enemy_defeated.bind(enemy))
	enemy.hazard_struck.connect(_on_enemy_hazard_struck)
	if config["kind"] in ["shooter", "boss_titan", "boss_warden"]:
		enemy.projectile_fired.connect(_spawn_reflectable_projectile)
	if config["kind"] == "boss_titan":
		enemy.bomb_fired.connect(_spawn_boss_bomb)
	add_child(enemy)
	expansion_enemies.append(enemy)

func _on_enemy_hazard_struck(at: Vector2) -> void:
	effects.impact(at, Color("ffad6f"), Vector2.UP)
	sfx.play("hit")

func _on_expansion_enemy_defeated(at: Vector2, enemy: Area2D) -> void:
	var is_boss: bool = is_instance_valid(enemy) and enemy.kind in ["boss_titan", "boss_warden"]
	effects.burst(at, Color("ff9a78") if is_boss else Color("d7a9ff"), 22 if is_boss else 12)
	sfx.play("boss_down" if is_boss else "attack_hit")
	if not is_boss:
		return
	var living_bosses := 0
	for candidate in expansion_enemies:
		if is_instance_valid(candidate) and candidate.kind in ["boss_titan", "boss_warden"] and candidate.alive:
			living_bosses += 1
	if living_bosses == 0:
		arena_cleared = true
		_set_arena_gate_open(true)
		last_event = "TITAN REGULATOR DEFEATED  summit gate released."
		result_label.text = "ARENA CLEARED\nSUMMIT GATE OPEN"
		sfx.play("gate_open")

func _spawn_reflectable_projectile(at: Vector2, direction: Vector2) -> void:
	if mode != "play" or direction.is_zero_approx():
		return
	var bullet := BulletScene.new() as Area2D
	bullet.configure(at, direction.normalized() * 115.0)
	bullet.hit_player.connect(_on_ram_touched_player)
	bullet.reflected.connect(func(point: Vector2) -> void:
		effects.burst(point, Color("a9f4dd"), 6)
		sfx.play("reflect")
	)
	add_child(bullet)
	if projectile_sound_cooldown <= 0.0:
		sfx.play("shoot")
		projectile_sound_cooldown = 0.04

func _spawn_boss_bomb(at: Vector2, initial_velocity: Vector2) -> void:
	if mode != "play" or initial_velocity.is_zero_approx():
		return
	var bomb := BossBombScene.new() as Area2D
	bomb.configure(at, initial_velocity)
	bomb.hit_player.connect(_on_ram_touched_player)
	bomb.reflected.connect(func(point: Vector2) -> void:
		effects.burst(point, Color("a9f4dd"), 8)
		sfx.play("reflect")
	)
	bomb.detonated.connect(func(point: Vector2) -> void:
		effects.burst(point, Color("ff8a66"), 16)
	)
	add_child(bomb)
	sfx.play("shoot")

func _clear_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("reflectable_projectiles"):
		if is_instance_valid(projectile):
			projectile.free()

func _create_dash_pickup() -> void:
	dash_pickup = Area2D.new()
	dash_pickup.name = "DashCore"
	dash_pickup.position = DASH_PICKUP_POSITION
	dash_pickup.collision_layer = 0
	dash_pickup.collision_mask = 2
	dash_pickup.monitoring = true
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 26)
	collision.shape = shape
	dash_pickup.add_child(collision)
	dash_pickup.body_entered.connect(_on_dash_pickup_body)
	add_child(dash_pickup)

func _create_double_jump_pickup() -> void:
	double_jump_pickup = Area2D.new()
	double_jump_pickup.name = "DoubleJumpCore"
	double_jump_pickup.position = DOUBLE_JUMP_PICKUP_POSITION
	double_jump_pickup.collision_layer = 0
	double_jump_pickup.collision_mask = 2
	double_jump_pickup.monitoring = true
	double_jump_pickup.add_to_group("double_jump_pickup")
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 30)
	collision.shape = shape
	double_jump_pickup.add_child(collision)
	double_jump_pickup.body_entered.connect(_on_double_jump_pickup_body)
	add_child(double_jump_pickup)

func _on_double_jump_pickup_body(body: Node2D) -> void:
	if double_jump_collected or not body.is_in_group("player"):
		return
	double_jump_collected = true
	player.double_jump_enabled = true
	player.double_jump_available = true
	double_jump_pickup.set_deferred("monitoring", false)
	double_jump_pickup.hide()
	last_event = "AERIAL CORE ACQUIRED  jump again while airborne."
	result_label.text = "DOUBLE JUMP"
	effects.burst(DOUBLE_JUMP_PICKUP_POSITION, Color("d7a9ff"), 24)
	sfx.play("powerup")
	_update_health_icons()
	queue_redraw()
	var ticket := reset_ticket
	await get_tree().create_timer(1.5).timeout
	if mode == "play" and double_jump_collected and ticket == reset_ticket:
		result_label.text = ""

func _reset_double_jump_pickup() -> void:
	if not is_instance_valid(double_jump_pickup):
		return
	double_jump_pickup.visible = not double_jump_collected
	double_jump_pickup.set_deferred("monitoring", not double_jump_collected)

func _add_arena_gate(rect: Rect2) -> void:
	arena_gate = StaticBody2D.new()
	arena_gate.name = "ArenaGate"
	arena_gate.position = rect.get_center()
	arena_gate.collision_layer = 1
	arena_gate.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	arena_gate.add_child(collision)
	add_child(arena_gate)

func _set_arena_gate_open(open: bool) -> void:
	if is_instance_valid(arena_gate):
		arena_gate.collision_layer = 0 if open else 1
	queue_redraw()

func _on_dash_pickup_body(body: Node2D) -> void:
	if dash_pickup_collected or not body.is_in_group("player"):
		return
	dash_pickup_collected = true
	player.dash_enabled = true
	player.dash_ready = true
	dash_pickup.set_deferred("monitoring", false)
	dash_pickup.hide()
	last_event = "DASH CORE ACQUIRED  aim toward a relay, then dash through it."
	result_label.text = "DASH CORE"
	_update_health_icons()
	effects.burst(DASH_PICKUP_POSITION, Color("a9f4dd"), 18)
	sfx.play("checkpoint")
	queue_redraw()
	var ticket := reset_ticket
	await get_tree().create_timer(1.35).timeout
	if mode == "play" and dash_pickup_collected and ticket == reset_ticket:
		result_label.text = ""

func _reset_dash_checkpoint() -> void:
	_reset_slow_motion_meter()
	reset_ticket += 1
	mode = "play"
	if is_instance_valid(carriage):
		carriage.reset_kinetic()
	_clear_projectiles()
	_recreate_dash_section(false)
	_recreate_vertical_enemies()
	_recreate_advanced_enemies()
	_recreate_expansion_enemies()
	player.dash_enabled = true
	player.double_jump_enabled = double_jump_collected
	var respawn_position := late_checkpoint_position if late_checkpoint_order > 0 else TOWER_CHECKPOINT_POSITION if tower_checkpoint_reached else DASH_CHECKPOINT_POSITION
	player.reset_at(respawn_position)
	_reset_death_presentation()
	if is_instance_valid(camera):
		camera.reset_smoothing()
	last_event = "Dash checkpoint restored. Chain every shielded relay to cross."
	result_label.text = ""
	_update_health_icons()
	_update_runtime_activation(0.0, true)
	queue_redraw()

func reset_encounter(reset_timer: bool = true) -> void:
	_reset_slow_motion_meter()
	if reset_timer:
		elapsed = 0.0
	reset_ticket += 1
	mode = "play"
	dash_pickup_collected = false
	double_jump_collected = false
	clockwork_core_collected = false
	tower_checkpoint_reached = false
	arena_cleared = false
	late_checkpoint_order = 0
	late_checkpoint_position = Vector2.ZERO
	if is_instance_valid(carriage):
		carriage.reset_kinetic()
	for actor in rams:
		if is_instance_valid(actor):
			actor.reset_kinetic()
	if is_instance_valid(ram):
		ram.cooldown = 0.05
	if is_instance_valid(player):
		player.dash_enabled = false
		player.double_jump_enabled = false
		player.reset_at(START_POSITION)
	_reset_death_presentation()
	_clear_projectiles()
	_recreate_dash_section(true)
	_recreate_vertical_enemies()
	_recreate_advanced_enemies()
	_reset_double_jump_pickup()
	_reset_clockwork_core()
	_recreate_expansion_enemies()
	if is_instance_valid(camera):
		camera.reset_smoothing()
	last_event = "Launch the ram, then catch the carriage while both are moving."
	if result_label != null:
		result_label.text = ""
	_update_health_icons()
	_update_runtime_activation(0.0, true)
	queue_redraw()

func _on_player_died() -> void:
	if mode != "play":
		return
	_set_slow_motion(false)
	mode = "dead"
	attempts += 1
	last_event = "The relay resets quickly; momentum mistakes on an island do not."
	effects.burst(player.global_position, Color("e9876c"), 12)
	sfx.play("death")
	result_label.text = "SYSTEM FAILURE\nREWINDING  %s" % _format_time(elapsed)
	if death_camera_tween != null and death_camera_tween.is_valid():
		death_camera_tween.kill()
	death_camera_tween = create_tween()
	death_camera_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	death_camera_tween.tween_property(camera, "zoom", DEATH_CAMERA_ZOOM, 0.2)
	var ticket := reset_ticket
	await get_tree().create_timer(DEATH_RESPAWN_DELAY).timeout
	if mode == "dead" and ticket == reset_ticket:
		if dash_pickup_collected:
			_reset_dash_checkpoint()
		else:
			reset_encounter(false)

func _on_environmental_hazard() -> void:
	if mode == "play":
		player.take_hazard_damage()

func _on_ram_touched_player(source: Vector2) -> void:
	if mode == "play":
		var previous_health: int = player.health
		player.take_damage(source)
		if player.health < previous_health and player.health > 0:
			last_event = "IMPACT  armor damaged  %d/3 health remains." % player.health

func _on_player_health_changed(value: int) -> void:
	if value > 0 and value < 3 and effects != null and sfx != null:
		effects.burst(player.global_position, Color("e9876c"), 8)
		sfx.play("hit")
	_update_health_icons()

func _on_player_rebounded(at: Vector2) -> void:
	effects.burst(at, Color("f6d68c"), 8)
	sfx.play("bounce")

func _on_player_double_jumped(at: Vector2) -> void:
	effects.burst(at + Vector2(0, 7), Color("d7a9ff"), 12)
	sfx.play("double_jump")
	last_event = "AERIAL CORE  second jump fired."

func _on_player_attack_connected(at: Vector2) -> void:
	# Downward kinetic strikes publish a more specific momentum-transfer event first.
	if player.attack_direction.y <= 0.0:
		last_event = "DIRECTIONAL ATTACK  connected."
	effects.impact(at, Color("f6d68c"), player.attack_direction)
	sfx.play("attack_hit")

func _on_player_dashed(at: Vector2) -> void:
	effects.burst(at, Color("a9f4dd"), 7)
	sfx.play("dash")

func _on_dash_connected(at: Vector2) -> void:
	effects.impact(at, Color("a9f4dd"), player.dash_direction)

func _on_ram_struck(label: String, actor: Area2D, player_speed: float, ram_speed: float) -> void:
	last_event = "%s REDIRECT  player %+.0f  -> ram %+.0f" % [label, player_speed, ram_speed]
	effects.burst(actor.global_position, Color("fff1ac"), 8)

func _on_ram_hit_carriage(ram_speed: float, carriage_speed: float) -> void:
	last_event = "IMPACT  ram %+.0f  -> carriage %+.0f" % [ram_speed, carriage_speed]
	effects.burst(carriage.global_position, Color("a9f4dd"), 10)

func _on_carriage_struck(player_speed: float, carriage_speed: float) -> void:
	last_event = "MID-AIR CORRECTION  player %+.0f  -> carriage %+.0f" % [player_speed, carriage_speed]
	effects.burst(carriage.global_position + Vector2(0, -16), Color("fff1ac"), 7)

func _on_carriage_stop(side: int, incoming_speed: float, outgoing_speed: float) -> void:
	last_event = "%s REBOUND  carriage %+.0f  -> %+.0f" % ["FAR" if side > 0 else "START", incoming_speed, outgoing_speed]
	sfx.play("hit")

func _add_block(rect: Rect2, one_way: bool = false) -> void:
	blocks.append(rect)
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.one_way_collision = one_way
	if one_way:
		collision.one_way_collision_margin = 3.0
	body.add_child(collision)
	add_child(body)

func _add_spikes(rect: Rect2) -> void:
	spike_rects.append(rect)
	var foundation_height := maxf(2.0, rect.size.y - 7.0)
	var foundation := StaticBody2D.new()
	foundation.name = "SpikeFoundation"
	foundation.position = Vector2(rect.get_center().x, rect.position.y + 7.0 + foundation_height * 0.5)
	foundation.collision_layer = 1
	foundation.collision_mask = 0
	foundation.add_to_group("spike_foundations")
	var foundation_collision := CollisionShape2D.new()
	var foundation_shape := RectangleShape2D.new()
	foundation_shape.size = Vector2(rect.size.x, foundation_height)
	foundation_collision.shape = foundation_shape
	foundation.add_child(foundation_collision)
	add_child(foundation)
	var hitbox := Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 2))
	var area := Area2D.new()
	area.position = hitbox.get_center()
	area.collision_layer = POGO_SPIKE_LAYER
	area.collision_mask = 2
	area.monitoring = true
	area.add_to_group("kinetic_spikes")
	area.add_to_group("pogo_spikes")
	area.set_meta("hitbox_rect", hitbox)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = hitbox.size
	collision.shape = shape
	area.add_child(collision)
	area.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and mode == "play" and not (body.has_method("is_pogo_safe") and body.is_pogo_safe()):
			_on_environmental_hazard()
	)
	add_child(area)

func _create_clockwork_core() -> void:
	clockwork_core = Area2D.new()
	clockwork_core.name = "ClockworkCore"
	clockwork_core.position = CLOCKWORK_CORE_POSITION
	clockwork_core.collision_layer = 0
	clockwork_core.collision_mask = 2
	clockwork_core.monitoring = true
	clockwork_core.add_to_group("clockwork_core")
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(36, 42)
	collision.shape = shape
	clockwork_core.add_child(collision)
	clockwork_core.body_entered.connect(_on_clockwork_core_body)
	add_child(clockwork_core)

func _on_clockwork_core_body(body: Node2D) -> void:
	if clockwork_core_collected or mode != "play" or not body.is_in_group("player"):
		return
	clockwork_core_collected = true
	clockwork_core.set_deferred("monitoring", false)
	clockwork_core.hide()
	_set_slow_motion(false)
	_clear_projectiles()
	mode = "complete"
	player.active = false
	player.velocity = Vector2.ZERO
	last_event = "CLOCKWORK CORE RESTORED  ascent complete."
	result_label.text = "CLOCKWORK CORE RESTORED  %s\nASCENT COMPLETE" % _format_time(elapsed)
	effects.burst(CLOCKWORK_CORE_POSITION, Color("fff1ac"), 32)
	sfx.play("powerup")
	sfx.play("win")
	queue_redraw()

func _reset_clockwork_core() -> void:
	if not is_instance_valid(clockwork_core):
		return
	clockwork_core.visible = not clockwork_core_collected
	clockwork_core.set_deferred("monitoring", not clockwork_core_collected)

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
	health_icons.clear()
	for icon_index in 3:
		var health_icon := _label(Vector2(7 + icon_index * 13, 4), Vector2(12, 15), 13, Color("e9876c"))
		health_icon.text = "◆"
		health_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		canvas.add_child(health_icon)
		health_icons.append(health_icon)
	timer_label = _label(Vector2(255, 5), Vector2(66, 14), 9, Color("fff1ac"))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	canvas.add_child(timer_label)
	slow_label = _label(Vector2(330, 3), Vector2(46, 11), 7, Color("7fa3aa"))
	slow_label.text = "SLOW"
	slow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	canvas.add_child(slow_label)
	slow_bar = _slow_motion_bar(Vector2(331, 15))
	canvas.add_child(slow_bar)
	slow_bar.size = Vector2(45, 4)
	result_label = _label(Vector2(65, 68), Vector2(254, 55), 15, Color("fff1ac"))
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	canvas.add_child(result_label)
	_update_health_icons()
	_update_timer()

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

func _update_timer() -> void:
	if timer_label != null:
		var timer_text := _format_time(elapsed)
		if timer_label.text != timer_text:
			timer_label.text = timer_text

func _show_startup_instructions() -> void:
	if result_label == null:
		return
	const STARTUP_TEXT := "WASD  MOVE\nJ  ATTACK"
	result_label.text = STARTUP_TEXT
	var ticket := reset_ticket
	await get_tree().create_timer(STARTUP_INSTRUCTION_TIME).timeout
	if mode == "play" and ticket == reset_ticket and result_label.text == STARTUP_TEXT:
		result_label.text = ""

func _format_time(value: float) -> String:
	var total_tenths := maxi(0, int(floor(value * 10.0)))
	var minutes := int(total_tenths / 600)
	var seconds := int(total_tenths / 10) % 60
	var tenths := total_tenths % 10
	return "%02d:%02d.%d" % [minutes, seconds, tenths]

func _reset_death_presentation() -> void:
	if death_camera_tween != null and death_camera_tween.is_valid():
		death_camera_tween.kill()
	death_camera_tween = null
	if is_instance_valid(camera):
		camera.zoom = Vector2.ONE
		if is_instance_valid(player):
			camera.position.y = LATE_CAMERA_OFFSET_Y if player.global_position.x >= POST_VERTICAL_SECTION_LEFT else CLIMB_CAMERA_OFFSET_Y

func _update_health_icons() -> void:
	if player == null:
		return
	for icon_index in health_icons.size():
		var icon := health_icons[icon_index]
		icon.add_theme_color_override("font_color", Color("e9876c") if icon_index < player.health else Color("35434b"))

func _draw() -> void:
	var draw_bounds := _world_view_bounds(DRAW_MARGIN)
	draw_rect(Rect2(WORLD_LEFT, WORLD_TOP, WORLD_WIDTH - WORLD_LEFT, WORLD_BOTTOM - WORLD_TOP), Color("111c2a"))
	draw_rect(Rect2(WORLD_LEFT, 40, 440 - WORLD_LEFT, 176), Color("182737"))
	draw_rect(Rect2(440, 40, 390, 176), Color("172533"))
	draw_rect(Rect2(830, 40, 530, 176), Color("182737"))
	draw_rect(Rect2(1360, 40, 565, 176), Color("142431"))
	draw_rect(Rect2(VERTICAL_SECTION_LEFT, WORLD_TOP, WORLD_WIDTH - VERTICAL_SECTION_LEFT, WORLD_BOTTOM - WORLD_TOP), Color("13222f"))
	draw_rect(Rect2(2880, WORLD_TOP, 760, WORLD_BOTTOM - WORLD_TOP), Color("182633"))
	draw_rect(Rect2(3640, WORLD_TOP, 860, WORLD_BOTTOM - WORLD_TOP), Color("202837"))
	draw_rect(Rect2(4500, WORLD_TOP, 800, WORLD_BOTTOM - WORLD_TOP), Color("172430"))
	draw_rect(Rect2(DESCENT_SECTION_LEFT, WORLD_TOP, GAUNTLET_SECTION_LEFT - DESCENT_SECTION_LEFT, WORLD_BOTTOM - WORLD_TOP), Color("241f2e"))
	draw_rect(Rect2(GAUNTLET_SECTION_LEFT, WORLD_TOP, DOUBLE_JUMP_SECTION_LEFT - GAUNTLET_SECTION_LEFT, WORLD_BOTTOM - WORLD_TOP), Color("1e2932"))
	draw_rect(Rect2(DOUBLE_JUMP_SECTION_LEFT, WORLD_TOP, ARENA_SECTION_LEFT - DOUBLE_JUMP_SECTION_LEFT, WORLD_BOTTOM - WORLD_TOP), Color("20233a"))
	draw_rect(Rect2(ARENA_SECTION_LEFT, WORLD_TOP, SUMMIT_SECTION_LEFT - ARENA_SECTION_LEFT, WORLD_BOTTOM - WORLD_TOP), Color("2a2029"))
	draw_rect(Rect2(SUMMIT_SECTION_LEFT, WORLD_TOP, WORLD_WIDTH - SUMMIT_SECTION_LEFT, WORLD_BOTTOM - WORLD_TOP), Color("172633"))
	_draw_clockwork_background(draw_bounds)
	var grid_left := maxf(1948.0, draw_bounds.position.x)
	var grid_right := minf(WORLD_WIDTH - 24.0, draw_bounds.end.x)
	var horizontal_start := maxi(int(WORLD_TOP), _aligned_range_start(draw_bounds.position.y, int(WORLD_TOP), 64))
	var horizontal_end := mini(180, int(ceil(draw_bounds.end.y)))
	if grid_right > grid_left:
		for y in range(horizontal_start, horizontal_end, 64):
			draw_rect(Rect2(grid_left, y, grid_right - grid_left, 2), Color("213542"))
	var vertical_start := maxi(1990, _aligned_range_start(draw_bounds.position.x, 1990, 128))
	var vertical_end := mini(int(WORLD_WIDTH), int(ceil(draw_bounds.end.x)))
	for x in range(vertical_start, vertical_end, 128):
		draw_rect(Rect2(x, maxf(WORLD_TOP, draw_bounds.position.y), 4, minf(WORLD_BOTTOM, draw_bounds.end.y) - maxf(WORLD_TOP, draw_bounds.position.y)), Color("1d303d"))
	last_drawn_block_count = 0
	for rect in blocks:
		if rect.grow(40.0).intersects(draw_bounds):
			last_drawn_block_count += 1
			_draw_kinetic_block(rect, draw_bounds)
	last_drawn_spike_count = 0
	for rect in spike_rects:
		if not rect.grow(8.0).intersects(draw_bounds):
			continue
		last_drawn_spike_count += 1
		var visible_left := maxf(rect.position.x, draw_bounds.position.x - 8.0)
		var visible_right := minf(rect.end.x, draw_bounds.end.x + 8.0)
		var foundation_height := maxf(1.0, rect.size.y - 7.0)
		draw_rect(Rect2(visible_left, rect.position.y + 7.0, visible_right - visible_left, foundation_height), Color("3b3137"))
		draw_rect(Rect2(visible_left, rect.position.y + 7.0, visible_right - visible_left, 2.0), Color("bd6755"))
		if rect.size.y > 10.0:
			var brace_start := _aligned_range_start(visible_left, int(rect.position.x), 16)
			for brace_x in range(brace_start, int(ceil(visible_right)), 16):
				draw_line(Vector2(brace_x, rect.position.y + 11), Vector2(brace_x + 10, minf(rect.end.y - 2.0, rect.position.y + 23.0)), Color("6b4343"), 2.0)
		var spike_start := maxi(int(rect.position.x), _aligned_range_start(draw_bounds.position.x - 8.0, int(rect.position.x), 8))
		var spike_end := mini(int(rect.end.x), int(ceil(draw_bounds.end.x + 8.0)))
		for x in range(spike_start, spike_end, 8):
			var tooth_index := int((x - rect.position.x) / 8.0)
			var tooth_phase := visual_clock * 5.0 + float(tooth_index) * 0.85
			var lift := (sin(tooth_phase) + 1.0) * 0.7
			var tip := Vector2(x + 4, rect.position.y - lift)
			var points := PackedVector2Array([
				Vector2(x, rect.position.y + 8),
				tip,
				Vector2(x + 8, rect.position.y + 8),
			])
			var tooth_pulse := (sin(tooth_phase + 0.8) + 1.0) * 0.5
			var tooth_color := Color("db735b").lerp(Color("ffad6f"), tooth_pulse * 0.55)
			draw_colored_polygon(points, Color("321f29"))
			var inset_points := PackedVector2Array([
				Vector2(x + 1.2, rect.position.y + 6.8),
				tip + Vector2(0, 1.8),
				Vector2(x + 6.8, rect.position.y + 6.8),
			])
			draw_colored_polygon(inset_points, tooth_color)
			draw_line(Vector2(x + 1.2, rect.position.y + 6.8), tip + Vector2(0, 1.8), Color(1.0, 0.78, 0.48, 0.65), 1.0)
			if tooth_index % 2 == 0:
				draw_circle(Vector2(x + 4, rect.position.y + 9.5), 1.1, Color("f0bd68"))
	if Rect2(RAIL_LEFT - 40.0, 145.0, RAIL_RIGHT - RAIL_LEFT + 80.0, 40.0).intersects(draw_bounds):
		draw_line(Vector2(RAIL_LEFT - 32, 180), Vector2(RAIL_RIGHT + 32, 180), Color("657b83"), 2.0)
		draw_rect(Rect2(RAIL_LEFT - 36, 154, 4, 28), Color("e5b873"))
		draw_rect(Rect2(RAIL_RIGHT + 32, 154, 4, 28), Color("e5b873"))
	_draw_test_portal(draw_bounds)
	_draw_world_label(draw_bounds, Vector2(42, 62), "I  LAUNCH + CATCH", 8, Color("9ac6c7"))
	_draw_world_label(draw_bounds, Vector2(526, 62), "II  OPPOSING RAM", 8, Color("9ac6c7"))
	_draw_world_label(draw_bounds, Vector2(976, 62), "III  USE THE RETURN", 8, Color("9ac6c7"))
	_draw_world_label(draw_bounds, Vector2(1450, 62), "IV  DASH RELAY", 8, Color("a9f4dd"))
	_draw_world_label(draw_bounds, Vector2(1432, 78), "SHIELDS BREAK ONLY ON A DASH", 8, Color("6ba5a6"))
	_draw_world_label(draw_bounds, Vector2(1985, 84), "V  VERTICAL WORKS", 8, Color("a9f4dd"))
	_draw_world_label(draw_bounds, Vector2(2190, 84), "DASH OR POGO DRONES", 8, Color("f0bd68"))
	_draw_world_label(draw_bounds, Vector2(2740, -328), "SUMMIT TRANSFER", 8, Color("f5dfa8"))
	_draw_world_label(draw_bounds, Vector2(2940, -365), "VI  PRECISION FOUNDRY", 8, Color("f0bd68"))
	_draw_world_label(draw_bounds, Vector2(3690, -430), "VII  CANNON GALLERY", 8, Color("ff9b75"))
	_draw_world_label(draw_bounds, Vector2(3690, -414), "ATTACK BULLETS TO REFLECT", 8, Color("a9f4dd"))
	_draw_world_label(draw_bounds, Vector2(4540, -470), "VIII  CROWN ASCENT", 8, Color("f0bd68"))
	_draw_world_label(draw_bounds, Vector2(5300, -705), "IX  DESCENT FOUNDRY", 8, Color("ff9b75"))
	_draw_world_label(draw_bounds, Vector2(5310, -688), "CHARGERS BELOW", 7, Color("f0bd68"))
	_draw_world_label(draw_bounds, Vector2(6120, 82), "X  RAZOR TRANSIT", 8, Color("ff9b75"))
	_draw_world_label(draw_bounds, Vector2(7430, 82), "XI  AERIAL CORE", 8, Color("d7a9ff"))
	_draw_world_label(draw_bounds, Vector2(8620, -390), "XII  TITAN REGULATOR", 8, Color("ff8a66"))
	_draw_world_label(draw_bounds, Vector2(8620, -374), "15 HITS  WATCH THE HAMMER + BOMBS", 7, Color("f5dfa8"))
	_draw_world_label(draw_bounds, Vector2(9730, -390), "XIII  SUMMIT ASCENT", 8, Color("f0bd68"))
	for checkpoint_data in [
		{"order": 1, "position": Vector2(2845, -279)},
		{"order": 2, "position": Vector2(3590, -349)},
		{"order": 3, "position": Vector2(4450, -389)},
		{"order": 4, "position": Vector2(5320, -650)},
		{"order": 5, "position": Vector2(6135, 145)},
		{"order": 6, "position": Vector2(7485, 110)},
		{"order": 7, "position": Vector2(8625, -330)},
		{"order": 8, "position": Vector2(9750, -330)},
		{"order": 9, "position": Vector2(9890, -680)},
		{"order": 10, "position": Vector2(10140, -1040)},
		{"order": 11, "position": Vector2(10620, -1310)},
		{"order": 12, "position": Vector2(10985, -1490)},
	]:
		var checkpoint_order: int = checkpoint_data["order"]
		var checkpoint_position: Vector2 = checkpoint_data["position"]
		if not draw_bounds.grow(30.0).has_point(checkpoint_position):
			continue
		var checkpoint_color := Color("f0bd68") if late_checkpoint_order >= checkpoint_order else Color("596873")
		draw_rect(Rect2(checkpoint_position + Vector2(-2, -25), Vector2(4, 25)), checkpoint_color)
		draw_rect(Rect2(checkpoint_position + Vector2(-8, -25), Vector2(16, 3)), checkpoint_color)
	if draw_bounds.has_point(Vector2(1960, 120)):
		draw_rect(Rect2(1958, 105, 4, 31), Color("587f78" if tower_checkpoint_reached else "52616a"))
		draw_rect(Rect2(1951, 105, 18, 4), Color("a9f4dd" if tower_checkpoint_reached else "657b83"))
	if draw_bounds.grow(20.0).has_point(DASH_PICKUP_POSITION):
		draw_rect(Rect2(DASH_PICKUP_POSITION.x - 12, 101, 24, 4), Color("dba866"))
		draw_rect(Rect2(DASH_PICKUP_POSITION.x - 5, 96, 10, 5), Color("526b72"))
	if not dash_pickup_collected and draw_bounds.grow(32.0).has_point(DASH_PICKUP_POSITION):
		var dash_core_points := PackedVector2Array([
			DASH_PICKUP_POSITION + Vector2(0, -9),
			DASH_PICKUP_POSITION + Vector2(8, 0),
			DASH_PICKUP_POSITION + Vector2(0, 9),
			DASH_PICKUP_POSITION + Vector2(-8, 0),
		])
		draw_colored_polygon(dash_core_points, Color("a9f4dd"))
		draw_circle(DASH_PICKUP_POSITION, 3.0, Color("fff1ac"))
		draw_string(ThemeDB.fallback_font, DASH_PICKUP_POSITION + Vector2(-22, -15), "DASH CORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("a9f4dd"))
	if not double_jump_collected and draw_bounds.grow(36.0).has_point(DOUBLE_JUMP_PICKUP_POSITION):
		var core_pulse := 1.0 + sin(visual_clock * 6.0) * 0.14
		var aerial_core_points := PackedVector2Array([
			DOUBLE_JUMP_PICKUP_POSITION + Vector2(0, -11) * core_pulse,
			DOUBLE_JUMP_PICKUP_POSITION + Vector2(10, 0) * core_pulse,
			DOUBLE_JUMP_PICKUP_POSITION + Vector2(0, 11) * core_pulse,
			DOUBLE_JUMP_PICKUP_POSITION + Vector2(-10, 0) * core_pulse,
		])
		draw_colored_polygon(aerial_core_points, Color("9f78d2"))
		draw_circle(DOUBLE_JUMP_PICKUP_POSITION, 4.0, Color("f2d8ff"))
		draw_line(DOUBLE_JUMP_PICKUP_POSITION + Vector2(-15, -3), DOUBLE_JUMP_PICKUP_POSITION + Vector2(-8, -8), Color("d7a9ff"), 3.0)
		draw_line(DOUBLE_JUMP_PICKUP_POSITION + Vector2(15, -3), DOUBLE_JUMP_PICKUP_POSITION + Vector2(8, -8), Color("d7a9ff"), 3.0)
		draw_string(ThemeDB.fallback_font, DOUBLE_JUMP_PICKUP_POSITION + Vector2(-30, -20), "AERIAL CORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d7a9ff"))
	if not arena_cleared and Rect2(9680, WORLD_TOP, 24, 1790).intersects(draw_bounds):
		var gate_start := maxi(int(WORLD_TOP), _aligned_range_start(draw_bounds.position.y - 18.0, int(WORLD_TOP), 18))
		var gate_end := mini(52, int(ceil(draw_bounds.end.y + 18.0)))
		for gate_y in range(gate_start, gate_end, 18):
			draw_rect(Rect2(9682, gate_y, 20, 10), Color("a95e55"))
			draw_circle(Vector2(9692, gate_y + 5), 2.0, Color("fff1ac"))
	if is_instance_valid(carriage) and absf(carriage.velocity_x) > 1.0 and draw_bounds.grow(40.0).has_point(carriage.global_position):
		draw_line(carriage.position, carriage.position + Vector2(clampf(carriage.velocity_x * 0.22, -34.0, 34.0), 0), Color("a9f4dd"), 2.0)
	_draw_clockwork_core(draw_bounds)

func _draw_world_label(draw_bounds: Rect2, at: Vector2, label_text: String, font_size: int, color: Color) -> void:
	if draw_bounds.grow(120.0).has_point(at):
		draw_string(ThemeDB.fallback_font, at, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_test_portal(draw_bounds: Rect2) -> void:
	if not draw_bounds.grow(40.0).has_point(TEST_PORTAL_POSITION):
		return
	var pulse := (sin(visual_clock * 4.5) + 1.0) * 0.5
	draw_circle(TEST_PORTAL_POSITION, 15.0 + pulse * 2.0, Color(0.28, 0.12, 0.4, 0.42))
	for arc_index in 3:
		var arc_start := visual_clock * (1.4 + arc_index * 0.25) + arc_index * TAU / 3.0
		draw_arc(TEST_PORTAL_POSITION, 11.0 + arc_index * 2.5 + pulse, arc_start, arc_start + 1.55, 12, Color("d7a9ff"), 2.0)
	draw_circle(TEST_PORTAL_POSITION, 5.0 + pulse * 2.0, Color("a9f4dd"))
	draw_line(TEST_PORTAL_POSITION + Vector2(-13, 20), TEST_PORTAL_POSITION + Vector2(13, 20), Color("d4a65e"), 3.0)
	draw_string(ThemeDB.fallback_font, TEST_PORTAL_POSITION + Vector2(-17, -27), "TEST WARP", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d7a9ff"))

func _draw_clockwork_core(draw_bounds: Rect2) -> void:
	if clockwork_core_collected or not draw_bounds.grow(48.0).has_point(CLOCKWORK_CORE_POSITION):
		return
	var pulse := (sin(visual_clock * 5.0) + 1.0) * 0.5
	var rotation_phase := visual_clock * 1.8
	draw_circle(CLOCKWORK_CORE_POSITION, 18.0 + pulse * 3.0, Color(0.95, 0.68, 0.28, 0.12 + pulse * 0.08))
	for tooth_index in 10:
		var tooth_direction := Vector2.from_angle(rotation_phase + tooth_index * TAU / 10.0)
		draw_line(CLOCKWORK_CORE_POSITION + tooth_direction * 12.0, CLOCKWORK_CORE_POSITION + tooth_direction * 17.0, Color("d4a65e"), 3.0)
	draw_circle(CLOCKWORK_CORE_POSITION, 12.5, Color("203945"))
	draw_arc(CLOCKWORK_CORE_POSITION, 11.0, -rotation_phase, -rotation_phase + PI * 1.65, 20, Color("fff1ac"), 2.5)
	var core_points := PackedVector2Array([
		CLOCKWORK_CORE_POSITION + Vector2(0, -8.0 - pulse),
		CLOCKWORK_CORE_POSITION + Vector2(7.0 + pulse, 0),
		CLOCKWORK_CORE_POSITION + Vector2(0, 8.0 + pulse),
		CLOCKWORK_CORE_POSITION + Vector2(-7.0 - pulse, 0),
	])
	draw_colored_polygon(core_points, Color("a9f4dd"))
	draw_circle(CLOCKWORK_CORE_POSITION, 3.0 + pulse, Color("fff1ac"))
	draw_line(CLOCKWORK_CORE_POSITION + Vector2(-14, 21), CLOCKWORK_CORE_POSITION + Vector2(14, 21), Color("d4a65e"), 3.0)
	draw_string(ThemeDB.fallback_font, CLOCKWORK_CORE_POSITION + Vector2(-34, -27), "CLOCKWORK CORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("fff1ac"))

func _aligned_range_start(value: float, origin: int, step: int) -> int:
	return origin + int(floor((value - float(origin)) / float(step))) * step

func _draw_clockwork_background(draw_bounds: Rect2) -> void:
	var first_gear_x := maxi(120, _aligned_range_start(draw_bounds.position.x - 180.0, 120, 310))
	var last_gear_x := mini(int(WORLD_WIDTH), int(ceil(draw_bounds.end.x + 180.0)))
	for x in range(first_gear_x, last_gear_x, 310):
		var gear_index := int((x - 120) / 310.0)
		var y := -625.0 + float(gear_index % 5) * 175.0
		if y < draw_bounds.position.y - 100.0 or y > draw_bounds.end.y + 100.0:
			continue
		var large_radius := 38 if gear_index % 2 == 0 else 30
		var small_center := Vector2(x + 58, y + 48)
		var large_center := Vector2(x, y)
		_draw_kinetic_gear(large_center, large_radius, visual_clock * (0.28 if gear_index % 2 == 0 else -0.32), Color("29424d"))
		_draw_kinetic_gear(small_center, 19, visual_clock * (-0.56 if gear_index % 2 == 0 else 0.6), Color("243b47"))
		draw_line(large_center, small_center, Color("3a535b"), 4.0)
		var piston_phase := sin(visual_clock * 1.8 + gear_index * 0.75)
		var piston_x := x + 112.0
		draw_rect(Rect2(piston_x, y - 40, 15, 92), Color("1c303c"))
		draw_rect(Rect2(piston_x + 3, y - 5 + piston_phase * 24.0, 9, 30), Color("526a70"))
		draw_rect(Rect2(piston_x - 2, y + 20 + piston_phase * 24.0, 19, 5), Color("9d7450"))
	var chain_y_origin := int(WORLD_TOP) + 38
	var chain_y_start := maxi(chain_y_origin, _aligned_range_start(draw_bounds.position.y, chain_y_origin, 128))
	var chain_y_end := mini(int(WORLD_BOTTOM), int(ceil(draw_bounds.end.y)))
	for y in range(chain_y_start, chain_y_end, 128):
		var chain_shift := fmod(visual_clock * 16.0 + y, 24.0)
		var chain_x_origin := int(WORLD_LEFT) - 24
		var chain_x_start := maxi(chain_x_origin, _aligned_range_start(draw_bounds.position.x - chain_shift - 24.0, chain_x_origin, 24))
		var chain_x_end := mini(int(WORLD_WIDTH), int(ceil(draw_bounds.end.x - chain_shift + 24.0)))
		for x in range(chain_x_start, chain_x_end, 24):
			draw_circle(Vector2(x + chain_shift, y), 2.0, Color(0.31, 0.42, 0.45, 0.48))
	var deep_gear_x_origin := int(DESCENT_SECTION_LEFT) + 120
	var deep_gear_x_start := maxi(deep_gear_x_origin, _aligned_range_start(draw_bounds.position.x - 160.0, deep_gear_x_origin, 430))
	var deep_gear_x_end := mini(int(WORLD_WIDTH), int(ceil(draw_bounds.end.x + 160.0)))
	var deep_gear_y_origin := int(WORLD_TOP) + 135
	var deep_gear_y_start := maxi(deep_gear_y_origin, _aligned_range_start(draw_bounds.position.y - 170.0, deep_gear_y_origin, 340))
	var deep_gear_y_end := mini(int(WORLD_BOTTOM), int(ceil(draw_bounds.end.y + 170.0)))
	for x in range(deep_gear_x_start, deep_gear_x_end, 430):
		for y in range(deep_gear_y_start, deep_gear_y_end, 340):
			var phase := visual_clock * (0.22 if (x + y) % 2 == 0 else -0.27)
			_draw_kinetic_gear(Vector2(x, y), 26, phase, Color(0.16, 0.25, 0.3, 0.6))
			draw_line(Vector2(x, y + 29), Vector2(x, y + 132), Color(0.19, 0.3, 0.34, 0.55), 5.0)

func _draw_kinetic_gear(center: Vector2, radius: int, rotation: float, color: Color) -> void:
	draw_circle(center, float(radius) + 3.0, Color(0.04, 0.09, 0.12, 0.55))
	draw_arc(center, radius, 0.0, TAU, 32, color, 5.0)
	draw_circle(center, radius * 0.42, Color("162936"))
	draw_circle(center, radius * 0.13, Color("9a704e"))
	for spoke_index in 6:
		var angle := rotation + spoke_index * TAU / 6.0
		var direction := Vector2.from_angle(angle)
		draw_line(center + direction * radius * 0.18, center + direction * radius * 0.78, color, 3.0)
	for tooth_index in 12:
		var angle := rotation + tooth_index * TAU / 12.0
		var tooth_center := center + Vector2.from_angle(angle) * float(radius)
		draw_rect(Rect2(tooth_center - Vector2(3, 3), Vector2(6, 6)), color)

func _draw_kinetic_block(rect: Rect2, draw_bounds: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(3, 4), rect.size), Color(0.03, 0.07, 0.1, 0.72))
	draw_rect(rect, Color("283b47"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 4)), Color("c99a5d"))
	draw_rect(Rect2(rect.position + Vector2(2, 5), Vector2(maxf(0.0, rect.size.x - 4), minf(4.0, rect.size.y - 5))), Color("6a716b"))
	var belt_offset := int(fmod(visual_clock * 13.0, 16.0))
	var detail_left := maxf(rect.position.x, draw_bounds.position.x - 24.0)
	var detail_right := minf(rect.end.x, draw_bounds.end.x + 24.0)
	var belt_start := _aligned_range_start(detail_left - belt_offset, int(rect.position.x) - 16, 16) + belt_offset
	for x in range(belt_start, int(ceil(detail_right)), 16):
		draw_line(Vector2(x, rect.position.y + 1), Vector2(x + 5, rect.position.y + 3), Color("f0bd68"), 1.0)
	var rivet_start := maxi(int(rect.position.x) + 8, _aligned_range_start(detail_left, int(rect.position.x) + 8, 18))
	for x in range(rivet_start, int(ceil(detail_right - 3.0)), 18):
		draw_circle(Vector2(x, rect.position.y + 7), 1.4, Color("dfb875"))
	if rect.size.y >= 20.0:
		draw_rect(Rect2(rect.position + Vector2(4, 11), Vector2(maxf(0.0, rect.size.x - 8), maxf(0.0, rect.size.y - 15))), Color("213540"))
		var brace_start := maxi(int(rect.position.x) + 10, _aligned_range_start(detail_left, int(rect.position.x) + 10, 32))
		for x in range(brace_start, int(ceil(detail_right - 18.0)), 32):
			var brace_bottom := minf(rect.end.y - 4, rect.position.y + 35)
			draw_line(Vector2(x, rect.position.y + 13), Vector2(x + 22, brace_bottom), Color("3f5960"), 2.0)
			draw_line(Vector2(x + 22, rect.position.y + 13), Vector2(x, brace_bottom), Color("314b55"), 2.0)

func _setup_inputs() -> void:
	_add_action("move_left", 0.2)
	_add_action("move_right", 0.2)
	_add_action("aim_up", 0.2)
	_add_action("aim_down", 0.2)
	_add_action("jump")
	_add_action("attack")
	_add_action("dash")
	_add_action("slow_motion")
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
