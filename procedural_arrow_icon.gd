extends Control

const GRID_SIZE := Vector2(9.0, 10.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	# Bright pixel glints frame the arrow without obscuring its silhouette.
	_pixel(1, 2, 1, 1, Color("74d9ed"))
	_pixel(7, 6, 1, 1, Color("74d9ed"))
	_pixel(2, 8, 1, 1, Color("f6dc83"))
	_pixel(6, 1, 1, 1, Color("f6dc83"))

	# Dark outline gives the diagonal shaft and head a crisp pixel-art edge.
	_pixel(1, 7, 2, 2, Color("402d22"))
	_pixel(2, 6, 2, 2, Color("402d22"))
	_pixel(3, 5, 2, 2, Color("402d22"))
	_pixel(4, 4, 2, 2, Color("402d22"))
	_pixel(5, 3, 2, 2, Color("402d22"))
	_pixel(6, 2, 3, 2, Color("402d22"))
	_pixel(5, 1, 4, 3, Color("402d22"))
	_pixel(6, 0, 3, 4, Color("402d22"))

	# Gold arrow head and shaft.
	_pixel(6, 1, 2, 2, Color("ffdf72"))
	_pixel(7, 1, 2, 2, Color("ffdf72"))
	_pixel(6, 0, 2, 1, Color("fff0ad"))
	_pixel(8, 1, 1, 2, Color("fff0ad"))
	_pixel(2, 7, 1, 1, Color("ffe9a0"))
	_pixel(3, 6, 1, 1, Color("ffe9a0"))
	_pixel(4, 5, 1, 1, Color("ffe9a0"))
	_pixel(5, 4, 1, 1, Color("ffe9a0"))
	_pixel(6, 3, 1, 1, Color("ffe9a0"))

	# Cyan feather fletching adds a small flash at the tail.
	_pixel(1, 6, 2, 1, Color("58bfd4"))
	_pixel(1, 8, 2, 1, Color("58bfd4"))
	_pixel(2, 5, 1, 1, Color("a0eff5"))
	_pixel(2, 9, 1, 1, Color("a0eff5"))


func _pixel(x: int, y: int, width: int, height: int, color: Color) -> void:
	var cell := size / GRID_SIZE
	draw_rect(
		Rect2(
			Vector2(float(x), float(y)) * cell,
			Vector2(float(width), float(height)) * cell
		),
		color
	)
