class_name WarriorExecutionCinematic
extends Control

const BUILD_DURATION := 2.5
const FLASH_DURATION := 1.5
const ACTION_DURATION := 3.0
const IMPACT_DURATION := 0.5
const DISSOLVE_DURATION := 2.0
const BAR_HEIGHT := 94.0

var target_card_name: String = ""
var bars_height: float = 0.0
var sunset_alpha: float = 0.0
var flash_alpha: float = 0.0
var silhouette_alpha: float = 0.0
var sigil_alpha: float = 0.0
var slash_progress: float = 0.0
var slash_alpha: float = 1.0
var impact_progress: float = 0.0
var shatter_progress: float = 0.0
var embers_alpha: float = 0.0
var shake_strength: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO
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
	var original_position := zoom_target.position
	var center := size * 0.5
	_shake_target = zoom_target
	_shake_origin = original_position

	var bars_tween := create_tween()
	bars_tween.tween_property(self, "bars_height", BAR_HEIGHT, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await bars_tween.finished

	zoom_target.pivot_offset = center
	var zoom_tween := create_tween()
	zoom_tween.tween_property(zoom_target, "scale", original_scale * 1.08, BUILD_DURATION - 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await zoom_tween.finished

	flash_alpha = 1.0
	_play_stinger()
	await get_tree().create_timer(0.2).timeout
	sunset_alpha = 1.0
	var flash_tween := create_tween()
	flash_tween.tween_property(self, "flash_alpha", 0.0, FLASH_DURATION - 0.2)
	await flash_tween.finished

	silhouette_alpha = 1.0
	var sigil_tween := create_tween()
	sigil_tween.tween_property(self, "sigil_alpha", 1.0, ACTION_DURATION * 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(ACTION_DURATION * 0.5).timeout
	var slash_tween := create_tween()
	slash_tween.tween_property(self, "slash_progress", 1.0, ACTION_DURATION * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await slash_tween.finished

	bars_height = 0.0
	shake_strength = 30.0
	impact_progress = 0.0
	var impact_tween := create_tween()
	impact_tween.set_parallel(true)
	impact_tween.tween_property(self, "shake_strength", 0.0, IMPACT_DURATION).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(self, "impact_progress", 1.0, IMPACT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	impact_tween.tween_property(self, "sigil_alpha", 0.0, IMPACT_DURATION).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	flash_alpha = 0.65
	impact_tween.tween_property(self, "flash_alpha", 0.0, IMPACT_DURATION).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await impact_tween.finished

	shatter_progress = 0.12
	embers_alpha = 1.0
	var dissolve_tween := create_tween()
	dissolve_tween.set_parallel(true)
	dissolve_tween.tween_property(self, "shatter_progress", 1.0, DISSOLVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dissolve_tween.tween_property(self, "embers_alpha", 0.0, DISSOLVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dissolve_tween.tween_property(self, "sunset_alpha", 0.0, DISSOLVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	dissolve_tween.tween_property(self, "silhouette_alpha", 0.0, DISSOLVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	dissolve_tween.tween_property(self, "slash_alpha", 0.0, DISSOLVE_DURATION * 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	dissolve_tween.tween_property(zoom_target, "scale", original_scale, DISSOLVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await dissolve_tween.finished

	zoom_target.position = original_position
	zoom_target.pivot_offset = original_pivot
	_shake_target = null


func _play_stinger() -> void:
	const SAMPLE_RATE := 22050
	const DURATION := 1.2
	var sample_count := int(SAMPLE_RATE * DURATION)
	var pcm := PackedByteArray()
	pcm.resize(sample_count * 2)
	for index in sample_count:
		var time := float(index) / float(SAMPLE_RATE)
		var envelope := minf(time * 40.0, 1.0) * exp(-time * 2.6)
		var chord := (
			sin(TAU * 55.0 * time)
			+ sin(TAU * 82.4 * time) * 0.72
			+ sin(TAU * 110.0 * time) * 0.45
			+ sin(TAU * 164.8 * time) * 0.2
		) * envelope * 0.32
		var impact := sin(TAU * (72.0 - 20.0 * time) * time) * exp(-time * 8.0) * 0.45
		var sample := clampf(chord + impact, -1.0, 1.0)
		pcm.encode_s16(index * 2, int(sample * 32767.0))

	var stinger := AudioStreamWAV.new()
	stinger.format = AudioStreamWAV.FORMAT_16_BITS
	stinger.mix_rate = SAMPLE_RATE
	stinger.data = pcm
	var player := AudioStreamPlayer.new()
	player.stream = stinger
	player.volume_db = -3.0
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func _process(delta: float) -> void:
	_elapsed += delta
	if _shake_target != null and is_instance_valid(_shake_target):
		var board_shake := Vector2(
			sin(_elapsed * 151.0) * shake_strength,
			cos(_elapsed * 127.0) * shake_strength * 0.72
		)
		_shake_target.position = _shake_origin + board_shake
	if shake_strength > 0.0:
		shake_offset = Vector2(
			sin(_elapsed * 137.0) * shake_strength,
			cos(_elapsed * 113.0) * shake_strength * 0.7
		)
	else:
		shake_offset = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	if sunset_alpha > 0.0:
		_draw_sunset(sunset_alpha)
	if flash_alpha > 0.0:
		_draw_flash(flash_alpha)

	if silhouette_alpha > 0.0:
		draw_set_transform(shake_offset, 0.0, Vector2.ONE)
		_draw_target()
		if sigil_alpha > 0.0:
			_draw_target_sigil()
		_draw_warrior_silhouette()
		if slash_progress > 0.0:
			_draw_sword_slash()
		if impact_progress > 0.0:
			_draw_impact_wave()
		if shatter_progress > 0.0:
			_draw_shards()
		if silhouette_alpha > 0.0:
			_draw_rising_embers()
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	_draw_letterbox()


func _draw_sunset(alpha: float) -> void:
	var screen := Rect2(Vector2.ZERO, size)
	draw_rect(screen, Color("7c321c", alpha))
	draw_rect(Rect2(Vector2(0, 0), Vector2(size.x, size.y * 0.38)), Color("b74a20", alpha))
	draw_rect(Rect2(Vector2(0, size.y * 0.38), Vector2(size.x, size.y * 0.26)), Color("ed7a2d", alpha))
	draw_rect(Rect2(Vector2(0, size.y * 0.64), Vector2(size.x, size.y * 0.36)), Color("57301f", alpha))
	var sun_center := Vector2(size.x * 0.68, size.y * 0.42)
	draw_circle(sun_center, size.y * 0.2, Color("ed8c39", alpha * 0.45))
	draw_circle(sun_center, size.y * 0.14, Color("ffcb63", alpha * 0.75))
	draw_circle(sun_center, size.y * 0.09, Color("ffe6a0", alpha))
	for ray_index in 12:
		var angle := TAU * float(ray_index) / 12.0 + _elapsed * 0.035
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(
			sun_center + direction * size.y * 0.17,
			sun_center + direction * size.y * (0.25 + 0.025 * sin(_elapsed + float(ray_index))),
			Color(1.0, 0.72, 0.34, alpha * 0.22),
			3.0,
			true
		)
	for line_index in 5:
		var line_y := sun_center.y + float(line_index + 1) * 18.0
		draw_rect(
			Rect2(sun_center.x - size.y * 0.12, line_y, size.y * 0.24, 4.0),
			Color("b95627", alpha * 0.6)
		)


func _draw_flash(alpha: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("ffcf62", alpha))
	draw_circle(size * Vector2(0.68, 0.42), size.y * 0.52, Color("ff842e", alpha * 0.88))
	draw_circle(size * Vector2(0.68, 0.42), size.y * 0.3, Color("fff0a0", alpha * 0.8))


func _draw_letterbox() -> void:
	if bars_height <= 0.0:
		return
	draw_rect(Rect2(0.0, 0.0, size.x, bars_height), Color.BLACK)
	draw_rect(
		Rect2(0.0, size.y - bars_height, size.x, bars_height),
		Color.BLACK
	)


func _draw_target() -> void:
	if shatter_progress >= 0.12:
		return
	var target_rect := _target_rect()
	var frame := PackedVector2Array([
		target_rect.position + Vector2(0, 8),
		target_rect.position + Vector2(8, 0),
		target_rect.position + Vector2(target_rect.size.x - 8, 0),
		target_rect.position + Vector2(target_rect.size.x, 8),
		target_rect.position + Vector2(target_rect.size.x, target_rect.size.y - 8),
		target_rect.position + Vector2(target_rect.size.x - 8, target_rect.size.y),
		target_rect.position + Vector2(8, target_rect.size.y),
		target_rect.position + Vector2(0, target_rect.size.y - 8),
	])
	draw_colored_polygon(frame, Color("24252b"))
	draw_polyline(frame, Color("ffd16f"), 3.0, true)
	draw_rect(target_rect.grow(-14.0), Color("85452b"))
	draw_rect(
		Rect2(target_rect.position + Vector2(15, 15), Vector2(target_rect.size.x - 30, 8)),
		Color("f2a04b")
	)
	draw_circle(target_rect.get_center() + Vector2(0, -12), 22.0, Color("f5a647", 0.65))
	draw_circle(target_rect.get_center() + Vector2(0, -12), 13.0, Color("302a28"))
	var font := ThemeDB.fallback_font
	var title := target_card_name.to_upper()
	draw_string(
		font,
		Vector2(target_rect.position.x + 14, target_rect.end.y - 22),
		title,
		HORIZONTAL_ALIGNMENT_LEFT,
		target_rect.size.x - 28,
		15,
		Color("fff0cf")
	)


func _draw_warrior_silhouette() -> void:
	var base := Vector2(size.x * 0.31, size.y * 0.72)
	var unit := size.y / 360.0
	var black := Color(0.055, 0.035, 0.04, silhouette_alpha)
	var shadow := Color(0.11, 0.045, 0.035, silhouette_alpha)
	var anticipation := 1.0 - clampf(slash_progress * 3.0, 0.0, 1.0)
	var sword_lift := anticipation * 13.0 * sin(_elapsed * 2.2)
	draw_circle(base + Vector2(4, -4) * unit, 68.0 * unit, Color(0.12, 0.055, 0.035, silhouette_alpha * 0.6))
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-24, -182) * unit,
		base + Vector2(22, -184) * unit,
		base + Vector2(38, -118) * unit,
		base + Vector2(56, -42) * unit,
		base + Vector2(-54, -42) * unit,
		base + Vector2(-40, -118) * unit,
	]), black)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-21, -48) * unit,
		base + Vector2(1, -48) * unit,
		base + Vector2(-5, -4) * unit,
		base + Vector2(-33, -4) * unit,
	]), black)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(14, -48) * unit,
		base + Vector2(36, -48) * unit,
		base + Vector2(53, -4) * unit,
		base + Vector2(25, -4) * unit,
	]), black)
	draw_circle(base + Vector2(0, -210) * unit, 25.0 * unit, black)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-27, -220) * unit,
		base + Vector2(-5, -243) * unit,
		base + Vector2(23, -231) * unit,
		base + Vector2(32, -219) * unit,
	]), shadow)
	draw_rect(Rect2(base + Vector2(-27, -217) * unit, Vector2(58, 8) * unit), black)
	draw_line(
		base + Vector2(18, -167) * unit,
		base + Vector2(58, -233 - sword_lift) * unit,
		black,
		14.0 * unit,
		true
	)
	var sword_start := base + Vector2(62, -230 - sword_lift) * unit
	var sword_end := sword_start + Vector2(38, -94) * unit
	draw_line(sword_start, sword_end, Color(0.95, 0.49, 0.17, silhouette_alpha), 11.0 * unit, true)
	draw_line(sword_start, sword_end, Color(1.0, 0.86, 0.49, silhouette_alpha), 4.0 * unit, true)
	draw_line(sword_start + Vector2(-12, 12) * unit, sword_start + Vector2(13, -3) * unit, black, 8.0 * unit, true)


