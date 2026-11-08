extends Node2D

# Playable match. Starter gold costs are on the cards.
# High attack speed and Swift Attack strike twice.
# Shaman drains 1 damage and 1 health, then other allies gain +1/+1.
# Elf Mount leaves a 2/2 Dismounted Elf. There are no spells yet.

const DECK_IDS: Array[String] = [
	"human_warrior",
	"human_anti_mage",
	"human_ranger",
	"human_healer",
	"orc_warrior",
	"orc_shaman",
	"orc_goblin",
	"elf_warrior",
	"elf_ranger",
	"elf_mount",
	"elf_shapeshifter",
	"undead_warrior",
	"undead_mage",
	"undead_butcher",
]

const FACTIONS: Array[CardResource.Faction] = [
	CardResource.Faction.HUMAN,
	CardResource.Faction.ORC,
	CardResource.Faction.ELF,
	CardResource.Faction.UNDEAD,
]

const MAX_BOARD := 6
const MAX_HAND := 10
const STARTING_GOLD := 3
const GOLD_PER_ROUND := 2
const GOLD_CAP := 10
const NEXUS_HEALTH := 20
const OPENING_HAND := 4

signal choice_made(ability_id: String)
signal blocks_confirmed

var player_deck: Array[CardInstance] = []
var enemy_deck: Array[CardInstance] = []
var player_hand: Array[CardInstance] = []
var enemy_hand: Array[CardInstance] = []
var player_board: Array[CardInstance] = []
var enemy_board: Array[CardInstance] = []
var player_hand_views: Array[CardView] = []
var player_views: Array[CardView] = []
var enemy_views: Array[CardView] = []
var combat_attackers: Array[CardInstance] = []
var combat_blockers: Dictionary = {}
var blockers_used: Array[CardInstance] = []
var selected_combat_attacker: CardInstance = null

var player_gold: int = STARTING_GOLD
var enemy_gold: int = STARTING_GOLD
var player_nexus: int = NEXUS_HEALTH
var enemy_nexus: int = NEXUS_HEALTH
var round_number: int = 1
var deaths_this_round: int = 0
var player_has_attack_token: bool = true
var player_attack_declared: bool = false
var combat_preview: String = ""

var player_turn: bool = true
var busy: bool = false
var awaiting_choice: bool = false
var game_over: bool = false
var selected_faction: CardResource.Faction = CardResource.Faction.HUMAN
var enemy_faction: CardResource.Faction = CardResource.Faction.ORC
var mode: String = ""
var selected: CardView = null
var _in_acid: bool = false
var _log_lines: Array[String] = []

var board_root: Control
var board_table: BoardTable
var start_layer: Control
var action_row: HBoxContainer
var choice_layer: Control
var choice_box: VBoxContainer
var enemy_nexus_button: Button
var end_button: Button
var attack_token_panel: PanelContainer
var attack_token_label: Label
var oracle_button: Button
var deck_panel: PanelContainer
var deck_label: Label
var player_nexus_label: Label
var gold_bar: GoldBar
var info_label: Label
var status_label: Label


func _ready() -> void:
	_build_ui()
	_show_class_select()


func _start_game(faction: CardResource.Faction) -> void:
	selected_faction = faction
	var possible_enemy_factions := FACTIONS.duplicate()
	possible_enemy_factions.erase(faction)
	enemy_faction = possible_enemy_factions.pick_random()
	player_deck = _make_deck(selected_faction)
	enemy_deck = _make_deck(enemy_faction)
	for _i in OPENING_HAND:
		draw_card(true)
		draw_card(false)
	_log("Play units from your hand. Drag attackers into combat when you have the Attack Token.")
	_log("Round 1. You have %d gold." % player_gold)
	start_layer.queue_free()
	_refresh_all()


func _make_deck(faction: CardResource.Faction) -> Array[CardInstance]:
	var deck: Array[CardInstance] = []
	for card_id in DECK_IDS:
		var card := CardDatabase.create_instance(card_id)
		if card == null:
			push_error("Missing card: %s" % card_id)
			continue
		if card.definition.faction != faction:
			continue
		deck.append(card)
	deck.shuffle()
	return deck


