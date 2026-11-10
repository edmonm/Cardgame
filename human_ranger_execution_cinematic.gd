class_name HumanRangerExecutionCinematic
extends Control

const BAR_HEIGHT := 94.0
const TARGET_SIZE := Vector2(168.0, 218.0)
const FLIGHT_START := Vector2(0.08, 0.29)
const TARGET_CENTER := Vector2(0.73, 0.53)

var target_card_name: String = ""
var bars_height: float = 0.0
var darkness_alpha: float = 0.0
var flash_alpha: float = 0.0
var charge_progress: float = 0.0
var wind_progress: float = 0.0
var arrow_progress: float = 0.0
var impact_progress: float = 0.0
var shatter_progress: float = 0.0
var shards_alpha: float = 0.0
var shake_strength: float = 0.0
var _elapsed: float = 0.0
var _shake_target: Control
var _shake_origin := Vector2.ZERO


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100


func _ready() -> void:
	set_process(true)


func configure(defeated_card_name: String) -> void:
	target_card_name = defeated_card_name


func play(zoom_target: Control) -> void:
	await get_tree().process_frame
	if size.is_zero_approx():
		size = get_viewport_rect().size

	var original_scale := zoom_target.scale
	var original_pivot := zoom_target.pivot_offset
	_shake_target = zoom_target
	_shake_origin = zoom_target.position

	var bars_tween := create_tween()
	bars_tween.tween_property(self, "bars_height", BAR_HEIGHT, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await bars_tween.finished

	zoom_target.pivot_offset = size * 0.5
	var zoom_tween := create_tween()
	zoom_tween.tween_property(zoom_target, "scale", original_scale * 1.1, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await zoom_tween.finished

	var dark_tween := create_tween()
	dark_tween.tween_property(self, "darkness_alpha", 0.92, 0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await dark_tween.finished

	var charge_tween := create_tween()
	charge_tween.tween_property(self, "charge_progress", 1.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await charge_tween.finished

	var flash_tween := create_tween()
	flash_tween.tween_property(self, "flash_alpha", 1.0, 0.08).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await flash_tween.finished
	await get_tree().create_timer(0.12).timeout
	var flash_fade := create_tween()
	flash_fade.tween_property(self, "flash_alpha", 0.0, 0.32).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	var release_tween := create_tween()
	release_tween.set_parallel(true)
	release_tween.tween_property(self, "wind_progress", 1.0, 1.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	release_tween.tween_property(self, "arrow_progress", 1.0, 1.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await release_tween.finished

	bars_height = 0.0
	shake_strength = 36.0
	flash_alpha = 0.88
	var impact_tween := create_tween()
	impact_tween.set_parallel(true)
	impact_tween.tween_property(self, "shake_strength", 0.0, 0.65).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(self, "flash_alpha", 0.0, 0.65).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(self, "impact_progress", 1.0, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(zoom_target, "scale", original_scale, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await impact_tween.finished

	shatter_progress = 0.08
	shards_alpha = 1.0
	var dissolve_tween := create_tween()
	dissolve_tween.set_parallel(true)
	dissolve_tween.tween_property(self, "shatter_progress", 1.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dissolve_tween.tween_property(self, "shards_alpha", 0.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dissolve_tween.tween_property(self, "darkness_alpha", 0.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	dissolve_tween.tween_property(self, "wind_progress", 0.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await dissolve_tween.finished

	zoom_target.position = _shake_origin
	zoom_target.pivot_offset = original_pivot
	_shake_target = null


func _process(delta: float) -> void:
	_elapsed += delta
	if _shake_target != null and is_instance_valid(_shake_target):
		var shake := Vector2(
			sin(_elapsed * 173.0) * shake_strength,
			cos(_elapsed * 139.0) * shake_strength * 0.78
		)
		_shake_target.position = _shake_origin + shake
	queue_redraw()


func _draw() -> void:
	if darkness_alpha > 0.0:
		_draw_darkness()

	if shatter_progress < 0.08:
		_draw_target()
	if impact_progress > 0.0:
		_draw_puncture()
	if darkness_alpha > 0.0 and charge_progress > 0.0:
		_draw_distant_charge()
	if wind_progress > 0.0:
		_draw_wind_burst()
	if arrow_progress > 0.0 and arrow_progress <= 1.0:
		_draw_arrow()
	if shards_alpha > 0.0:
		_draw_shards()
	if flash_alpha > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.96, 0.87, flash_alpha))
	_draw_letterbox()


func _draw_darkness() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.008, 0.012, 0.025, darkness_alpha))
	draw_rect(
		Rect2(Vector2(0.0, size.y * 0.58), Vector2(size.x, size.y * 0.42)),
		Color(0.025, 0.015, 0.055, darkness_alpha * 0.8)
	)
	draw_circle(size * Vector2(0.54, 0.28), size.y * 0.31, Color(0.025, 0.045, 0.11, darkness_alpha * 0.5))


func _draw_distant_charge() -> void:
	var origin := size * FLIGHT_START
	var intensity := charge_progress
	var pulse := 0.82 + 0.18 * sin(_elapsed * 13.0)
	var glow := size.y * lerpf(0.012, 0.075, intensity) * pulse
	var direction := (_target_rect().get_center() - origin).normalized()
	draw_circle(origin, glow * 2.2, Color(0.39, 0.05, 0.72, intensity * 0.22))
	draw_circle(origin, glow * 1.35, Color(0.0, 0.75, 1.0, intensity * 0.48))
	draw_circle(origin, glow * 0.55, Color(1.0, 0.23, 0.58, intensity * 0.85))
	draw_circle(origin, glow * 0.19, Color(1.0, 0.98, 0.78, intensity))
	draw_line(
		origin - direction * glow * 0.75,
		origin + direction * glow * 1.4,
		Color(0.0, 0.86, 1.0, intensity * 0.8),
		maxf(2.0, glow * 0.28),
		true
	)
	draw_colored_polygon(PackedVector2Array([
		origin + direction * glow * 1.75,
		origin + direction * glow * 0.8 + direction.rotated(PI * 0.5) * glow * 0.34,
		origin + direction * glow * 0.8 + direction.rotated(-PI * 0.5) * glow * 0.34,
	]), Color(1.0, 0.95, 0.72, intensity))
	for ray_index in 12:
		var angle := TAU * float(ray_index) / 12.0 + _elapsed * 2.1
		var ray_direction := Vector2(cos(angle), sin(angle))
		draw_line(
			origin + ray_direction * glow * 0.8,
			origin + ray_direction * glow * (1.3 + intensity * 0.8),
			Color(0.6, 0.88, 1.0, intensity * 0.75),
			maxf(1.0, size.y * 0.0025),
			true
		)


func _draw_puncture() -> void:
	var center := _target_rect().get_center()
	var radius := size.y * lerpf(0.012, 0.24, impact_progress)
	var alpha := 1.0 - impact_progress * 0.65
	draw_circle(center, radius, Color(0.1, 0.82, 1.0, alpha * 0.24))
	draw_arc(center, radius, 0.0, TAU, 56, Color(0.82, 0.96, 1.0, alpha), 7.0, true)
	draw_arc(center, radius * 0.72, 0.0, TAU, 48, Color(1.0, 0.22, 0.82, alpha * 0.9), 3.0, true)
	for crack_index in 8:
		var angle := TAU * float(crack_index) / 8.0 + 0.19
		var direction := Vector2(cos(angle), sin(angle))
		var elbow := center + direction * radius * 0.55
		var tip := center + direction * radius
		var kink := elbow + direction.rotated(0.55 if crack_index % 2 == 0 else -0.55) * radius * 0.17
		draw_line(center, kink, Color(0.75, 0.94, 1.0, alpha), 3.0, true)
		draw_line(kink, tip, Color(0.75, 0.94, 1.0, alpha), 2.0, true)


func _draw_target() -> void:
	var rect := _target_rect()
	var frame := PackedVector2Array([
		rect.position + Vector2(0, 8),
		rect.position + Vector2(8, 0),
		rect.position + Vector2(rect.size.x - 8, 0),
		rect.position + Vector2(rect.size.x, 8),
		rect.position + Vector2(rect.size.x, rect.size.y - 8),
		rect.position + Vector2(rect.size.x - 8, rect.size.y),
		rect.position + Vector2(8, rect.size.y),
		rect.position + Vector2(0, rect.size.y - 8),
	])
	draw_colored_polygon(frame, Color("242934"))
	draw_polyline(frame, Color("91c6db"), 3.0, true)
	draw_rect(rect.grow(-14.0), Color("354558"))
	draw_rect(Rect2(rect.position + Vector2(15, 15), Vector2(rect.size.x - 30, 8)), Color("b4d7df"))
	draw_circle(rect.get_center() + Vector2(0, -12), 22.0, Color("d7b78a", 0.75))
	draw_circle(rect.get_center() + Vector2(0, -12), 13.0, Color("242934"))
	draw_string(
		ThemeDB.fallback_font,
		Vector2(rect.position.x + 14, rect.end.y - 22),
		target_card_name.to_upper(),
		HORIZONTAL_ALIGNMENT_LEFT,
		rect.size.x - 28,
		15,
		Color("edf4e9")
	)


func _draw_wind_burst() -> void:
	var colors: Array[Color] = [
		Color("70e8ff"),
		Color("d484ff"),
		Color("ffe56b"),
		Color("ff6fae"),
		Color("8cff9c"),
		Color("ff965f"),
	]
	var start := size * FLIGHT_START
	var finish := _target_rect().get_center()
	var direction := (finish - start).normalized()
	var sideways := Vector2(-direction.y, direction.x)
	var intensity := clampf(wind_progress, 0.0, 1.0)

	for ribbon_index in 24:
		var points := PackedVector2Array()
		var ribbon := float(ribbon_index)
		var amplitude := size.y * (0.025 + fmod(ribbon * 0.013, 0.07)) * intensity
		var phase := _elapsed * (7.0 + fmod(ribbon, 5.0)) + ribbon * 1.91
		for point_index in 15:
			var along := float(point_index) / 14.0
			var envelope := sin(along * PI) * (0.35 + along * 0.65)
			var wave := sin(phase + along * (9.0 + fmod(ribbon, 7.0)))
			var position := start.lerp(finish, along)
			position += sideways * wave * amplitude * envelope
			position += direction * cos(phase * 0.7 + along * 12.0) * amplitude * 0.22 * envelope
			points.append(position)
		var color := colors[ribbon_index % colors.size()]
		color.a = intensity * (0.34 + 0.32 * absf(sin(phase)))
		var width := lerpf(1.5, 8.0, intensity) * (0.6 + fmod(ribbon, 4.0) * 0.2)
		draw_polyline(points, color, width, true)


func _draw_arrow() -> void:
	var start := size * FLIGHT_START
	var finish := _target_rect().get_center()
	var progress := clampf(arrow_progress, 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - progress, 2.4)
	var tip := start.lerp(finish, eased)
	var direction := (finish - start).normalized()
	var sideways := Vector2(-direction.y, direction.x)
	var scale := lerpf(0.3, 2.25, pow(progress, 1.5))
	var shaft_length := size.y * 0.2 * scale
	var shaft_width := maxf(2.0, size.y * 0.006 * scale)
	var tail := tip - direction * shaft_length
	draw_line(tail, tip, Color(0.84, 0.91, 0.87, 0.95), shaft_width, true)
	draw_line(tail, tip, Color(0.35, 0.83, 0.95, 0.78), shaft_width * 2.6, true)
	draw_colored_polygon(PackedVector2Array([
		tip,
		tip - direction * size.y * 0.075 * scale + sideways * size.y * 0.04 * scale,
		tip - direction * size.y * 0.075 * scale - sideways * size.y * 0.04 * scale,
	]), Color("e9fff0"))
	for feather_index in 3:
		var feather_start := tail + direction * shaft_length * float(feather_index) * 0.08
		draw_line(
			feather_start,
			feather_start - direction * size.y * 0.045 * scale + sideways * size.y * 0.022 * scale,
			Color("ff9f70", 0.9),
			maxf(1.0, shaft_width * 1.4),
			true
		)


func _draw_shards() -> void:
	var center := _target_rect().get_center()
	var colors: Array[Color] = [
		Color("70e8ff"),
		Color("d484ff"),
		Color("ffe56b"),
		Color("ff6fae"),
		Color("8cff9c"),
		Color("ff965f"),
	]
	for index in 26:
		var direction := Vector2(sin(float(index) * 2.41), -cos(float(index) * 1.73)).normalized()
		var distance := 16.0 + shatter_progress * (85.0 + float(index % 5) * 18.0)
		var shard_center := center + direction * distance
		var shard_size := 5.0 + float(index % 4) * 2.0
		var shard := PackedVector2Array([
			shard_center + Vector2(-shard_size, shard_size * 0.5),
			shard_center + Vector2(shard_size * 0.8, -shard_size),
			shard_center + Vector2(shard_size * 0.6, shard_size),
		])
		var color := colors[index % colors.size()]
		color.a = shards_alpha
		draw_colored_polygon(shard, color)


func _draw_letterbox() -> void:
	if bars_height <= 0.0:
		return
	draw_rect(Rect2(0.0, 0.0, size.x, bars_height), Color.BLACK)
	draw_rect(Rect2(0.0, size.y - bars_height, size.x, bars_height), Color.BLACK)


func _target_rect() -> Rect2:
	return Rect2(size * TARGET_CENTER - TARGET_SIZE * 0.5, TARGET_SIZE)