func _draw_target_sigil() -> void:
	var center := _target_rect().get_center()
	var radius := 104.0 + 8.0 * sin(_elapsed * 2.8)
	var pulse := 0.72 + 0.28 * sin(_elapsed * 4.0)
	var gold := Color(1.0, 0.69, 0.22, sigil_alpha * pulse)
	var pale_gold := Color(1.0, 0.9, 0.57, sigil_alpha * pulse * 0.86)
	draw_arc(center, radius, 0.0, TAU, 72, gold, 3.0, true)
	draw_arc(center, radius * 0.82, 0.0, TAU, 64, pale_gold, 1.5, true)
	for mark_index in 8:
		var angle := TAU * float(mark_index) / 8.0 + _elapsed * 0.18
		var direction := Vector2(cos(angle), sin(angle))
		var side := direction.rotated(PI * 0.5)
		var outer := center + direction * radius
		var inner := center + direction * (radius * 0.73)
		draw_line(inner - side * 8.0, outer, gold, 2.0, true)
		draw_line(outer, inner + side * 8.0, gold, 2.0, true)
	draw_line(
		center + Vector2(0, -radius * 0.64),
		center + Vector2(0, radius * 0.64),
		pale_gold,
		1.5,
		true
	)
	draw_line(
		center + Vector2(-radius * 0.64, 0),
		center + Vector2(radius * 0.64, 0),
		pale_gold,
		1.5,
		true
	)
	draw_circle(center, 8.0 + pulse * 5.0, Color(1.0, 0.83, 0.39, sigil_alpha * 0.72))