func draw_card(player_side: bool) -> void:
	var deck: Array[CardInstance] = player_deck if player_side else enemy_deck
	var hand: Array[CardInstance] = player_hand if player_side else enemy_hand
	if deck.is_empty():
		return
	if hand.size() >= MAX_HAND:
		deck.pop_back()
		return
	var card: CardInstance = deck.pop_back()
	hand.append(card)
	if not player_side:
		return
	var view := _create_view(card, true, "hand")
	player_hand_views.append(view)
	board_root.add_child(view)
	view.position = Vector2(_width() * 0.5, _hand_y())


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font_size = 18
	root.theme = theme
	layer.add_child(root)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("0c1016")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var backdrop_material := ShaderMaterial.new()
	backdrop_material.shader = load("res://board_backdrop.gdshader") as Shader
	backdrop.material = backdrop_material
	root.add_child(backdrop)

	board_root = Control.new()
	board_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(board_root)

	board_table = BoardTable.new()
	board_table.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_table.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_root.add_child(board_table)

	var hud := Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)

	info_label = _make_hud_label(hud, 18)
	player_nexus_label = _make_hud_label(hud, 22)
	gold_bar = GoldBar.new()
	gold_bar.custom_minimum_size = Vector2(260, 74)
	hud.add_child(gold_bar)
	status_label = _make_hud_label(hud, 18)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	enemy_nexus_button = Button.new()
	enemy_nexus_button.pressed.connect(_on_enemy_nexus_pressed)
	hud.add_child(enemy_nexus_button)

	end_button = Button.new()
	end_button.text = "End Turn"
	end_button.pressed.connect(_on_end_turn)
	hud.add_child(end_button)

	attack_token_panel = PanelContainer.new()
	hud.add_child(attack_token_panel)
	var token_style := StyleBoxFlat.new()
	token_style.bg_color = Color("10191f", 0.96)
	token_style.border_color = Color("a88b4e")
	token_style.set_border_width_all(1)
	token_style.set_corner_radius_all(10)
	attack_token_panel.add_theme_stylebox_override("panel", token_style)
	attack_token_label = _make_hud_label(attack_token_panel, 16)
	attack_token_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	attack_token_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attack_token_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	oracle_button = Button.new()
	oracle_button.text = "Oracle's Eye"
	oracle_button.pressed.connect(_begin_preview)
	hud.add_child(oracle_button)

	deck_panel = PanelContainer.new()
	hud.add_child(deck_panel)
	var deck_style := StyleBoxFlat.new()
	deck_style.bg_color = Color("152329", 0.96)
	deck_style.border_color = Color("a88b4e")
	deck_style.set_border_width_all(2)
	deck_style.set_corner_radius_all(8)
	deck_panel.add_theme_stylebox_override("panel", deck_style)
	deck_label = _make_hud_label(deck_panel, 18)
	deck_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	deck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deck_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	action_row = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	action_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(action_row)

	choice_layer = Control.new()
	choice_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	choice_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	choice_layer.visible = false
	choice_layer.z_index = 30
	root.add_child(choice_layer)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	choice_layer.add_child(dim)
	choice_box = VBoxContainer.new()
	choice_box.position = Vector2(520, 340)
	choice_box.add_theme_constant_override("separation", 10)
	choice_layer.add_child(choice_box)


func _show_class_select() -> void:
	start_layer = Control.new()
	start_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	start_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	start_layer.z_index = 20
	board_root.get_parent().add_child(start_layer)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_layer.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_STOP
	start_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("171a22")
	panel_style.border_color = Color("c4a15a")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var options := VBoxContainer.new()
	options.add_theme_constant_override("separation", 12)
	panel.add_child(options)

	var title := _make_hud_label(options, 30)
	title.text = "Choose Your Class"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var description := _make_hud_label(options, 16)
	description.text = "Your deck will contain cards from your chosen class only."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_add_faction_button(options, "Human", CardResource.Faction.HUMAN)
	_add_faction_button(options, "Orc", CardResource.Faction.ORC)
	_add_faction_button(options, "Elf", CardResource.Faction.ELF)
	_add_faction_button(options, "Undead", CardResource.Faction.UNDEAD)


func _add_faction_button(parent: VBoxContainer, title: String, faction: CardResource.Faction) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(0, 48)
	button.pressed.connect(_start_game.bind(faction))
	parent.add_child(button)


func _faction_name(faction: CardResource.Faction) -> String:
	match faction:
		CardResource.Faction.ORC:
			return "Orc"
		CardResource.Faction.ELF:
			return "Elf"
		CardResource.Faction.UNDEAD:
			return "Undead"
		_:
			return "Human"


func _make_hud_label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f3efe4"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _create_view(card: CardInstance, player_owned: bool, zone_name: String) -> CardView:
	var view := CardView.new()
	view.setup(card, player_owned, zone_name)
	view.pressed.connect(_on_card_pressed)
	view.drag_dropped.connect(_on_card_drag_dropped)
	return view


func _on_card_pressed(view: CardView) -> void:
	if mode == "declare_attack":
		return
	if mode == "block" and player_turn == false:
		if view.zone == "board" and not view.owner_player:
			_select_attacker_to_block(view)
		return
	if game_over or busy or awaiting_choice or not player_turn:
		return
	if view.zone == "hand" and view.owner_player:
		await _play_from_hand(view)
	elif view.zone == "board" and view.owner_player:
		_on_player_unit_pressed(view)
	elif view.zone == "board" and not view.owner_player:
		await _on_enemy_unit_pressed(view)


func _play_from_hand(view: CardView) -> void:
	var card := view.instance
	if player_gold < card.definition.gold_cost:
		_log("Not enough gold.")
		return
	if player_board.size() >= MAX_BOARD:
		_log("Your board is full.")
		return
	busy = true
	if card.definition.ability_choice_required and card.chosen_ability_id.is_empty():
		awaiting_choice = true
		_refresh_hud()
		var picked := await _prompt_choice(card.definition.abilities)
		awaiting_choice = false
		if picked.is_empty():
			busy = false
			_refresh_all()
			return
		card.choose_ability(picked)
	player_gold -= card.definition.gold_cost
	player_hand.erase(card)
	player_hand_views.erase(view)
	view.zone = "board"
	view.scale = Vector2.ONE
	view.z_index = 1
	card.attacks_left = 1
	player_board.append(card)
	player_views.append(view)
	mode = ""
	busy = false
	_log("Played %s." % card.definition.card_name)
	_refresh_all()


func _prompt_choice(abilities: Array[CardAbility]) -> String:
	_clear_box(choice_box)
	choice_layer.visible = true
	var title := _make_hud_label(choice_box, 22)
	title.text = "Choose one ability"
	for ability in abilities:
		var button := Button.new()
		button.text = ability.text
		button.custom_minimum_size = Vector2(760, 48)
		button.pressed.connect(_emit_choice.bind(ability.ability_id))
		choice_box.add_child(button)
	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.custom_minimum_size = Vector2(760, 40)
	cancel.pressed.connect(_emit_choice.bind(""))
	choice_box.add_child(cancel)
	var picked: String = await choice_made
	choice_layer.visible = false
	_clear_box(choice_box)
	return picked


