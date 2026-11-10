extends Control

const GRID_SIZE := Vector2(38.0, 20.0)

var card_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	match card_id:
		"human_anti_mage":
			_draw_anti_mage()
		"human_healer":
			_draw_healer()
		_:
			_draw_warrior()


func _draw_warrior() -> void:
	_draw_backdrop(Color("3c4c51"), Color("29363b"))
	_pixel(4, 5, 4, 8, Color("b18c4f"))
	_pixel(5, 3, 2, 2, Color("e2be69"))
	_pixel(30, 4, 2, 10, Color("795238"))
	_pixel(29, 3, 4, 2, Color("d7b85e"))
	_pixel(14, 11, 12, 6, Color("315575"))
	_pixel(12, 12, 4, 5, Color("27445f"))
	_pixel(23, 12, 5, 4, Color("9b784b"))
	_pixel(14, 16, 11, 2, Color("34404a"))
	_pixel(16, 18, 4, 2, Color("514333"))
	_pixel(22, 18, 4, 2, Color("514333"))
	_draw_human_face(Color("d99a68"))
	_pixel(15, 5, 12, 2, Color("c2cbd0"))
	_pixel(17, 3, 8, 3, Color("88999e"))
	_pixel(18, 3, 6, 1, Color("e3e3d5"))
	_pixel(16, 6, 11, 1, Color("57666b"))
	_pixel(19, 12, 2, 4, Color("b8c5c6"))
	_pixel(18, 13, 4, 2, Color("d9dfd6"))
	_pixel(11, 12, 4, 4, Color("c79a54"))


func _draw_anti_mage() -> void:
	_draw_backdrop(Color("32354b"), Color("25283d"))
	_pixel(4, 5, 2, 1, Color("778ac0"))
	_pixel(7, 3, 1, 2, Color("b5bfea"))
	_pixel(30, 4, 2, 9, Color("7550a4"))
	_pixel(29, 3, 4, 2, Color("b68be2"))
	_pixel(13, 11, 14, 7, Color("44345e"))
	_pixel(14, 12, 12, 5, Color("584477"))
	_pixel(16, 16, 9, 2, Color("302940"))
	_pixel(17, 18, 4, 2, Color("493c42"))
	_pixel(22, 18, 4, 2, Color("493c42"))
	_draw_human_face(Color("e0ad7b"))
	_pixel(14, 4, 14, 4, Color("263149"))
	_pixel(16, 2, 10, 4, Color("374967"))
	_pixel(19, 5, 2, 5, Color("d8e6e2"))
	_pixel(21, 7, 3, 2, Color("78d8e3"))
	_pixel(20, 6, 1, 1, Color("e4ffff"))
	_pixel(21, 9, 2, 1, Color("4b8fa8"))
	_pixel(15, 7, 3, 5, Color("263149"))
	_pixel(24, 7, 3, 5, Color("263149"))


func _draw_healer() -> void:
	_draw_backdrop(Color("52644d"), Color("344639"))
	_pixel(3, 5, 2, 7, Color("84a765"))
	_pixel(2, 4, 4, 2, Color("b1c16d"))
	_pixel(32, 6, 3, 7, Color("79945d"))
	_pixel(31, 4, 4, 2, Color("bacd79"))
	_pixel(14, 11, 12, 7, Color("ded8bd"))
	_pixel(16, 12, 8, 5, Color("f0e9d4"))
	_pixel(14, 16, 12, 2, Color("788456"))
	_pixel(16, 18, 4, 2, Color("74563f"))
	_pixel(22, 18, 4, 2, Color("74563f"))
	_draw_human_face(Color("d99a68"))
	_pixel(15, 4, 12, 3, Color("734b3b"))
	_pixel(14, 6, 3, 7, Color("734b3b"))
	_pixel(25, 6, 3, 7, Color("734b3b"))
	_pixel(18, 13, 2, 3, Color("6c9b64"))
	_pixel(17, 14, 4, 1, Color("6c9b64"))
	_pixel(28, 8, 2, 9, Color("79583c"))
	_pixel(26, 7, 6, 2, Color("d8c88f"))
	_pixel(28, 5, 2, 6, Color("d8c88f"))
	_pixel(29, 6, 1, 4, Color("fff0ba"))


func _draw_backdrop(sky: Color, ground: Color) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), sky)
	_pixel(0, 15, 38, 5, ground)
	_pixel(2, 4, 3, 1, Color("d8c47e"))
	_pixel(7, 6, 2, 1, Color("c0b889"))
	_pixel(29, 3, 2, 1, Color("ded19d"))
	_pixel(33, 6, 3, 1, Color("a6b084"))


func _draw_human_face(skin: Color) -> void:
	_pixel(16, 7, 2, 3, skin.darkened(0.18))
	_pixel(25, 7, 2, 3, skin.darkened(0.18))
	_pixel(17, 5, 9, 8, skin)
	_pixel(18, 9, 7, 3, skin.lightened(0.08))
	_pixel(19, 8, 1, 1, Color("332d2c"))
	_pixel(23, 8, 1, 1, Color("332d2c"))
	_pixel(21, 10, 2, 1, Color("a85e49"))


func _pixel(x: int, y: int, width: int, height: int, color: Color) -> void:
	var cell := size / GRID_SIZE
	draw_rect(
		Rect2(
			Vector2(float(x), float(y)) * cell,
			Vector2(float(width), float(height)) * cell
		),
		color
	)
