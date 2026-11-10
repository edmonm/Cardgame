class_name BoardTable
extends Control

const CARD_SIZE := Vector2(168, 240)
const SIDE_MARGIN := 24.0
const ENEMY_ROW_Y := 92.0

var player_row_y: float = 0.0
var enemy_count: int = 0
var player_count: int = 0
var combat_mode: String = ""
var enemy_class_name: String = "Enemy"
var preview_text: String = ""


func configure(
	row_y: float,
	enemies: int,
	allies: int,
	active_combat_mode: String,
	enemy_name: String,
	combat_preview: String
) -> void:
	player_row_y = row_y
	enemy_count = enemies
	player_count = allies
	combat_mode = active_combat_mode
	enemy_class_name = enemy_name
	preview_text = combat_preview
	queue_redraw()


func combat_center_y() -> float:
	return (ENEMY_ROW_Y + CARD_SIZE.y + player_row_y) * 0.5


func is_combat_drop(global_position: Vector2) -> bool:
	var local_position := get_global_transform_with_canvas().affine_inverse() * global_position
	return absf(local_position.y - combat_center_y()) <= 72.0


func _draw() -> void:
	if size.x < 1.0 or size.y < 1.0:
		return

	var board_bottom := player_row_y + CARD_SIZE.y + 24.0
	var board_rect := Rect2(
		SIDE_MARGIN,
		66.0,
		size.x - SIDE_MARGIN * 2.0,
		board_bottom - 66.0
	)
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("101b20")
	frame.border_color = Color("a88b4e")
	frame.set_border_width_all(2)
	frame.set_corner_radius_all(18)
	draw_style_box(frame, board_rect)

	var turf := board_rect.grow(-8.0)
	draw_rect(turf, Color("243a32"))
	_draw_lane(turf, ENEMY_ROW_Y, Color("1a2e2c", 0.92))
	_draw_lane(turf, player_row_y, Color("304339", 0.92))
	_draw_combat_lane(turf)
	_draw_row_label(
		"%s BENCH" % enemy_class_name.to_upper(),
		enemy_count,
		ENEMY_ROW_Y - 23.0,
		Color("c0cabd")
	)
	_draw_row_label(
		"YOUR BENCH",
		player_count,
		player_row_y - 20.0,
		Color("e1d3ac")
	)
	_draw_hand_area()


func _draw_lane(turf: Rect2, row_y: float, color: Color) -> void:
	var lane_rect := Rect2(
		Vector2(turf.position.x + 8.0, row_y - 18.0),
		Vector2(turf.size.x - 16.0, CARD_SIZE.y + 36.0)
	)
	var lane_style := StyleBoxFlat.new()
	lane_style.bg_color = color
	lane_style.border_color = Color("b5a06d", 0.32)
	lane_style.set_border_width_all(1)
	lane_style.set_corner_radius_all(12)
	draw_style_box(lane_style, lane_rect)
	_draw_card_pedestals(lane_rect, row_y, enemy_count if row_y == ENEMY_ROW_Y else player_count)


func _draw_card_pedestals(lane_rect: Rect2, row_y: float, count: int) -> void:
	var visible_count: int = maxi(count, 5)
	var card_gap := 14.0
	var step := CARD_SIZE.x + card_gap
	var total := CARD_SIZE.x + step * float(visible_count - 1)
	if total > lane_rect.size.x - 28.0:
		step = (lane_rect.size.x - 28.0 - CARD_SIZE.x) / float(visible_count - 1)
		total = CARD_SIZE.x + step * float(visible_count - 1)
	var start_x := (size.x - total) * 0.5
	for index in visible_count:
		var pedestal := Rect2(
			Vector2(start_x + step * float(index) - 5.0, row_y - 5.0),
			Vector2(CARD_SIZE.x + 10.0, CARD_SIZE.y + 10.0)
		)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("111d1d", 0.36)
		style.border_color = Color("c2a969", 0.22)
		style.set_border_width_all(1)
		style.set_corner_radius_all(9)
		draw_style_box(style, pedestal)


func _draw_combat_lane(turf: Rect2) -> void:
	var combat_y := combat_center_y()
	var combat_color := Color("f0cf79") if not combat_mode.is_empty() else Color("b5a276", 0.8)
	draw_rect(
		Rect2(Vector2(turf.position.x, combat_y - 22.0), Vector2(turf.size.x, 44.0)),
		Color("0e1719", 0.78)
	)
	draw_line(
		Vector2(turf.position.x, combat_y),
		Vector2(turf.end.x, combat_y),
		combat_color,
		2.0
	)
	for marker_x in [turf.position.x + 48.0, turf.end.x - 48.0]:
		draw_arc(Vector2(marker_x, combat_y), 13.0, 0.0, TAU, 48, combat_color, 2.0)

	var title := "COMBAT ZONE"
	match combat_mode:
		"declare_attack":
			title = "DECLARE ATTACKERS"
		"block":
			title = "ASSIGN BLOCKERS"
		"preview":
			title = "ORACLE'S EYE"
	var font := ThemeDB.fallback_font
	var title_width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	draw_string(
		font,
		Vector2(size.x * 0.5 - title_width * 0.5, combat_y + 5.0),
		title,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		combat_color
	)
	if not preview_text.is_empty():
		_draw_preview_panel(combat_y, font)


func _draw_preview_panel(combat_y: float, font: Font) -> void:
	var panel_size := Vector2(460.0, 60.0)
	var panel_rect := Rect2(
		Vector2((size.x - panel_size.x) * 0.5, combat_y + 28.0),
		panel_size
	)
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("10191f", 0.96)
	panel.border_color = Color("65b9c9")
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(8)
	draw_style_box(panel, panel_rect)
	draw_multiline_string(
		font,
		panel_rect.position + Vector2(12.0, 20.0),
		preview_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		panel_size.x - 24.0,
		13,
		2,
		Color("e4edf0")
	)


func _draw_row_label(label: String, count: int, y: float, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var text := "%s  |  %d" % [label, count]
	draw_string(font, Vector2(SIDE_MARGIN + 22.0, y + 12.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)


func _draw_hand_area() -> void:
	var hand_top := size.y - CARD_SIZE.y - 28.0
	if hand_top <= player_row_y + CARD_SIZE.y:
		return
	var hand_rect := Rect2(
		SIDE_MARGIN,
		hand_top,
		size.x - SIDE_MARGIN * 2.0,
		CARD_SIZE.y + 22.0
	)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0d171c", 0.78)
	style.border_color = Color("a88b4e", 0.82)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	draw_style_box(style, hand_rect)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(hand_rect.position.x + 18.0, hand_rect.position.y + 21.0),
		"HAND",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		13,
		Color("d6c89f", 0.82)
	)