func _emit_choice(ability_id: String) -> void:
	choice_made.emit(ability_id)


func _on_player_unit_pressed(view: CardView) -> void:
	var unit := view.instance
	if mode == "switch" and selected != null and unit != selected.instance:
		_switch_units(selected.instance, unit)
		return
	if mode == "drain" and selected != null and unit != selected.instance:
		_drain(selected.instance, unit, player_board)
		return
	if mode == "heal" and selected != null:
		_full_heal(selected.instance, unit)
		return
	selected = view
	mode = ""
	combat_preview = ""
	_log("Selected %s." % unit.current_definition().card_name)
	_refresh_all()


func _on_enemy_unit_pressed(view: CardView) -> void:
	if mode == "preview" and selected != null and not busy and player_turn:
		combat_preview = _get_combat_preview(selected.instance, view.instance)
		mode = ""
		_refresh_all()
		return


func _on_enemy_nexus_pressed() -> void:
	if mode == "preview" and selected != null and not busy and player_turn:
		combat_preview = _get_combat_preview(selected.instance, null)
		mode = ""
		_refresh_all()
		return


func _begin_attack() -> void:
	if not player_has_attack_token:
		_log("You do not have the Attack Token this round.")
		return
	if player_attack_declared:
		_log("You have already declared your attack this round.")
		return
	if _eligible_attackers(player_board).is_empty():
		_log("You have no ready units to attack with.")
		return
	mode = "declare_attack"
	combat_attackers.clear()
	combat_blockers.clear()
	combat_preview = ""
	_log("Drag ready units from your bench to the combat zone, then confirm.")
	_refresh_all()


func _on_card_drag_dropped(view: CardView, drop_position: Vector2) -> void:
	if mode == "block" and not player_turn and view.owner_player and view.zone == "board":
		if selected_combat_attacker != null and board_table.is_combat_drop(drop_position):
			_assign_blocker(view)
		elif selected_combat_attacker != null:
			_remove_blocker(view.instance)
		else:
			_layout()
		return
	if mode != "declare_attack" or not view.owner_player or view.zone != "board":
		_layout()
		return
	if not board_table.is_combat_drop(drop_position):
		if combat_attackers.has(view.instance):
			combat_attackers.erase(view.instance)
			_refresh_all()
			return
		_layout()
		return
	if not player_board.has(view.instance) or view.instance.attacks_left <= 0:
		_layout()
		return
	if combat_attackers.has(view.instance):
		combat_attackers.erase(view.instance)
		_layout()
		return
	combat_attackers.append(view.instance)
	_place_attacking_view(view.instance, true, combat_attackers.size() - 1)
	_refresh_all()


func _confirm_attack() -> void:
	if mode != "declare_attack" or combat_attackers.is_empty() or busy:
		return
	busy = true
	player_attack_declared = true
	mode = ""
	var attackers := combat_attackers.duplicate()
	var blockers := _choose_ai_blockers(attackers, enemy_board)
	combat_blockers = blockers
	_log("Attack declared with %d unit(s)." % attackers.size())
	_refresh_all()
	await _resolve_attack_group(attackers, blockers, true)
	busy = false
	combat_attackers.clear()
	combat_blockers.clear()
	_clear_dead_selection()
	if not game_over:
		_refresh_all()


func _cancel_attack() -> void:
	combat_attackers.clear()
	combat_blockers.clear()
	mode = ""
	_log("Attack cancelled.")
	_refresh_all()


func _begin_preview() -> void:
	if selected == null or busy or not player_turn:
		return
	mode = "preview"
	combat_preview = ""
	_refresh_board_table()
	_log("Oracle's Eye: click an enemy unit or nexus to preview combat.")


func _get_combat_preview(attacker: CardInstance, defender: CardInstance) -> String:
	var attack_copy := _copy_for_preview(attacker)
	var defense_copy: CardInstance = null
	if defender != null:
		defense_copy = _copy_for_preview(defender)

	for ally in player_board:
		if ally.health > 0 and ally.chosen_ability_id == "ally_attack_heal":
			attack_copy.gain_health(2)

	var strikes := 2 if (
		attack_copy.has_active_keyword("high_attack_speed")
		or attack_copy.has_active_keyword("swift_attack")
	) else 1
	if defense_copy == null:
		var damage_to_nexus := attack_copy.current_damage() * strikes
		var stolen_gold := _preview_stolen_gold(damage_to_nexus, attacker.has_active_keyword("steal_gold"))
		return "%s: %d strike(s), %d Nexus damage. %d gold stolen." % [
			attack_copy.current_definition().card_name,
			strikes,
			damage_to_nexus,
			stolen_gold,
		]

	var damage_to_defender := 0
	var damage_to_attacker := 0
	for _strike in strikes:
		if attack_copy.health <= 0 or defense_copy.health <= 0:
			break
		var attack_damage := attack_copy.current_damage()
		var counter_damage := defense_copy.current_damage()
		damage_to_defender += _preview_damage(defense_copy, attack_damage, attack_copy)
		damage_to_attacker += _preview_damage(attack_copy, counter_damage, defense_copy)

	var stolen_gold := _preview_stolen_gold(
		damage_to_defender,
		attacker.has_active_keyword("steal_gold")
	)
	return "%s takes %d (%d HP); %s takes %d (%d HP); %d gold stolen." % [
		attack_copy.current_definition().card_name,
		damage_to_attacker,
		maxi(attack_copy.health, 0),
		defense_copy.current_definition().card_name,
		damage_to_defender,
		maxi(defense_copy.health, 0),
		stolen_gold,
	]


func _preview_stolen_gold(damage: int, can_steal: bool) -> int:
	if not can_steal:
		return 0
	return mini(damage, mini(enemy_gold, GOLD_CAP - player_gold))


