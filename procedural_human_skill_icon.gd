extends Control

const GRID_SIZE := Vector2(12.0, 14.0)

var card_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	match card_id:
		"human_anti_mage":
			_draw_silence_rune()
		"human_healer":
			_draw_healing_cross()
		_:
			_draw_tough_shield()


func _draw_tough_shield() -> void:
	_pixel(2, 1, 8, 2, Color("493926"))
	_pixel(1, 2, 10, 6, Color("493926"))
	_pixel(2, 8, 8, 2, Color("493926"))
	_pixel(3, 10, 6, 1, Color("493926"))
	_pixel(4, 11, 4, 1, Color("493926"))
	_pixel(3, 3, 6, 2, Color("daa84f"))
	_pixel(2, 5, 8, 2, Color("c28a39"))
	_pixel(3, 7, 6, 2, Color("daa84f"))
	_pixel(4, 9, 4, 1, Color("c28a39"))
	_pixel(5, 3, 2, 6, Color("eef0d7"))
	_pixel(4, 5, 4, 2, Color("eef0d7"))
	_pixel(9, 3, 1, 2, Color("fff0ad"))


func _draw_silence_rune() -> void:
	_pixel(5, 1, 2, 2, Color("49325f"))
	_pixel(3, 2, 6, 2, Color("49325f"))
	_pixel(2, 4, 8, 5, Color("49325f"))
	_pixel(3, 9, 6, 2, Color("49325f"))
	_pixel(5, 11, 2, 2, Color("49325f"))
	_pixel(4, 3, 4, 1, Color("9d73d0"))
	_pixel(3, 5, 6, 3, Color("d7b6ff"))
	_pixel(4, 8, 4, 1, Color("9d73d0"))
	_pixel(5, 4, 2, 1, Color("f4ebff"))
	_pixel(6, 5, 1, 2, Color("f4ebff"))
	_pixel(2, 2, 1, 1, Color("7fe5f0"))
	_pixel(9, 9, 1, 1, Color("7fe5f0"))


func _draw_healing_cross() -> void:
	_pixel(4, 1, 4, 2, Color("47633e"))
	_pixel(3, 2, 6, 8, Color("47633e"))
	_pixel(4, 10, 4, 2, Color("47633e"))
	_pixel(5, 3, 2, 6, Color("e6c85e"))
	_pixel(3, 5, 6, 2, Color("e6c85e"))
	_pixel(5, 4, 2, 4, Color("fff2b0"))
	_pixel(4, 5, 4, 1, Color("fff2b0"))
	_pixel(1, 3, 1, 1, Color("9ce8a0"))
	_pixel(10, 8, 1, 1, Color("9ce8a0"))
	_pixel(2, 10, 1, 1, Color("d5f3be"))
	_pixel(9, 2, 1, 1, Color("d5f3be"))


func _pixel(x: int, y: int, width: int, height: int, color: Color) -> void:
	var cell := size / GRID_SIZE
	draw_rect(
		Rect2(
			Vector2(float(x), float(y)) * cell,
			Vector2(float(width), float(height)) * cell
		),
		color
	)
