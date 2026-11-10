extends Control

const GRID_SIZE := Vector2(38.0, 20.0)

var card_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	match card_id:
		"orc_warrior":
			_draw_orc_warrior()
		"orc_shaman":
			_draw_orc_shaman()
		"orc_goblin":
			_draw_goblin()
		"elf_warrior":
			_draw_elf_warrior()
		"elf_ranger":
			_draw_elf_ranger()
		"elf_mount":
			_draw_elf_mount()
		"elf_shapeshifter":
			_draw_shapeshifter()
		"elf_form_bear":
			_draw_bear()
		"elf_form_wolf":
			_draw_wolf()
		"elf_form_raven":
			_draw_raven()
		"elf_rider":
			_draw_elf_rider()
		"undead_warrior":
			_draw_undead_warrior()
		"undead_mage":
			_draw_undead_mage()
		"undead_butcher":
			_draw_butcher()
		"undead_skeleton":
			_draw_skeleton()
		_:
			_draw_skeleton()


func _draw_orc_warrior() -> void:
	_backdrop(Color("704333"), Color("3f302c"))
	_pixel(11, 9, 16, 8, Color("58734c"))
	_pixel(14, 11, 12, 4, Color("708b53"))
	_pixel(13, 15, 13, 3, Color("453533"))
	_pixel(16, 18, 4, 2, Color("453533"))
	_pixel(22, 18, 4, 2, Color("453533"))
	_orc_face(Color("9bac58"))
	_pixel(12, 4, 14, 3, Color("3d4c38"))
	_pixel(15, 2, 9, 3, Color("536143"))
	_pixel(16, 12, 8, 2, Color("c2a15a"))
	_pixel(30, 4, 2, 12, Color("6b452f"))
	_pixel(28, 3, 6, 3, Color("bf8050"))
	_pixel(29, 4, 4, 1, Color("e2be69"))
	_pixel(12, 12, 4, 4, Color("96a157"))


func _draw_orc_shaman() -> void:
	_backdrop(Color("40324d"), Color("292b36"))
	_pixel(12, 10, 14, 8, Color("4c6847"))
	_pixel(14, 11, 10, 5, Color("697d4d"))
	_pixel(13, 16, 12, 2, Color("352e38"))
	_pixel(16, 18, 4, 2, Color("514137"))
	_pixel(22, 18, 4, 2, Color("514137"))
	_orc_face(Color("a8b962"))
	_pixel(13, 4, 13, 3, Color("3d4c38"))
	_pixel(16, 2, 8, 3, Color("697d4d"))
	_pixel(19, 12, 2, 4, Color("85e4cf"))
	_pixel(17, 13, 6, 2, Color("5ac2bd"))
	_pixel(29, 3, 2, 15, Color("69452f"))
	_pixel(27, 2, 6, 3, Color("d3bd6c"))
	_pixel(28, 5, 4, 2, Color("71e4d7"))
	_pixel(27, 7, 6, 1, Color("368e8c"))
	_pixel(4, 5, 4, 3, Color("70dccc"))


func _draw_goblin() -> void:
	_backdrop(Color("526442"), Color("303d30"))
	_pixel(15, 11, 10, 6, Color("795735"))
	_pixel(17, 15, 8, 2, Color("4c3a2e"))
	_pixel(17, 17, 3, 2, Color("464039"))
	_pixel(22, 17, 3, 2, Color("464039"))
	_pixel(17, 6, 8, 7, Color("9caf54"))
	_pixel(14, 7, 4, 3, Color("9caf54"))
	_pixel(24, 7, 5, 3, Color("9caf54"))
	_pixel(16, 4, 11, 3, Color("475536"))
	_pixel(18, 2, 8, 3, Color("647444"))
	_pixel(18, 8, 2, 2, Color("f0cf69"))
	_pixel(23, 8, 2, 2, Color("f0cf69"))
	_pixel(19, 11, 5, 2, Color("d5d69b"))
	_pixel(20, 11, 3, 1, Color("403631"))
	_pixel(8, 13, 7, 2, Color("967344"))
	_pixel(8, 12, 4, 4, Color("d9b55b"))
	_pixel(5, 12, 4, 4, Color("765332"))
	_pixel(30, 5, 3, 10, Color("d4b453"))