func _copy_for_preview(source: CardInstance) -> CardInstance:
	var copy := CardInstance.new(source.definition)
	copy.damage = source.damage
	copy.health = source.health
	copy.max_health = source.max_health
	copy.fury_bonus = source.fury_bonus
	copy.revives_remaining = source.revives_remaining
	copy.current_form_id = source.current_form_id
	copy.chosen_ability_id = source.chosen_ability_id
	copy.silenced = source.silenced
	return copy


func _preview_damage(target: CardInstance, raw_amount: int, striker: CardInstance) -> int:
	if target.health <= 0 or raw_amount <= 0:
		return 0
	var dealt := raw_amount
	if target.has_active_keyword("tough"):
		dealt = maxi(raw_amount - 1, 0)
	target.health -= dealt
	if dealt > 0 and target.health > 0 and target.has_active_keyword("fury"):
		target.apply_fury()
	if dealt > 0 and target.has_active_keyword("acidic_blood") and striker != null:
		_preview_damage(striker, 2, null)
	if target.health <= 0 and target.revives_remaining > 0 and not target.silenced:
		target.revives_remaining = 0
		target.health = target.definition.health
		target.max_health = target.definition.health
		target.fury_bonus = 0
	return dealt


func _begin_switch() -> void:
	mode = "switch"
	_log("Click an ally to switch positions.")


func _begin_drain() -> void:
	mode = "drain"
	_log("Click an ally to drain.")


func _begin_heal() -> void:
	mode = "heal"
	_log("Click an ally to fully heal.")


func _cast_shapeshift(form_id: String) -> void:
	if selected == null:
		return
	var unit := selected.instance
	if unit.ability_used or not unit.shapeshift(form_id):
		return
	unit.ability_used = true
	_log("Shapeshifted into %s." % unit.current_definition().card_name)
	_refresh_all()


func _switch_units(ranger: CardInstance, ally: CardInstance) -> void:
	var first := player_board.find(ranger)
	var second := player_board.find(ally)
	if first < 0 or second < 0:
		return
	var swapped_unit := player_board[first]
	player_board[first] = player_board[second]
	player_board[second] = swapped_unit
	var swapped_view := player_views[first]
	player_views[first] = player_views[second]
	player_views[second] = swapped_view
	ranger.ability_used = true
	mode = ""
	_log("Switched positions.")
	_refresh_all()


func _drain(shaman: CardInstance, victim: CardInstance, allies: Array[CardInstance]) -> void:
	var damage_loss := 1 if victim.damage > 0 else 0
	var health_loss := 1 if victim.health > 0 else 0
	victim.damage -= damage_loss
	if health_loss > 0:
		victim.max_health = maxi(1, victim.max_health - health_loss)
		victim.health -= health_loss
	for ally in allies:
		if ally == victim or ally.health <= 0:
			continue
		ally.damage += damage_loss
		if health_loss > 0:
			ally.gain_health(1)
	shaman.ability_used = true
	mode = ""
	_log("Shaman drained %s." % victim.current_definition().card_name)
	_remove_dead(true)
	_remove_dead(false)
	_refresh_all()


func _full_heal(healer: CardInstance, target: CardInstance) -> void:
	target.full_heal()
	healer.ability_used = true
	mode = ""
	_log("Fully healed %s." % target.current_definition().card_name)
	_refresh_all()


func _eligible_attackers(board: Array[CardInstance]) -> Array[CardInstance]:
	var attackers: Array[CardInstance] = []
	for unit in board:
		if unit.health > 0 and unit.attacks_left > 0:
			attackers.append(unit)
	return attackers


func _choose_ai_blockers(
	attackers: Array[CardInstance],
	defenders: Array[CardInstance]
) -> Dictionary:
	var assignments: Dictionary = {}
	var used: Array[CardInstance] = []
	for attacker in attackers:
		var best_defender: CardInstance = null
		var best_score := 0
		for defender in defenders:
			if defender.health <= 0 or used.has(defender):
				continue
			var damage_to_attacker := defender.current_damage()
			if attacker.has_active_keyword("tough"):
				damage_to_attacker = maxi(damage_to_attacker - 1, 0)
			var damage_to_defender := attacker.current_damage()
			if defender.has_active_keyword("tough"):
				damage_to_defender = maxi(damage_to_defender - 1, 0)
			var score := 0
			if damage_to_attacker >= attacker.health:
				score += 3
			if damage_to_defender >= defender.health:
				score -= 3
			if score > best_score:
				best_score = score
				best_defender = defender
		if best_defender != null:
			assignments[attacker] = best_defender
			used.append(best_defender)
	return assignments


func _resolve_attack_group(
	attackers: Array[CardInstance],
	blockers: Dictionary,
	attacker_is_player: bool
) -> void:
	for attacker in attackers:
		if game_over:
			break
		var defender: CardInstance = blockers.get(attacker) as CardInstance
		await _resolve_combat(attacker, defender, attacker_is_player)
	combat_attackers.clear()
	combat_blockers.clear()
	blockers_used.clear()
	selected_combat_attacker = null
	_layout()


func _bench_position(unit: CardInstance, player_owned: bool) -> Vector2:
	var board: Array[CardInstance] = player_board if player_owned else enemy_board
	var index := board.find(unit)
	var count := board.size()
	var card_width := CardView.CARD_SIZE.x
	var gap := 14.0
	if count > 6:
		gap = -minf(40.0, float(count - 6) * 16.0)
	var step := card_width + gap
	var total := card_width + step * float(count - 1)
	var start_x := (_width() - total) * 0.5
	var row_y := _player_row_y() if player_owned else 92.0
	return Vector2(start_x + step * float(index), row_y)