func _draw_sword_slash() -> void:
	var target := _target_rect()
	var center_x := target.get_center().x
	var start := Vector2(center_x, -size.y * 0.16)
	var finish := Vector2(center_x, target.position.y + target.size.y * 0.43)
	var eased_progress := 1.0 - pow(1.0 - slash_progress, 2.2)
	var tip := start.lerp(finish, eased_progress)
	var blade_alpha := slash_alpha * (0.82 + 0.18 * sin(_elapsed * 24.0))
	var blade_length := size.y * 0.62
	var blade_width := size.y * 0.13
	var shoulder := tip - Vector2(0, blade_length * 0.67)
	var hilt := tip - Vector2(0, blade_length)
	var blade := PackedVector2Array([
		tip,
		shoulder + Vector2(-blade_width * 0.5, 0),
		hilt + Vector2(-blade_width * 0.31, 0),
		hilt + Vector2(-blade_width * 0.17, -blade_width * 0.14),
		hilt + Vector2(blade_width * 0.17, -blade_width * 0.14),
		hilt + Vector2(blade_width * 0.31, 0),
		shoulder + Vector2(blade_width * 0.5, 0),
	])
	draw_colored_polygon(blade, Color(1.0, 0.24, 0.035, blade_alpha * 0.28))
	var blade_core := PackedVector2Array([
		tip,
		shoulder + Vector2(-blade_width * 0.2, 0),
		hilt + Vector2(-blade_width * 0.12, -blade_width * 0.1),
		hilt + Vector2(blade_width * 0.12, -blade_width * 0.1),
		shoulder + Vector2(blade_width * 0.2, 0),
	])
	draw_colored_polygon(blade_core, Color(1.0, 0.73, 0.25, blade_alpha * 0.92))
	draw_line(hilt, tip, Color(1.0, 0.98, 0.8, blade_alpha), 5.0, true)
	draw_line(
		hilt + Vector2(-blade_width * 0.54, 0),
		hilt + Vector2(blade_width * 0.54, 0),
		Color(1.0, 0.83, 0.4, blade_alpha),
		10.0,
		true
	)
	draw_line(
		hilt + Vector2(0, -blade_width * 0.12),
		hilt + Vector2(0, blade_width * 0.18),
		Color(0.28, 0.1, 0.035, blade_alpha),
		7.0,
		true
	)
	draw_circle(tip, lerpf(10.0, 34.0, slash_progress), Color(1.0, 0.9, 0.55, 0.88 * blade_alpha))