func _draw_elf_warrior() -> void:
	_backdrop(Color("577a66"), Color("315342"))
	_pixel(14, 10, 12, 7, Color("396b4c"))
	_pixel(16, 12, 8, 4, Color("5f9657"))
	_pixel(14, 16, 12, 2, Color("314b3d"))
	_pixel(16, 18, 4, 2, Color("66503b"))
	_pixel(22, 18, 4, 2, Color("66503b"))
	_elf_face(Color("dca170"))
	_pixel(12, 7, 7, 2, Color("dca170"))
	_pixel(25, 7, 7, 2, Color("dca170"))
	_pixel(15, 4, 12, 3, Color("654939"))
	_pixel(18, 2, 7, 3, Color("82553b"))
	_pixel(19, 12, 2, 4, Color("d6dcbd"))
	_pixel(18, 13, 4, 2, Color("eff0d4"))
	_pixel(29, 4, 2, 13, Color("735038"))
	_pixel(27, 3, 6, 3, Color("bea65a"))
	_pixel(6, 5, 4, 2, Color("d2e99b"))


func _draw_elf_ranger() -> void:
	_backdrop(Color("557e6c"), Color("294c43"))
	_pixel(13, 11, 13, 7, Color("34735b"))
	_pixel(15, 12, 9, 4, Color("4f916d"))
	_pixel(15, 16, 10, 2, Color("273e3a"))
	_pixel(17, 18, 3, 2, Color("70513b"))
	_pixel(22, 18, 3, 2, Color("70513b"))
	_elf_face(Color("cf9870"))
	_pixel(12, 7, 7, 2, Color("cf9870"))
	_pixel(25, 7, 7, 2, Color("cf9870"))
	_pixel(13, 5, 15, 2, Color("244b39"))
	_pixel(16, 3, 11, 3, Color("3c8053"))
	_pixel(19, 2, 6, 2, Color("66a65d"))
	_pixel(31, 3, 2, 15, Color("805534"))
	_pixel(30, 3, 4, 2, Color("d3b864"))
	_pixel(31, 4, 1, 13, Color("dfe7bb"))
	_pixel(26, 12, 5, 2, Color("d09a68"))


func _draw_elf_mount() -> void:
	_backdrop(Color("8ca56d"), Color("42583f"))
	_pixel(9, 11, 21, 6, Color("8b6543"))
	_pixel(12, 9, 15, 7, Color("c5a06a"))
	_pixel(16, 8, 11, 5, Color("ddbd7d"))
	_pixel(19, 7, 8, 5, Color("e5c88c"))
	_pixel(26, 9, 7, 4, Color("ddbd7d"))
	_pixel(31, 10, 5, 3, Color("c5a06a"))
	_pixel(33, 11, 1, 1, Color("342d28"))
	_pixel(11, 15, 3, 4, Color("8b6543"))
	_pixel(18, 15, 3, 4, Color("8b6543"))
	_pixel(26, 15, 3, 4, Color("8b6543"))
	_pixel(12, 18, 4, 1, Color("40352e"))
	_pixel(19, 18, 4, 1, Color("40352e"))
	_pixel(27, 18, 4, 1, Color("40352e"))
	_pixel(16, 3, 2, 6, Color("527745"))
	_pixel(18, 3, 8, 6, Color("386445"))
	_pixel(20, 2, 5, 3, Color("4f8950"))
	_pixel(18, 5, 8, 1, Color("d5c778"))
	_pixel(17, 7, 3, 5, Color("bd8863"))
	_pixel(25, 7, 3, 5, Color("bd8863"))
	_pixel(8, 13, 4, 2, Color("d3b864"))
	_pixel(7, 12, 3, 4, Color("805534"))


func _draw_shapeshifter() -> void:
	_backdrop(Color("6c8c65"), Color("3b5b43"))
	_pixel(13, 10, 13, 8, Color("41664c"))
	_pixel(15, 12, 9, 4, Color("71914e"))
	_pixel(15, 16, 10, 2, Color("344b3b"))
	_pixel(17, 18, 3, 2, Color("76563d"))
	_pixel(22, 18, 3, 2, Color("76563d"))
	_elf_face(Color("d2a071"))
	_pixel(13, 4, 13, 3, Color("43583c"))
	_pixel(17, 2, 8, 3, Color("789453"))
	_pixel(14, 6, 4, 7, Color("527d48"))
	_pixel(25, 6, 4, 7, Color("527d48"))
	_pixel(18, 12, 2, 3, Color("77d9a1"))
	_pixel(22, 12, 2, 3, Color("8be8c1"))
	_pixel(19, 13, 4, 1, Color("d3f0b2"))
	_pixel(5, 5, 4, 2, Color("dded9a"))
	_pixel(29, 7, 4, 2, Color("dded9a"))


