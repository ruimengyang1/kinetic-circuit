extends Area2D

signal activated(source: String)
signal charge_changed(value: int)
signal impact_applied(force: int, source: String, value: int)

var required_charge := 1
var charge := 0
var socket_name := ""
var enabled := true
var _charging_contacts: Dictionary = {}
var _flash := 0.0

func configure(at: Vector2, threshold: int, label: String) -> void:
	position = at
	required_charge = maxi(1, threshold)
	socket_name = label

func _ready() -> void:
	collision_layer = 16
	collision_mask = 16
	monitoring = true
	monitorable = true
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(48, 38)
	collision.shape = shape
	add_child(collision)

func _physics_process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta)
	var touching: Dictionary = {}
	for area in get_overlapping_areas():
		if area.get("kind") not in ["tower_guard", "descent_guard", "boss_titan"]:
			continue
		if area.get("alive") != true or area.get("state") != "charge":
			continue
		var id := area.get_instance_id()
		touching[id] = true
		if not _charging_contacts.has(id):
			add_impact(3, "charge")
	_charging_contacts = touching
	queue_redraw()

func receive_directional_strike(_direction: Vector2) -> bool:
	if not enabled:
		return false
	add_impact(1, "player")
	return true

func receive_projectile_strike() -> bool:
	if not enabled:
		return false
	add_impact(2, "projectile")
	return true

func add_impact(force: int, source: String) -> void:
	if not enabled:
		return
	_flash = 0.22
	if charge >= required_charge:
		queue_redraw()
		return
	charge = mini(required_charge, charge + maxi(0, force))
	impact_applied.emit(force, source, charge)
	charge_changed.emit(charge)
	if charge >= required_charge:
		collision_layer = 0
		activated.emit(source)
	queue_redraw()

func reset_receiver(saved_charge: int = 0) -> void:
	charge = clampi(saved_charge, 0, required_charge)
	collision_layer = 0 if charge >= required_charge else 16
	_charging_contacts.clear()
	_flash = 0.0
	charge_changed.emit(charge)
	queue_redraw()

func _draw() -> void:
	var powered := charge >= required_charge
	var rim := Color("5df2d2") if powered else Color("d49b54")
	if _flash > 0.0:
		rim = Color("fff0aa")
	draw_circle(Vector2.ZERO, 24.0, Color("0b1c24"))
	draw_arc(Vector2.ZERO, 21.0, 0.0, TAU, 32, rim, 4.0)
	draw_circle(Vector2.ZERO, 9.0, rim if powered else Color("425864"))
	for index in required_charge:
		var angle := -PI * 0.72 + float(index) * PI * 1.44 / maxf(1.0, float(required_charge - 1))
		var point := Vector2.from_angle(angle) * 15.0
		draw_circle(point, 2.8, Color("5df2d2") if index < charge else Color("986c45"))