func _draw_impact_wave() -> void:
	var center := _target_rect().get_center()
	var radius := size.y * lerpf(0.025, 0.34, impact_progress)
	var alpha := 1.0 - impact_progress
	draw_circle(center, radius * 0.22, Color(1.0, 0.86, 0.46, alpha * 0.58))
	draw_arc(center, radius, 0.0, TAU, 56, Color(1.0, 0.82, 0.35, alpha), 7.0, true)
	draw_arc(center, radius * 0.72, 0.0, TAU, 48, Color(1.0, 0.34, 0.08, alpha * 0.8), 3.0, true)
	for ray_index in 12:
		var angle := TAU * float(ray_index) / 12.0 + _elapsed * 0.9
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(
			center + direction * radius * 0.76,
			center + direction * radius * 1.22,
			Color(1.0, 0.7, 0.25, alpha * 0.86),
			3.0,
			true
		)


func _draw_shards() -> void:
	var target := _target_rect()
	var center := target.get_center()
	for index in 18:
		var direction := Vector2(
			sin(float(index) * 2.41),
			-cos(float(index) * 1.73)
		)
		var distance := 10.0 + shatter_progress * (105.0 + float(index % 5) * 22.0)
		var flutter := sin(_elapsed * (3.0 + float(index % 4)) + float(index) * 1.7)
		var shard_center := center + direction * distance + Vector2(flutter * 12.0, -shatter_progress * float(index % 4) * 10.0)
		var shard_size := 5.0 + float(index % 4) * 2.0
		var spin := shatter_progress * (float(index % 3) - 1.0) * 0.8
		var shard := PackedVector2Array([
			shard_center + Vector2(-shard_size, shard_size * 0.5).rotated(spin),
			shard_center + Vector2(shard_size * 0.8, -shard_size).rotated(spin),
			shard_center + Vector2(shard_size * 0.6, shard_size).rotated(spin),
		])
		var ember_color := Color("ffb342") if index % 2 == 0 else Color("f56a27")
		ember_color.a = embers_alpha
		draw_colored_polygon(shard, ember_color)
		if index % 3 == 0:
			draw_circle(shard_center + Vector2(3.0, -5.0), 3.0, Color(1.0, 0.78, 0.35, embers_alpha))


func _draw_rising_embers() -> void:
	var base := Vector2(size.x * 0.31, size.y * 0.72)
	for index in 20:
		var seed := float(index)
		var drift := fposmod(_elapsed * (18.0 + fmod(seed, 5.0)) + seed * 47.0, size.y * 0.72)
		var ember_position := base + Vector2(
			sin(_elapsed * 1.7 + seed * 2.3) * (18.0 + fmod(seed, 28.0)),
			-drift
		)
		var fade := silhouette_alpha * (1.0 - drift / (size.y * 0.72))
		var radius := 1.5 + fmod(seed, 3.0)
		var color := Color("ffb342") if index % 2 == 0 else Color("f56a27")
		color.a = fade * 0.75
		draw_circle(ember_position, radius, color)


func _target_rect() -> Rect2:
	var target_size := Vector2(168.0, 218.0)
	return Rect2(size * Vector2(0.68, 0.55) - target_size * 0.5, target_size)
