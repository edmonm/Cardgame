extends Control

const GRID_SIZE := Vector2(12.0, 14.0)

var card_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	match card_id:
		"orc_warrior":
			_draw_fury()
		"orc_shaman":
			_draw_drain()
		"orc_goblin":
			_draw_gold()
		"elf_warrior":
			_draw_double_blades()
		"elf_ranger":
			_draw_switch()
		"elf_mount":
			_draw_last_breath()
		"elf_shapeshifter":
			_draw_shapeshift()
		"elf_form_bear":
			_draw_bear()
		"elf_form_wolf":
			_draw_wolf()
		"elf_form_raven":
			_draw_double_blades()
		"elf_rider":
			_draw_elf_token()
		"undead_warrior":
			_draw_revive()
		"undead_mage":
			_draw_raise_skeleton()
		"undead_butcher":
			_draw_acid()
		"undead_skeleton":
			_draw_skeleton_token()
		_:
			_draw_skeleton_token()


func _draw_fury() -> void:
	_pixel(4, 1, 4, 2, Color("762d28"))
	_pixel(3, 3, 6, 7, Color("762d28"))
	_pixel(5, 10, 3, 3, Color("762d28"))
	_pixel(4, 3, 2, 4, Color("ee7040"))
	_pixel(7, 4, 2, 4, Color("ffae42"))
	_pixel(5, 6, 3, 4, Color("ffd461"))
	_pixel(6, 4, 1, 6, Color("fff1a4"))
	_pixel(2, 8, 1, 2, Color("ffdc69"))
	_pixel(9, 5, 1, 2, Color("ffa34b"))


func _draw_drain() -> void:
	_pixel(1, 3, 4, 2, Color("512c64"))
	_pixel(7, 3, 4, 2, Color("512c64"))
	_pixel(2, 5, 3, 2, Color("9556bb"))
	_pixel(7, 5, 3, 2, Color("9556bb"))
	_pixel(4, 6, 4, 6, Color("3c336b"))
	_pixel(5, 7, 2, 4, Color("d37ee5"))
	_pixel(3, 8, 2, 2, Color("77e1d0"))
	_pixel(7, 8, 2, 2, Color("77e1d0"))
	_pixel(5, 4, 2, 2, Color("ffdf80"))
	_pixel(5, 12, 2, 1, Color("a5f4e3"))


func _draw_gold() -> void:
	_pixel(4, 1, 4, 2, Color("70502a"))
	_pixel(3, 3, 6, 8, Color("a97732"))
	_pixel(4, 4, 4, 6, Color("f1c34c"))
	_pixel(5, 5, 2, 4, Color("fff0a0"))
	_pixel(6, 4, 1, 6, Color("fff7cb"))
	_pixel(2, 4, 1, 2, Color("d7a544"))
	_pixel(9, 7, 1, 2, Color("fff0a0"))
	_pixel(5, 11, 2, 1, Color("70502a"))


func _draw_double_blades() -> void:
	_pixel(2, 2, 2, 9, Color("435349"))
	_pixel(3, 3, 1, 6, Color("d4ead4"))
	_pixel(8, 2, 2, 9, Color("435349"))
	_pixel(8, 3, 1, 6, Color("d4ead4"))
	_pixel(1, 2, 4, 2, Color("88623f"))
	_pixel(7, 2, 4, 2, Color("88623f"))
	_pixel(4, 5, 4, 3, Color("7ca954"))
	_pixel(5, 4, 2, 5, Color("daf090"))
	_pixel(4, 12, 1, 1, Color("d5e89b"))
	_pixel(7, 1, 1, 1, Color("f5edbd"))


func _draw_switch() -> void:
	_pixel(3, 2, 6, 2, Color("416348"))
	_pixel(2, 4, 2, 5, Color("416348"))
	_pixel(8, 4, 2, 5, Color("416348"))
	_pixel(3, 9, 6, 2, Color("416348"))
	_pixel(4, 4, 4, 1, Color("d9ee9a"))
	_pixel(6, 5, 1, 4, Color("d9ee9a"))
	_pixel(4, 8, 4, 1, Color("d9ee9a"))
	_pixel(2, 5, 2, 2, Color("8ad685"))
	_pixel(8, 7, 2, 2, Color("8ad685"))
	_pixel(1, 4, 2, 2, Color("efffb7"))
	_pixel(9, 8, 2, 2, Color("efffb7"))


func _draw_last_breath() -> void:
	_pixel(5, 1, 2, 3, Color("6e5436"))
	_pixel(3, 4, 6, 5, Color("d3bd74"))
	_pixel(4, 5, 4, 3, Color("fff0b0"))
	_pixel(5, 9, 2, 2, Color("75c17c"))
	_pixel(2, 10, 2, 2, Color("75c17c"))
	_pixel(8, 10, 2, 2, Color("75c17c"))
	_pixel(5, 11, 2, 2, Color("d6ed9c"))
	_pixel(1, 4, 2, 2, Color("a8e8a1"))
	_pixel(9, 3, 2, 2, Color("a8e8a1"))


func _draw_shapeshift() -> void:
	_pixel(5, 1, 2, 2, Color("d5ec9a"))
	_pixel(2, 3, 4, 4, Color("8ab75e"))
	_pixel(6, 3, 4, 4, Color("719a59"))
	_pixel(4, 6, 4, 3, Color("b9df73"))
	_pixel(3, 8, 2, 2, Color("c6e993"))
	_pixel(7, 8, 2, 2, Color("a8d875"))
	_pixel(5, 10, 2, 2, Color("6f9955"))
	_pixel(1, 2, 1, 1, Color("f7f0b1"))
	_pixel(10, 5, 1, 1, Color("f7f0b1"))