func _place_attacking_view(unit: CardInstance, player_owned: bool, index: int) -> void:
	var view := _view_for(unit)
	if view == null:
		return
	var count := combat_attackers.size()
	var spacing := CardView.CARD_SIZE.x + 14.0
	var total := CardView.CARD_SIZE.x + spacing * float(count - 1)
	var start_x := (_width() - total) * 0.5
	var x := start_x + spacing * float(index)
	if player_owned:
		view.move_to(Vector2(x, board_table.combat_center_y() - CardView.CARD_SIZE.y * 0.5))
	else:
		view.move_to(Vector2(x, board_table.combat_center_y() - CardView.CARD_SIZE.y - 12.0))


func _place_blocking_view(unit: CardInstance, attacker_index: int) -> void:
	var view := _view_for(unit)
	if view == null or combat_attackers.is_empty():
		return
	var spacing := CardView.CARD_SIZE.x + 14.0
	var total := CardView.CARD_SIZE.x + spacing * float(combat_attackers.size() - 1)
	var start_x := (_width() - total) * 0.5
	view.move_to(Vector2(
		start_x + spacing * float(attacker_index),
		board_table.combat_center_y() + 8.0
	))


func _is_in_combat(unit: CardInstance) -> bool:
	if combat_attackers.has(unit) or combat_blockers.values().has(unit):
		return true
	return false


func _on_end_turn() -> void:
	if busy or awaiting_choice or game_over or not player_turn:
		return
	busy = true
	player_turn = false
	mode = ""
	selected = null
	_refresh_all()
	await _enemy_turn()
	if not game_over:
		await _resolve_round_end()
	if not game_over:
		_start_round()
	busy = false
	if not game_over:
		_refresh_all()


func _enemy_turn() -> void:
	_log("Enemy turn.")
	while enemy_board.size() < MAX_BOARD:
		var card := _best_enemy_play()
		if card == null:
			break
		await _enemy_play(card)
	_enemy_prepare()
	_refresh_units()
	if player_has_attack_token:
		_log("The enemy does not have the Attack Token.")
		return
	var attackers := _eligible_attackers(enemy_board)
	if attackers.is_empty():
		_log("The enemy has no ready attackers.")
		return
	combat_attackers = attackers
	combat_blockers.clear()
	blockers_used.clear()
	selected_combat_attacker = null
	for index in attackers.size():
		_place_attacking_view(attackers[index], false, index)
	mode = "block"
	_log("Enemy attack declared. Select an attacker, then a blocker for it.")
	_refresh_all()
	await blocks_confirmed
	mode = ""
	await _resolve_attack_group(attackers, combat_blockers, false)
	combat_attackers.clear()
	combat_blockers.clear()
	selected_combat_attacker = null
	if not game_over:
		_refresh_all()


func _best_enemy_play() -> CardInstance:
	var best: CardInstance = null
	for card in enemy_hand:
		if card.definition.gold_cost > enemy_gold:
			continue
		if best == null or card.definition.gold_cost > best.definition.gold_cost:
			best = card
	return best


func _enemy_play(card: CardInstance) -> void:
	enemy_gold -= card.definition.gold_cost
	enemy_hand.erase(card)
	if card.definition.ability_choice_required:
		card.choose_ability("ally_attack_heal")
	card.attacks_left = 1
	enemy_board.append(card)
	var view := _create_view(card, false, "board")
	enemy_views.append(view)
	board_root.add_child(view)
	view.position = Vector2(_width() * 0.5, 24.0)
	_log("Enemy played %s." % card.definition.card_name)
	_layout()
	_refresh_hud()
	await get_tree().create_timer(0.35).timeout


func _enemy_prepare() -> void:
	for unit in enemy_board:
		if unit.health <= 0 or unit.ability_used:
			continue
		if unit.definition.has_keyword("shapeshift") and unit.current_form_id.is_empty():
			var form_id := "elf_form_bear" if unit.health <= 2 else "elf_form_wolf"
			if unit.shapeshift(form_id):
				unit.ability_used = true
				_log("Enemy shapeshifted into %s." % unit.current_definition().card_name)
	for unit in enemy_board:
		if unit.definition.card_id != "orc_shaman" or unit.ability_used or unit.health <= 0:
			continue
		var victim: CardInstance = null
		for ally in enemy_board:
			if ally == unit or ally.health <= 1:
				continue
			if victim == null or ally.health < victim.health:
				victim = ally
		if victim != null:
			_drain(unit, victim, enemy_board)


func _select_attacker_to_block(view: CardView) -> void:
	if not combat_attackers.has(view.instance):
		return
	selected_combat_attacker = view.instance
	_refresh_all()


func _assign_blocker(view: CardView) -> void:
	if selected_combat_attacker == null:
		_log("Select an attacking unit first.")
		return
	var blocker := view.instance
	if blocker.health <= 0 or not player_board.has(blocker) or blocker.attacks_left <= 0:
		return
	if not combat_attackers.has(selected_combat_attacker):
		return
	if blockers_used.has(blocker):
		_log("%s is already blocking another attacker." % blocker.current_definition().card_name)
		return
	if combat_blockers.has(selected_combat_attacker):
		var previous: CardInstance = combat_blockers[selected_combat_attacker]
		blockers_used.erase(previous)
		var previous_view := _view_for(previous)
		if previous_view != null:
			previous_view.move_to(_bench_position(previous, true))
	blockers_used.append(blocker)
	combat_blockers[selected_combat_attacker] = blocker
	var attacker_index := combat_attackers.find(selected_combat_attacker)
	_place_blocking_view(blocker, attacker_index)
	_refresh_all()


