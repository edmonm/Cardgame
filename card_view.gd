class_name CardView
extends Panel

signal pressed(view: CardView)
signal drag_dropped(view: CardView, drop_position: Vector2)

const CARD_SIZE := Vector2(168, 240)

var instance: CardInstance
var owner_player: bool = true
var zone: String = "hand"
var selected: bool = false

var _stripe: ColorRect
var _artwork: Panel
var _art_label: Label
var _ranger_art: Control
var _human_art: Control
var _faction_art: Control
var _skill_icon: Label
var _arrow_icon: Control
var _human_skill_icon: Control
var _faction_skill_icon: Control
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
	tooltip_text = shown.rules_text
	_power_label.text = str(instance.current_damage())
	_health_label.text = str(instance.health)
	_stripe.color = _faction_color(shown.faction)
	_art_label.text = shown.card_name.substr(0, 1).to_upper()
	_art_label.add_theme_color_override("font_color", _faction_color(shown.faction).lightened(0.55))
	var is_ranger := shown.card_id == "human_ranger"
	var is_human_portrait := (
		shown.faction == CardResource.Faction.HUMAN
		and shown.card_id != "human_ranger"
	)
	var is_faction_portrait := shown.faction != CardResource.Faction.HUMAN
	_art_label.visible = not is_ranger and not is_human_portrait and not is_faction_portrait
	_ranger_art.visible = is_ranger
	_human_art.visible = is_human_portrait
	_faction_art.visible = is_faction_portrait
	_arrow_icon.visible = is_ranger
	_human_skill_icon.visible = is_human_portrait
	_faction_skill_icon.visible = is_faction_portrait
	_skill_icon.visible = not is_ranger and not is_human_portrait and not is_faction_portrait
	if is_ranger:
		_ranger_art.queue_redraw()
		_arrow_icon.queue_redraw()
	if is_human_portrait:
		_human_art.set("card_id", shown.card_id)
		_human_art.queue_redraw()
		_human_skill_icon.set("card_id", shown.card_id)
		_human_skill_icon.queue_redraw()
	if is_faction_portrait:
		_faction_art.set("card_id", shown.card_id)
		_faction_art.queue_redraw()
		_faction_skill_icon.set("card_id", shown.card_id)
		_faction_skill_icon.queue_redraw()
	_artwork.add_theme_stylebox_override("panel", _make_box_style(
		_faction_color(shown.faction).darkened(0.72),
		_faction_color(shown.faction).lightened(0.15)
	))
	_skill_icon.add_theme_color_override("font_color", _faction_color(shown.faction).lightened(0.5))
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
	_stripe.size = Vector2(CARD_SIZE.x, 4)
	_stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stripe)

	_name_label = _make_label(Vector2(10, 7), Vector2(108, 24), 15, HORIZONTAL_ALIGNMENT_LEFT)
	_name_label.clip_text = true

	var cost_badge := ColorRect.new()
	cost_badge.position = Vector2(134, 7)
	cost_badge.size = Vector2(26, 24)
	cost_badge.color = Color("e0b84a")
	cost_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cost_badge)

	_cost_label = _make_label(Vector2(134, 7), Vector2(26, 24), 15, HORIZONTAL_ALIGNMENT_CENTER)

	_artwork = Panel.new()
	_artwork.position = Vector2(8, 38)
	_artwork.size = Vector2(152, 82)
	_artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_artwork.add_theme_stylebox_override("panel", _make_box_style(Color("202a31"), Color("a88b4e")))
	add_child(_artwork)
	_art_label = _make_label(
		Vector2(0, 0),
		_artwork.size,
		48,
		HORIZONTAL_ALIGNMENT_CENTER,
		_artwork
	)
	_art_label.add_theme_color_override("font_color", Color("d8c99e"))

	_ranger_art = Control.new()
	_ranger_art.set_script(load("res://procedural_ranger_art.gd"))
	_ranger_art.position = Vector2.ZERO
	_ranger_art.size = _artwork.size
	_ranger_art.visible = false
	_artwork.add_child(_ranger_art)

	_human_art = Control.new()
	_human_art.set_script(load("res://procedural_human_art.gd"))
	_human_art.position = Vector2.ZERO
	_human_art.size = _artwork.size
	_human_art.visible = false
	_artwork.add_child(_human_art)

	_faction_art = Control.new()
	_faction_art.set_script(load("res://procedural_faction_art.gd"))
	_faction_art.position = Vector2.ZERO
	_faction_art.size = _artwork.size
	_faction_art.visible = false
	_artwork.add_child(_faction_art)

	var skill_frame := Panel.new()
	skill_frame.position = Vector2(9, 132)
	skill_frame.size = Vector2(34, 40)
	skill_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skill_frame.add_theme_stylebox_override("panel", _make_box_style(Color("20252d"), Color("6b7479")))
	add_child(skill_frame)
	_skill_icon = _make_label(
		Vector2(0, 0),
		skill_frame.size,
		18,
		HORIZONTAL_ALIGNMENT_CENTER,
		skill_frame
	)
	_skill_icon.text = "*"

	_arrow_icon = Control.new()
	_arrow_icon.set_script(load("res://procedural_arrow_icon.gd"))
	_arrow_icon.position = Vector2(0, 0)
	_arrow_icon.size = skill_frame.size
	_arrow_icon.visible = false
	skill_frame.add_child(_arrow_icon)

	_human_skill_icon = Control.new()
	_human_skill_icon.set_script(load("res://procedural_human_skill_icon.gd"))
	_human_skill_icon.position = Vector2.ZERO
	_human_skill_icon.size = skill_frame.size
	_human_skill_icon.visible = false
	skill_frame.add_child(_human_skill_icon)

	_faction_skill_icon = Control.new()
	_faction_skill_icon.set_script(load("res://procedural_faction_skill_icon.gd"))
	_faction_skill_icon.position = Vector2.ZERO
	_faction_skill_icon.size = skill_frame.size
	_faction_skill_icon.visible = false
	skill_frame.add_child(_faction_skill_icon)

	_rules_label = _make_label(Vector2(51, 126), Vector2(108, 72), 12, HORIZONTAL_ALIGNMENT_LEFT)
	_rules_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rules_label.clip_text = false
	_rules_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	var damage_box := Panel.new()
	damage_box.position = Vector2(96, 202)
	damage_box.size = Vector2(30, 34)
	damage_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_box.add_theme_stylebox_override("panel", _make_box_style(Color("24272b"), Color("b97645")))
	add_child(damage_box)
	var damage_caption := _make_label(
		Vector2(0, 2),
		Vector2(30, 11),
		9,
		HORIZONTAL_ALIGNMENT_CENTER,
		damage_box
	)
	damage_caption.text = "ATK"
	_power_label = _make_label(
		Vector2(0, 14),
		Vector2(30, 18),
		16,
		HORIZONTAL_ALIGNMENT_CENTER,
		damage_box
	)
	_power_label.add_theme_color_override("font_color", Color("f0a35e"))

	var health_box := Panel.new()
	health_box.position = Vector2(130, 202)
	health_box.size = Vector2(30, 34)
	health_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_box.add_theme_stylebox_override("panel", _make_box_style(Color("24272b"), Color("bb6666")))
	add_child(health_box)
	var health_caption := _make_label(
		Vector2(0, 2),
		Vector2(30, 11),
		9,
		HORIZONTAL_ALIGNMENT_CENTER,
		health_box
	)
	health_caption.text = "HP"
	_health_label = _make_label(
		Vector2(0, 14),
		Vector2(30, 18),
		16,
		HORIZONTAL_ALIGNMENT_CENTER,
		health_box
	)
	_health_label.add_theme_color_override("font_color", Color("ef6d6d"))


func _make_label(
	label_position: Vector2,
	label_size: Vector2,
	font_size: int,
	alignment: HorizontalAlignment,
	label_parent: Control = null
) -> Label:
	var label := Label.new()
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f3efe4"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if label_parent == null:
		add_child(label)
	else:
		label_parent.add_child(label)
	return label


func _make_box_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	return style


func _apply_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("171a22")
	style.border_color = Color("f0d48a") if selected else _stripe.color
	style.set_border_width_all(3 if selected else 1)
	style.set_corner_radius_all(4)
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