func _draw_bear() -> void:
	_pixel(2, 4, 8, 6, Color("765236"))
	_pixel(3, 3, 2, 2, Color("765236"))
	_pixel(7, 3, 2, 2, Color("765236"))
	_pixel(4, 6, 1, 1, Color("f4df91"))
	_pixel(7, 6, 1, 1, Color("f4df91"))
	_pixel(5, 8, 3, 1, Color("d9bd87"))
	_pixel(5, 5, 2, 3, Color("9d7043"))
	_pixel(1, 11, 2, 1, Color("d7b674"))
	_pixel(9, 11, 2, 1, Color("d7b674"))


func _draw_wolf() -> void:
	_pixel(2, 4, 8, 6, Color("899790"))
	_pixel(3, 3, 2, 2, Color("65766e"))
	_pixel(7, 3, 2, 2, Color("65766e"))
	_pixel(4, 6, 1, 1, Color("f5dc82"))
	_pixel(7, 6, 1, 1, Color("f5dc82"))
	_pixel(5, 8, 3, 1, Color("414944"))
	_pixel(5, 5, 2, 3, Color("c9d0b6"))
	_pixel(1, 2, 2, 1, Color("e6f0d2"))
	_pixel(9, 2, 2, 1, Color("e6f0d2"))


func _draw_elf_token() -> void:
	_pixel(5, 2, 2, 2, Color("7a533a"))
	_pixel(3, 4, 6, 5, Color("d5a071"))
	_pixel(2, 6, 2, 2, Color("d5a071"))
	_pixel(8, 6, 2, 2, Color("d5a071"))
	_pixel(5, 6, 1, 1, Color("29342f"))
	_pixel(7, 6, 1, 1, Color("29342f"))
	_pixel(4, 9, 4, 2, Color("548550"))
	_pixel(2, 11, 8, 1, Color("d5e89b"))
	_pixel(1, 3, 2, 1, Color("d5e89b"))
	_pixel(9, 3, 2, 1, Color("d5e89b"))


func _draw_revive() -> void:
	_pixel(3, 2, 6, 2, Color("545462"))
	_pixel(2, 4, 8, 6, Color("545462"))
	_pixel(3, 10, 6, 2, Color("545462"))
	_pixel(4, 3, 4, 1, Color("d2c8a9"))
	_pixel(3, 5, 6, 3, Color("e9dfbc"))
	_pixel(4, 8, 4, 1, Color("d2c8a9"))
	_pixel(5, 4, 2, 1, Color("eb727a"))
	_pixel(6, 5, 1, 2, Color("eb727a"))
	_pixel(5, 9, 2, 2, Color("74dc95"))
	_pixel(4, 10, 4, 1, Color("74dc95"))
	_pixel(2, 1, 1, 1, Color("b8edc2"))
	_pixel(9, 11, 1, 1, Color("b8edc2"))


func _draw_raise_skeleton() -> void:
	_pixel(2, 8, 8, 3, Color("54416e"))
	_pixel(3, 6, 6, 2, Color("54416e"))
	_pixel(4, 5, 4, 2, Color("e1d8b8"))
	_pixel(5, 6, 1, 1, Color("ec777d"))
	_pixel(7, 6, 1, 1, Color("ec777d"))
	_pixel(5, 2, 2, 3, Color("81e8e4"))
	_pixel(3, 3, 2, 2, Color("81e8e4"))
	_pixel(7, 3, 2, 2, Color("81e8e4"))
	_pixel(4, 4, 4, 2, Color("bd91e1"))
	_pixel(5, 5, 2, 2, Color("f5e1ff"))
	_pixel(1, 4, 1, 1, Color("f7f0b1"))
	_pixel(10, 2, 1, 1, Color("f7f0b1"))


func _draw_acid() -> void:
	_pixel(4, 2, 4, 2, Color("4d633a"))
	_pixel(2, 4, 8, 5, Color("4d633a"))
	_pixel(3, 9, 6, 2, Color("4d633a"))
	_pixel(4, 4, 2, 2, Color("b7d85a"))
	_pixel(7, 6, 2, 2, Color("8acb57"))
	_pixel(5, 8, 2, 2, Color("d8ed75"))
	_pixel(2, 2, 1, 1, Color("d8ed75"))
	_pixel(9, 10, 1, 1, Color("d8ed75"))
	_pixel(1, 6, 1, 1, Color("94e47b"))
	_pixel(10, 4, 1, 1, Color("94e47b"))


func _draw_skeleton_token() -> void:
	_pixel(3, 3, 6, 3, Color("d5cdb0"))
	_pixel(2, 4, 8, 4, Color("d5cdb0"))
	_pixel(4, 7, 1, 1, Color("e9757e"))
	_pixel(7, 7, 1, 1, Color("e9757e"))
	_pixel(4, 9, 4, 1, Color("e4dbc0"))
	_pixel(5, 10, 2, 3, Color("d5cdb0"))
	_pixel(3, 12, 2, 1, Color("d5cdb0"))
	_pixel(7, 12, 2, 1, Color("d5cdb0"))
	_pixel(1, 2, 1, 1, Color("bdc4b8"))
	_pixel(10, 9, 1, 1, Color("bdc4b8"))


func _pixel(x: int, y: int, width: int, height: int, color: Color) -> void:
	var cell := size / GRID_SIZE
	draw_rect(
		Rect2(
			Vector2(float(x), float(y)) * cell,
			Vector2(float(width), float(height)) * cell
		),
		color
	)
