extends Node2D

var particles: Array[Dictionary] = []
var impacts: Array[Dictionary] = []

func burst(at: Vector2, color: Color, count: int = 8) -> void:
	for i in count:
		var angle := TAU * float(i) / float(count) + randf_range(-0.18, 0.18)
		var speed := randf_range(28.0, 75.0)
		particles.append({"position": at, "velocity": Vector2(cos(angle), sin(angle)) * speed, "life": 0.38, "color": color})
	queue_redraw()

func impact(at: Vector2, color: Color, direction: Vector2) -> void:
	var facing := direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	var side := Vector2(-facing.y, facing.x)
	for i in 10:
		var spread := randf_range(-0.85, 0.85)
		var particle_direction := (facing * randf_range(0.25, 1.0) + side * spread).normalized()
		particles.append({
			"position": at,
			"velocity": particle_direction * randf_range(45.0, 105.0),
			"life": randf_range(0.18, 0.34),
			"color": color,
		})
	impacts.append({"position": at, "direction": facing, "life": 0.14, "color": color})
	queue_redraw()

func _process(delta: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		var p := particles[i]
		p["life"] -= delta
		if p["life"] <= 0.0:
			particles.remove_at(i)
		else:
			p["position"] += p["velocity"] * delta
			p["velocity"].y += 120.0 * delta
			particles[i] = p
	for i in range(impacts.size() - 1, -1, -1):
		var hit := impacts[i]
		hit["life"] = float(hit["life"]) - delta
		if float(hit["life"]) <= 0.0:
			impacts.remove_at(i)
		else:
			impacts[i] = hit
	queue_redraw()

func _draw() -> void:
	for p in particles:
		var size := 2.0 if p["life"] > 0.18 else 1.0
		draw_rect(Rect2(p["position"] - Vector2.ONE * size * 0.5, Vector2.ONE * size), p["color"])
	for hit in impacts:
		var life_ratio := clampf(float(hit["life"]) / 0.14, 0.0, 1.0)
		var at: Vector2 = hit["position"]
		var direction: Vector2 = hit["direction"]
		var side := Vector2(-direction.y, direction.x)
		var color: Color = hit["color"]
		color.a = life_ratio
		var radius := lerpf(9.0, 18.0, 1.0 - life_ratio)
		draw_arc(at, radius, direction.angle() - 0.8, direction.angle() + 0.8, 10, color, 2.0)
		draw_line(at - side * radius * 0.65, at + side * radius * 0.65, color, 2.0)
		draw_circle(at, 3.0 + life_ratio * 3.0, Color(1.0, 0.98, 0.78, life_ratio * 0.8))