func _remove_blocker(blocker: CardInstance) -> void:
	var assigned_attacker: CardInstance = null
	for attacker in combat_blockers:
		if combat_blockers[attacker] == blocker:
			assigned_attacker = attacker
			break
	if assigned_attacker != null:
		combat_blockers.erase(assigned_attacker)
		blockers_used.erase(blocker)
	_layout()
	_refresh_all()


func _confirm_blocks() -> void:
	if mode == "block":
		blocks_confirmed.emit()


func _resolve_round_end() -> void:
	var bodies := deaths_this_round
	deaths_this_round = 0
	if bodies <= 0:
		return
	bodies = await _mages_attack(true, bodies)
	if game_over:
		return
	await _mages_attack(false, bodies)


func _mages_attack(player_side: bool, bodies: int) -> int:
	var board: Array[CardInstance] = player_board if player_side else enemy_board
	var mages: Array[CardInstance] = []
	for unit in board:
		if unit.definition.card_id == "undead_mage" and unit.health > 0 and not unit.silenced:
			mages.append(unit)
	for mage in mages:
		if bodies <= 0 or game_over or mage.health <= 0:
			break
		var skeleton := _spawn("undead_skeleton", player_side)
		if skeleton == null:
			continue
		bodies -= 1
		_log("Undead Mage raises a Skeleton.")
		await _resolve_combat(skeleton, null, player_side)
	return bodies


func _start_round() -> void:
	round_number += 1
	player_has_attack_token = not player_has_attack_token
	player_attack_declared = false
	player_gold = mini(GOLD_CAP, player_gold + GOLD_PER_ROUND)
	enemy_gold = mini(GOLD_CAP, enemy_gold + GOLD_PER_ROUND)
	draw_card(true)
	draw_card(false)
	for unit in player_board:
		_ready_unit(unit)
	for unit in enemy_board:
		_ready_unit(unit)
	player_turn = true
	mode = ""
	selected = null
	_log("Round %d. %s has the Attack Token. Both sides gain %d gold." % [
		round_number,
		"You" if player_has_attack_token else "Enemy",
		GOLD_PER_ROUND,
	])


func _ready_unit(unit: CardInstance) -> void:
	unit.attacks_left = 1
	unit.ability_used = false
	unit.silenced = false


func _resolve_combat(attacker: CardInstance, defender: CardInstance, attacker_is_player: bool) -> void:
	if attacker == null or attacker.health <= 0 or attacker.attacks_left <= 0:
		return
	if defender != null and defender.health <= 0:
		return
	attacker.attacks_left = 0
	_grant_attack_health(attacker, attacker_is_player)
	var strikes := 2 if attacker.has_active_keyword("high_attack_speed") or attacker.has_active_keyword("swift_attack") else 1
	var attacker_view := _view_for(attacker)
	if attacker_view != null:
		var combat_x := _width() * 0.5 - CardView.CARD_SIZE.x * 0.5
		if defender != null:
			combat_x -= CardView.CARD_SIZE.x * 0.5 + 6.0
		var combat_position := Vector2(
			combat_x,
			board_table.combat_center_y() - CardView.CARD_SIZE.y * 0.5
		)
		var move_tween: Tween = attacker_view.move_to(combat_position)
		await move_tween.finished
	if defender != null:
		var defender_view := _view_for(defender)
		if defender_view != null:
			var defender_position := Vector2(
				_width() * 0.5 + 6.0,
				board_table.combat_center_y() - CardView.CARD_SIZE.y * 0.5
			)
			var defender_tween: Tween = defender_view.move_to(defender_position)
			await defender_tween.finished
	for _strike in strikes:
		if attacker.health <= 0:
			break
		if defender != null and defender.health <= 0:
			break
		if attacker_view != null:
			var aim := enemy_nexus_button.position if defender == null else Vector2.ZERO
			if defender != null:
				var defender_view := _view_for(defender)
				if defender_view == null:
					break
				aim = defender_view.position
			elif not attacker_is_player:
				aim = player_nexus_label.position
			await attacker_view.lunge_toward(aim)
		if defender == null:
			var hit := attacker.current_damage()
			if attacker_is_player:
				enemy_nexus = maxi(0, enemy_nexus - hit)
				_popup(enemy_nexus_button.position, "-%d" % hit, Color("ffb4a8"))
			else:
				player_nexus = maxi(0, player_nexus - hit)
				_popup(player_nexus_label.position, "-%d" % hit, Color("ffb4a8"))
			if attacker.has_active_keyword("steal_gold"):
				_steal_gold(hit, attacker_is_player)
		else:
			var attacker_was_alive := attacker.health > 0
			var defender_was_alive := defender.health > 0
			var attacker_strike_damage := attacker.current_damage()
			var defender_strike_damage := defender.current_damage()
			var dealt := _apply_damage(defender, attacker_strike_damage, attacker)
			_popup_on_unit(defender, "-%d" % dealt, Color("ffb4a8"))
			if attacker.has_active_keyword("steal_gold"):
				_steal_gold(dealt, attacker_is_player)
			if attacker_was_alive and defender_was_alive:
				var counter := _apply_damage(attacker, defender_strike_damage, defender)
				_popup_on_unit(attacker, "-%d" % counter, Color("ffb4a8"))
		_refresh_units()
		_refresh_hud()
		if _check_winner():
			_remove_dead(true)
			_remove_dead(false)
			_layout()
			return
		await get_tree().create_timer(0.05).timeout
	_remove_dead(true)
	_remove_dead(false)
	_layout()


func _grant_attack_health(attacker: CardInstance, attacker_is_player: bool) -> void:
	var allies: Array[CardInstance] = player_board if attacker_is_player else enemy_board
	for ally in allies:
		if ally.health > 0 and ally.chosen_ability_id == "ally_attack_heal":
			attacker.gain_health(2)