func _draw_bear() -> void:
	_backdrop(Color("71865f"), Color("414b37"))
	_pixel(8, 10, 22, 8, Color("704b35"))
	_pixel(11, 7, 17, 8, Color("98673e"))
	_pixel(24, 8, 9, 7, Color("98673e"))
	_pixel(26, 5, 4, 4, Color("704b35"))
	_pixel(30, 5, 4, 3, Color("704b35"))
	_pixel(30, 10, 1, 1, Color("342b27"))
	_pixel(31, 12, 4, 2, Color("d4b683"))
	_pixel(11, 16, 4, 4, Color("704b35"))
	_pixel(22, 16, 5, 4, Color("704b35"))
	_pixel(12, 19, 4, 1, Color("3c342e"))
	_pixel(23, 19, 5, 1, Color("3c342e"))
	_pixel(13, 11, 7, 3, Color("b88650"))


func _draw_wolf() -> void:
	_backdrop(Color("6a7f75"), Color("394b43"))
	_pixel(8, 11, 23, 7, Color("707e78"))
	_pixel(12, 8, 17, 8, Color("a6b0a1"))
	_pixel(26, 7, 8, 7, Color("a6b0a1"))
	_pixel(31, 9, 7, 3, Color("a6b0a1"))
	_pixel(35, 10, 2, 2, Color("dbc695"))
	_pixel(29, 7, 1, 1, Color("f1d980"))
	_pixel(28, 8, 2, 1, Color("34312e"))
	_pixel(17, 9, 4, 7, Color("57675f"))
	_pixel(11, 16, 5, 3, Color("707e78"))
	_pixel(23, 16, 5, 3, Color("707e78"))
	_pixel(11, 18, 5, 2, Color("414b46"))
	_pixel(23, 18, 5, 2, Color("414b46"))
	_pixel(17, 12, 7, 2, Color("e1e2c6"))


func _draw_raven() -> void:
	_backdrop(Color("59647a"), Color("30394c"))
	_pixel(7, 11, 23, 7, Color("242936"))
	_pixel(12, 8, 16, 8, Color("343b4f"))
	_pixel(23, 5, 9, 8, Color("222735"))
	_pixel(30, 7, 7, 3, Color("30384b"))
	_pixel(36, 8, 2, 2, Color("d5ad5c"))
	_pixel(27, 6, 1, 1, Color("f2dd83"))
	_pixel(18, 9, 5, 5, Color("626d88"))
	_pixel(10, 15, 5, 3, Color("242936"))
	_pixel(23, 15, 5, 3, Color("242936"))
	_pixel(11, 17, 4, 2, Color("d5ad5c"))
	_pixel(24, 17, 4, 2, Color("d5ad5c"))
	_pixel(17, 10, 5, 3, Color("4c5671"))


func _draw_elf_rider() -> void:
	_backdrop(Color("72906b"), Color("3e5a44"))
	_pixel(14, 11, 12, 7, Color("63824f"))
	_pixel(16, 12, 8, 4, Color("86a85c"))
	_pixel(15, 16, 10, 2, Color("344a3c"))
	_pixel(17, 18, 3, 2, Color("6e533b"))
	_pixel(22, 18, 3, 2, Color("6e533b"))
	_elf_face(Color("d4a074"))
	_pixel(13, 5, 14, 3, Color("704c35"))
	_pixel(17, 3, 8, 3, Color("967044"))
	_pixel(17, 12, 2, 3, Color("e1d3a0"))
	_pixel(23, 12, 2, 3, Color("e1d3a0"))
	_pixel(30, 5, 2, 12, Color("825a39"))
	_pixel(29, 4, 4, 2, Color("d2b35e"))


func _draw_undead_warrior() -> void:
	_backdrop(Color("55566a"), Color("30323e"))
	_pixel(12, 10, 14, 8, Color("525467"))
	_pixel(15, 12, 9, 5, Color("74798a"))
	_pixel(14, 16, 12, 2, Color("3c3a43"))
	_pixel(16, 18, 4, 2, Color("49434a"))
	_pixel(22, 18, 4, 2, Color("49434a"))
	_skeleton_face()
	_pixel(14, 4, 13, 4, Color("343745"))
	_pixel(17, 2, 8, 3, Color("56586c"))
	_pixel(16, 11, 3, 5, Color("d0c28f"))
	_pixel(21, 11, 3, 5, Color("d0c28f"))
	_pixel(18, 13, 4, 2, Color("444554"))
	_pixel(30, 4, 2, 12, Color("755238"))
	_pixel(28, 3, 6, 2, Color("c3b48b"))
	_pixel(29, 4, 4, 1, Color("f0e2b9"))


