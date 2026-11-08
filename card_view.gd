class_name CardView
extends Panel

signal pressed(view: CardView)
signal drag_dropped(view: CardView, drop_position: Vector2)

const CARD_SIZE := Vector2(124, 176)

var instance: CardInstance
var owner_player: bool = true
var zone: String = "hand"
var selected: bool = false

var _stripe: ColorRect
var _name_label: Label
var _cost_label: Label
var _rules_label: Label
var _power_label: Label
var _health_label: Label
var _move_tween: Tween
var _left_pressed: bool = false
var _dragging: bool = false
var _press_position: Vector2 = Vector2.ZERO
var _drag_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	size = CARD_SIZE
	custom_minimum_size = CARD_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	clip_contents = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_build()
	if instance != null:
		refresh()


func setup(card: CardInstance, player_owned: bool, zone_name: String) -> void:
	instance = card
	owner_player = player_owned
	zone = zone_name
	if is_node_ready():
		refresh()


func refresh() -> void:
	if instance == null or _name_label == null:
		return
	var shown := instance.current_definition()
	_name_label.text = shown.card_name
	_cost_label.text = str(instance.definition.gold_cost)
	_rules_label.text = shown.rules_text
	_power_label.text = str(instance.current_damage())
	_health_label.text = str(instance.health)
	_stripe.color = _faction_color(shown.faction)
	_apply_style()
	var used_attack := zone == "board" and instance.attacks_left <= 0
	modulate = Color(0.62, 0.62, 0.62) if used_attack and not selected else Color.WHITE


func move_to(target: Vector2) -> Tween:
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	_move_tween = create_tween()
	_move_tween.tween_property(self, "position", target, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return _move_tween


func lunge_toward(target_pos: Vector2) -> void:
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	var origin := position
	var direction := target_pos - origin
	if direction.length() < 1.0:
		direction = Vector2.UP if owner_player else Vector2.DOWN
	else:
		direction = direction.normalized()
	var tween := create_tween()
	tween.tween_property(self, "position", origin + direction * 70.0, 0.1)
	tween.tween_property(self, "position", origin, 0.12)
	await tween.finished


func _gui_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse == null:
		return
	if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		_left_pressed = true
		_dragging = false
		_press_position = mouse.global_position
		_drag_offset = mouse.global_position - global_position
		pressed.emit(self)
		accept_event()


func _input(event: InputEvent) -> void:
	if not _left_pressed:
		return
	var motion := event as InputEventMouseMotion
	if motion != null and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _dragging and motion.global_position.distance_to(_press_position) >= 12.0:
			_dragging = true
			z_index = 30
			if _move_tween != null and _move_tween.is_valid():
				_move_tween.kill()
		if _dragging:
			global_position = motion.global_position - _drag_offset
		return
	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.button_index == MOUSE_BUTTON_LEFT and not mouse.pressed:
		_left_pressed = false
		if _dragging:
			z_index = 1
			drag_dropped.emit(self, mouse.global_position)
		_dragging = false


func _build() -> void:
	_stripe = ColorRect.new()
	_stripe.position = Vector2(0, 0)
	_stripe.size = Vector2(CARD_SIZE.x, 8)
	_stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stripe)

	var cost_badge := ColorRect.new()
	cost_badge.position = Vector2(8, 16)
	cost_badge.size = Vector2(24, 24)
	cost_badge.color = Color("e0b84a")
	cost_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cost_badge)

	_cost_label = _make_label(Vector2(8, 16), Vector2(24, 24), 16, HORIZONTAL_ALIGNMENT_CENTER)
	_name_label = _make_label(Vector2(36, 14), Vector2(82, 40), 13, HORIZONTAL_ALIGNMENT_LEFT)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rules_label = _make_label(Vector2(8, 58), Vector2(108, 78), 11, HORIZONTAL_ALIGNMENT_LEFT)
	_rules_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rules_label.clip_text = true
	_power_label = _make_label(Vector2(8, 142), Vector2(48, 28), 20, HORIZONTAL_ALIGNMENT_LEFT)
	_power_label.add_theme_color_override("font_color", Color("f0a35e"))
	_health_label = _make_label(Vector2(68, 142), Vector2(48, 28), 20, HORIZONTAL_ALIGNMENT_RIGHT)
	_health_label.add_theme_color_override("font_color", Color("ef6d6d"))


func _make_label(label_position: Vector2, label_size: Vector2, font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f3efe4"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("171a22")
	style.border_color = Color("f0d48a") if selected else _stripe.color
	style.set_border_width_all(3 if selected else 1)
	style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", style)


func _on_mouse_entered() -> void:
	if zone != "hand":
		return
	z_index = 20
	pivot_offset = size * 0.5
	scale = Vector2(1.06, 1.06)


func _on_mouse_exited() -> void:
	if zone != "hand":
		return
	z_index = 1
	scale = Vector2.ONE


func _faction_color(faction: CardResource.Faction) -> Color:
	match faction:
		CardResource.Faction.ORC:
			return Color("b5523a")
		CardResource.Faction.ELF:
			return Color("3e8f63")
		CardResource.Faction.UNDEAD:
			return Color("7d6aa3")
		_:
			return Color("c4a15a")