func _apply_damage(target: CardInstance, raw_amount: int, striker: CardInstance) -> int:
	if target == null or target.health <= 0 or raw_amount <= 0:
		return 0
	var dealt := raw_amount
	if target.has_active_keyword("tough"):
		dealt = maxi(raw_amount - 1, 0)
	target.health -= dealt
	if dealt > 0 and target.health > 0 and target.has_active_keyword("fury"):
		target.apply_fury()
		_log("%s gains Fury." % target.current_definition().card_name)
	if dealt > 0 and target.has_active_keyword("acidic_blood") and striker != null and not _in_acid:
		_in_acid = true
		var splash := _apply_damage(striker, 2, null)
		_popup_on_unit(striker, "-%d" % splash, Color("b6e36a"))
		_in_acid = false
	if target.health <= 0 and target.revives_remaining > 0 and not target.silenced:
		target.revives_remaining = 0
		target.health = target.definition.health
		target.max_health = target.definition.health
		target.fury_bonus = 0
		_log("%s revived." % target.definition.card_name)
	return dealt


func _steal_gold(amount: int, thief_is_player: bool) -> void:
	if amount <= 0:
		return
	var taken := 0
	if thief_is_player:
		taken = mini(amount, enemy_gold)
		enemy_gold -= taken
		player_gold = mini(GOLD_CAP, player_gold + taken)
	else:
		taken = mini(amount, player_gold)
		player_gold -= taken
		enemy_gold = mini(GOLD_CAP, enemy_gold + taken)
	if taken > 0:
		_log("Stole %d gold." % taken)


func _remove_dead(player_side: bool) -> void:
	var board: Array[CardInstance] = player_board if player_side else enemy_board
	var views: Array[CardView] = player_views if player_side else enemy_views
	var riders := 0
	var index := board.size() - 1
	while index >= 0:
		var unit := board[index]
		if unit.health <= 0:
			if unit.definition.card_id == "elf_mount":
				riders += 1
			deaths_this_round += 1
			_log("%s died." % unit.current_definition().card_name)
			if selected != null and selected.instance == unit:
				selected = null
				mode = ""
			views[index].queue_free()
			views.remove_at(index)
			board.remove_at(index)
		index -= 1
	for _rider in riders:
		_spawn("elf_rider", player_side)


func _spawn(card_id: String, player_side: bool) -> CardInstance:
	var board: Array[CardInstance] = player_board if player_side else enemy_board
	if board.size() >= MAX_BOARD:
		_log("No room to spawn.")
		return null
	var card := CardDatabase.create_instance(card_id)
	if card == null:
		return null
	card.attacks_left = 1
	var view := _create_view(card, player_side, "board")
	board.append(card)
	var views: Array[CardView] = player_views if player_side else enemy_views
	views.append(view)
	board_root.add_child(view)
	view.position = Vector2(_width() * 0.5, 300.0)
	_layout()
	return card


func _check_winner() -> bool:
	if game_over:
		return true
	if player_nexus <= 0 and enemy_nexus <= 0:
		_show_result("Draw")
		return true
	if enemy_nexus <= 0:
		_show_result("You win")
		return true
	if player_nexus <= 0:
		_show_result("You lose")
		return true
	return false


func _show_result(title: String) -> void:
	game_over = true
	player_turn = false
	var layer := Control.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.z_index = 40
	board_root.get_parent().add_child(layer)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.7)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dim)
	var label := _make_hud_label(layer, 48)
	label.text = title
	label.position = Vector2(_width() * 0.5 - 140, _height() * 0.5 - 80)
	var again := Button.new()
	again.text = "Play again"
	again.position = Vector2(_width() * 0.5 - 70, _height() * 0.5)
	again.size = Vector2(160, 48)
	again.pressed.connect(func() -> void: get_tree().reload_current_scene())
	layer.add_child(again)


func _refresh_all() -> void:
	_layout()
	_refresh_hud()
	_refresh_units()
	_refresh_actions()


func _refresh_hud() -> void:
	enemy_nexus_button.text = "Enemy nexus  %d" % enemy_nexus
	player_nexus_label.text = "Your nexus  %d" % player_nexus
	gold_bar.configure(player_gold, GOLD_CAP)
	info_label.text = "Round %d     Enemy: %s     Gold %d     Hand %d     Deck %d" % [
		round_number,
		_faction_name(enemy_faction),
		enemy_gold,
		enemy_hand.size(),
		enemy_deck.size(),
	]
	deck_label.text = "DECK\n%d" % player_deck.size()
	attack_token_label.text = "ATTACK TOKEN\n%s" % (
		"YOURS" if player_has_attack_token else "ENEMY"
	)
	attack_token_label.add_theme_color_override("font_color", (
		Color("f0d48a") if player_has_attack_token else Color("c58b84")
	))
	oracle_button.disabled = selected == null or busy or not player_turn
	end_button.disabled = busy or awaiting_choice or game_over or not player_turn
	var aiming := mode == "declare_attack" and not combat_attackers.is_empty()
	enemy_nexus_button.modulate = Color("ffd0c4") if aiming else Color.WHITE


func _refresh_units() -> void:
	for view in _every_view():
		if not is_instance_valid(view):
			continue
		view.selected = view == selected or view.instance == selected_combat_attacker
		view.refresh()
		if view.zone == "hand":
			var affordable := player_gold >= view.instance.definition.gold_cost and player_board.size() < MAX_BOARD
			if not affordable:
				view.modulate = Color(0.45, 0.45, 0.45)
		elif mode == "block" and view.owner_player and blockers_used.has(view.instance):
			view.modulate = Color(0.45, 0.45, 0.45)

