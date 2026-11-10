extends Control

const GRID_SIZE := Vector2(38.0, 20.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("314b3e"))
	_pixel(0, 14, 38, 6, Color("25382f"))
	_pixel(3, 5, 6, 1, Color("52664a"))
	_pixel(6, 4, 3, 1, Color("52664a"))
	_pixel(28, 6, 5, 1, Color("52664a"))
	_pixel(34, 4, 2, 1, Color("52664a"))
	_pixel(2, 17, 7, 1, Color("536143"))
	_pixel(30, 18, 6, 1, Color("536143"))

	# Bow limbs and string.
	_pixel(31, 2, 2, 2, Color("704328"))
	_pixel(33, 4, 1, 3, Color("a96d36"))
	_pixel(34, 7, 1, 6, Color("d09549"))
	_pixel(33, 13, 1, 3, Color("a96d36"))
	_pixel(31, 16, 2, 2, Color("704328"))
	_pixel(31, 3, 1, 14, Color("e6d5a5"))

	# Tunic, belt, and legs.
	_pixel(14, 11, 12, 6, Color("2e6945"))
	_pixel(16, 12, 8, 1, Color("438451"))
	_pixel(15, 16, 10, 2, Color("253f37"))
	_pixel(17, 18, 3, 2, Color("725039"))
	_pixel(22, 18, 3, 2, Color("725039"))
	_pixel(16, 19, 5, 1, Color("342b29"))
	_pixel(21, 19, 5, 1, Color("342b29"))

	# Drawing arm reaches for the bow.
	_pixel(23, 12, 5, 2, Color("c98756"))
	_pixel(27, 10, 3, 3, Color("d99a68"))
	_pixel(28, 10, 3, 2, Color("e5ad78"))

	# Head and ears.
	_pixel(15, 7, 2, 3, Color("bd7951"))
	_pixel(25, 7, 2, 3, Color("bd7951"))
	_pixel(17, 6, 8, 7, Color("d99a68"))
	_pixel(17, 6, 2, 6, Color("86543d"))
	_pixel(23, 6, 2, 6, Color("86543d"))
	_pixel(19, 8, 1, 1, Color("342c29"))
	_pixel(23, 8, 1, 1, Color("342c29"))
	_pixel(20, 10, 3, 1, Color("a85e49"))

	# Broad green hat and cap.
	_pixel(13, 5, 15, 2, Color("214832"))
	_pixel(16, 3, 10, 3, Color("34734a"))
	_pixel(18, 2, 7, 2, Color("438c55"))
	_pixel(21, 1, 5, 1, Color("2e6945"))
	_pixel(14, 6, 13, 1, Color("173a2a"))


func _pixel(x: int, y: int, width: int, height: int, color: Color) -> void:
	var cell := size / GRID_SIZE
	draw_rect(
		Rect2(
			Vector2(float(x), float(y)) * cell,
			Vector2(float(width), float(height)) * cell
		),
		color
	)