func _draw_undead_mage() -> void:
	_backdrop(Color("38354f"), Color("292b3b"))
	_pixel(12, 10, 14, 8, Color("44345d"))
	_pixel(14, 12, 10, 5, Color("624679"))
	_pixel(14, 16, 12, 2, Color("302b3d"))
	_pixel(16, 18, 4, 2, Color("443a45"))
	_pixel(22, 18, 4, 2, Color("443a45"))
	_skeleton_face()
	_pixel(13, 3, 14, 5, Color("30263f"))
	_pixel(16, 1, 9, 4, Color("584070"))
	_pixel(18, 6, 8, 5, Color("292637"))
	_pixel(20, 8, 4, 2, Color("74e4e6"))
	_pixel(21, 7, 2, 1, Color("d3ffff"))
	_pixel(28, 3, 2, 15, Color("6c4a36"))
	_pixel(26, 2, 6, 3, Color("bd9660"))
	_pixel(27, 6, 4, 3, Color("70dfe7"))
	_pixel(28, 7, 2, 1, Color("e2ffff"))
	_pixel(4, 7, 4, 2, Color("665092"))
	_pixel(7, 4, 2, 2, Color("7df0f0"))


func _draw_butcher() -> void:
	_backdrop(Color("604447"), Color("36353b"))
	_pixel(11, 10, 17, 8, Color("534b56"))
	_pixel(14, 12, 12, 4, Color("77717a"))
	_pixel(14, 16, 13, 2, Color("3f383d"))
	_pixel(16, 18, 4, 2, Color("484047"))
	_pixel(23, 18, 4, 2, Color("484047"))
	_skeleton_face()
	_pixel(14, 3, 14, 5, Color("49363c"))
	_pixel(17, 2, 9, 4, Color("70464a"))
	_pixel(18, 10, 7, 3, Color("9e6462"))
	_pixel(20, 11, 4, 1, Color("c57a6b"))
	_pixel(30, 4, 2, 12, Color("683f31"))
	_pixel(28, 3, 6, 3, Color("b7a16d"))
	_pixel(5, 10, 3, 2, Color("b1dc71"))
	_pixel(7, 8, 3, 2, Color("77c876"))
	_pixel(6, 13, 4, 2, Color("d5e889"))


func _draw_skeleton() -> void:
	_backdrop(Color("4a4b5c"), Color("30313c"))
	_pixel(13, 12, 12, 5, Color("454653"))
	_pixel(16, 15, 5, 3, Color("d1c9a9"))
	_pixel(21, 15, 5, 3, Color("d1c9a9"))
	_skeleton_face()
	_pixel(17, 12, 8, 2, Color("d1c9a9"))
	_pixel(18, 14, 6, 1, Color("d1c9a9"))
	_pixel(8, 10, 4, 1, Color("d1c9a9"))
	_pixel(7, 9, 1, 4, Color("d1c9a9"))
	_pixel(27, 10, 4, 1, Color("d1c9a9"))
	_pixel(30, 9, 1, 4, Color("d1c9a9"))


func _orc_face(skin: Color) -> void:
	_pixel(15, 6, 3, 4, skin.darkened(0.2))
	_pixel(25, 6, 3, 4, skin.darkened(0.2))
	_pixel(17, 5, 10, 8, skin)
	_pixel(18, 8, 2, 2, Color("352c29"))
	_pixel(23, 8, 2, 2, Color("352c29"))
	_pixel(18, 12, 3, 2, Color("eee3cb"))
	_pixel(23, 12, 3, 2, Color("eee3cb"))


func _elf_face(skin: Color) -> void:
	_pixel(12, 7, 6, 2, skin)
	_pixel(25, 7, 6, 2, skin)
	_pixel(17, 5, 9, 8, skin)
	_pixel(18, 8, 1, 1, Color("29312c"))
	_pixel(23, 8, 1, 1, Color("29312c"))
	_pixel(20, 10, 3, 1, Color("a85e49"))


func _skeleton_face() -> void:
	_pixel(16, 5, 11, 8, Color("d1c9a9"))
	_pixel(17, 7, 3, 3, Color("353643"))
	_pixel(23, 7, 3, 3, Color("353643"))
	_pixel(18, 8, 1, 1, Color("eb6e77"))
	_pixel(24, 8, 1, 1, Color("eb6e77"))
	_pixel(19, 11, 5, 1, Color("807a73"))


func _backdrop(sky: Color, ground: Color) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), sky)
	_pixel(0, 15, 38, 5, ground)
	_pixel(3, 4, 3, 1, Color("d8c47e"))
	_pixel(7, 6, 2, 1, Color("c0b889"))
	_pixel(29, 3, 2, 1, Color("ded19d"))
	_pixel(34, 7, 2, 1, Color("a6b084"))


func _pixel(x: int, y: int, width: int, height: int, color: Color) -> void:
	var cell := size / GRID_SIZE
	draw_rect(
		Rect2(
			Vector2(float(x), float(y)) * cell,
			Vector2(float(width), float(height)) * cell
		),
		color
	)