func _refresh_actions() -> void:
	_clear_box(action_row)
	action_row.position = Vector2(24, _player_row_y() + CardView.CARD_SIZE.y + 8)
	if mode == "declare_attack":
		_add_action("Confirm Attack", _confirm_attack)
		_add_action("Cancel", _cancel_attack)
		return
	if mode == "block" and not player_turn:
		_add_action("Resolve Combat", _confirm_blocks)
		return
	if selected == null or not player_turn or busy or game_over:
		return
	var unit := selected.instance
	if unit.health <= 0:
		return
	if (
		not _eligible_attackers(player_board).is_empty()
		and player_has_attack_token
		and not player_attack_declared
	):
		_add_action("Attack", _begin_attack)
	if unit.definition.has_keyword("shapeshift") and not unit.ability_used:
		_add_action("Bear", _cast_shapeshift.bind("elf_form_bear"))
		_add_action("Wolf", _cast_shapeshift.bind("elf_form_wolf"))
		_add_action("Raven", _cast_shapeshift.bind("elf_form_raven"))
	if unit.definition.card_id == "elf_ranger" and not unit.ability_used and player_board.size() > 1:
		_add_action("Switch", _begin_switch)
	if unit.definition.card_id == "orc_shaman" and not unit.ability_used and player_board.size() > 1:
		_add_action("Drain", _begin_drain)
	if unit.chosen_ability_id == "full_heal_one" and not unit.ability_used:
		_add_action("Full Heal", _begin_heal)


func _add_action(title: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(110, 36)
	button.pressed.connect(callback)
	action_row.add_child(button)


func _layout() -> void:
	_place_bench_views(enemy_views, 92.0)
	_place_bench_views(player_views, _player_row_y())
	_place(player_hand_views, _hand_y())
	_refresh_board_table()
	var width := _width()
	enemy_nexus_button.position = Vector2(width * 0.5 - 180.0, 12.0)
	enemy_nexus_button.size = Vector2(360, 44)
	end_button.position = Vector2(width - 190.0, 12.0)
	end_button.size = Vector2(160, 44)
	info_label.position = Vector2(24, 14)
	info_label.size = Vector2(520, 30)
	player_nexus_label.position = Vector2(24, 48)
	player_nexus_label.size = Vector2(240, 40)
	gold_bar.position = Vector2(width - 286.0, 68.0)
	gold_bar.size = Vector2(260.0, 74.0)
	attack_token_panel.position = Vector2(width - 220.0, 158.0)
	attack_token_panel.size = Vector2(180.0, 50.0)
	oracle_button.position = Vector2(34.0, board_table.combat_center_y() - 24.0)
	oracle_button.size = Vector2(132.0, 48.0)
	deck_panel.position = Vector2(36.0, _hand_y() + 26.0)
	deck_panel.size = Vector2(96.0, 132.0)
	status_label.position = Vector2(36.0, 274.0)
	status_label.size = Vector2(300, 120)
	if action_row != null:
		action_row.position = Vector2(24, _player_row_y() + CardView.CARD_SIZE.y + 8)


func _refresh_board_table() -> void:
	board_table.configure(
		_player_row_y(),
		enemy_views.size(),
		player_views.size(),
		mode,
		_faction_name(enemy_faction),
		combat_preview
	)


func _place(views: Array[CardView], row_y: float) -> void:
	var count := views.size()
	if count == 0:
		return
	var card_w := CardView.CARD_SIZE.x
	var gap := 14.0
	if count > 6:
		gap = -minf(40.0, float(count - 6) * 16.0)
	var step := card_w + gap
	var total := card_w + step * float(count - 1)
	var start_x := (_width() - total) * 0.5
	for i in count:
		if not is_instance_valid(views[i]):
			continue
		if _is_in_combat(views[i].instance):
			continue
		views[i].move_to(Vector2(start_x + step * float(i), row_y))


func _place_bench_views(views: Array[CardView], row_y: float) -> void:
	_place(views, row_y)


func _popup_on_unit(unit: CardInstance, text: String, color: Color) -> void:
	var view := _view_for(unit)
	if view == null:
		return
	_popup(view.position, text, color)


func _popup(origin: Vector2, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = origin + Vector2(36, 8)
	label.z_index = 25
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	board_root.add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 32.0, 0.4)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.4)
	tween.finished.connect(label.queue_free)


func _view_for(unit: CardInstance) -> CardView:
	var index := player_board.find(unit)
	if index >= 0:
		return player_views[index]
	index = enemy_board.find(unit)
	if index >= 0:
		return enemy_views[index]
	return null


func _every_view() -> Array[CardView]:
	var views: Array[CardView] = []
	views.append_array(player_hand_views)
	views.append_array(player_views)
	views.append_array(enemy_views)
	return views


func _clear_dead_selection() -> void:
	if selected == null:
		return
	if not is_instance_valid(selected) or selected.instance.health <= 0 or not player_board.has(selected.instance):
		selected = null
		mode = ""


func _clear_box(box: Node) -> void:
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()


func _log(message: String) -> void:
	_log_lines.append(message)
	if _log_lines.size() > 4:
		_log_lines.remove_at(0)
	if status_label == null:
		return
	var text := ""
	for line in _log_lines:
		text += line + "\n"
	status_label.text = text


func _width() -> float:
	return get_viewport_rect().size.x


func _height() -> float:
	return get_viewport_rect().size.y


func _hand_y() -> float:
	return _height() - CardView.CARD_SIZE.y - 18.0


func _player_row_y() -> float:
	return _hand_y() - CardView.CARD_SIZE.y - 64.0
