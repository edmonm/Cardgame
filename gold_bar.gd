class_name GoldBar
extends Control

var amount: int = 0
var capacity: int = 10


func configure(current_amount: int, max_amount: int) -> void:
	amount = clampi(current_amount, 0, max_amount)
	capacity = max_amount
	queue_redraw()


func _draw() -> void:
	if size.x < 1.0 or size.y < 1.0:
		return

	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("10191f", 0.94)
	panel.border_color = Color("a88b4e")
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(10)
	draw_style_box(panel, Rect2(Vector2.ZERO, size))

	var font := ThemeDB.fallback_font
	draw_string(
		font,
		Vector2(14.0, 24.0),
		"GOLD",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color("f0d48a")
	)
	draw_string(
		font,
		Vector2(size.x - 14.0, 25.0),
		"%d / %d" % [amount, capacity],
		HORIZONTAL_ALIGNMENT_RIGHT,
		-1,
		17,
		Color("f3efe4")
	)

	var gap := 5.0
	var segment_width := (size.x - 28.0 - gap * float(capacity - 1)) / float(capacity)
	for index in capacity:
		var rect := Rect2(
			Vector2(14.0 + float(index) * (segment_width + gap), 42.0),
			Vector2(segment_width, 22.0)
		)
		var segment := StyleBoxFlat.new()
		segment.bg_color = Color("d7a640") if index < amount else Color("27333a")
		segment.border_color = Color("ffe098", 0.7) if index < amount else Color("48545a")
		segment.set_border_width_all(1)
		segment.set_corner_radius_all(4)
		draw_style_box(segment, rect)
