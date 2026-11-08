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

const MAX_BOARD := 6
const MAX_HAND := 10
const STARTING_GOLD := 3
const GOLD_PER_ROUND := 2
const GOLD_CAP := 10
const NEXUS_HEALTH := 20
const OPENING_HAND := 4

signal choice_made(ability_id: String)

var player_deck: Array[CardInstance] = []
var enemy_deck: Array[CardInstance] = []
var player_hand: Array[CardInstance] = []
var enemy_hand: Array[CardInstance] = []
var player_board: Array[CardInstance] = []
var enemy_board: Array[CardInstance] = []
var player_hand_views: Array[CardView] = []
var player_views: Array[CardView] = []
var enemy_views: Array[CardView] = []

var player_gold: int = STARTING_GOLD
var enemy_gold: int = STARTING_GOLD
var player_nexus: int = NEXUS_HEALTH
var enemy_nexus: int = NEXUS_HEALTH
var round_number: int = 1
var deaths_this_round: int = 0

var player_turn: bool = true
var busy: bool = false
var awaiting_choice: bool = false
var game_over: bool = false
var mode: String = ""
var selected: CardView = null
var _in_acid: bool = false
var _log_lines: Array[String] = []

var board_root: Control
var action_row: HBoxContainer
var choice_layer: Control
var choice_box: VBoxContainer
var enemy_nexus_button: Button
var end_button: Button
var player_nexus_label: Label
var gold_label: Label
var info_label: Label
var status_label: Label


func _ready() -> void:
	_build_ui()
	player_deck = _make_deck()
	enemy_deck = _make_deck()
	for _i in OPENING_HAND:
		_draw(true)
		_draw(false)
	_log("Click a card to play it. Select your unit, then Attack.")
	_log("Round 1. You have %d gold." % player_gold)
	_refresh_all()


func _make_deck() -> Array[CardInstance]:
	var deck: Array[CardInstance] = []
	for card_id in DECK_IDS:
		var card := CardDatabase.create_instance(card_id)
		if card == null:
			push_error("Missing card: %s" % card_id)
			continue
		deck.append(card)
	deck.shuffle()
	return deck


func _draw(player_side: bool) -> void:
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

	var hud := Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)

	info_label = _make_hud_label(hud, 18)
	player_nexus_label = _make_hud_label(hud, 22)
	gold_label = _make_hud_label(hud, 22)
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
	return view


func _on_card_pressed(view: CardView) -> void:
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
	_log("Selected %s." % unit.current_definition().card_name)
	_refresh_all()


func _on_enemy_unit_pressed(view: CardView) -> void:
	if mode != "attack" or selected == null:
		return
	var attacker := selected.instance
	busy = true
	mode = ""
	await _resolve_combat(attacker, view.instance, true)
	_clear_dead_selection()
	busy = false
	if not game_over:
		_refresh_all()


func _on_enemy_nexus_pressed() -> void:
	if mode != "attack" or selected == null or busy or game_over or not player_turn:
		return
	var attacker := selected.instance
	busy = true
	mode = ""
	await _resolve_combat(attacker, null, true)
	_clear_dead_selection()
	busy = false
	if not game_over:
		_refresh_all()


func _begin_attack() -> void:
	if selected == null or selected.instance.attacks_left <= 0:
		return
	mode = "attack"
	_log("Click an enemy unit, or the enemy nexus.")
	_refresh_hud()


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
	var attackers: Array[CardInstance] = []
	for unit in enemy_board:
		attackers.append(unit)
	for unit in attackers:
		if game_over or unit.health <= 0 or unit.attacks_left <= 0 or not enemy_board.has(unit):
			continue
		await _resolve_combat(unit, _enemy_target(unit), false)
		if game_over:
			return
		await get_tree().create_timer(0.2).timeout


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


func _enemy_target(attacker: CardInstance) -> CardInstance:
	for unit in player_board:
		if unit.health <= 0:
			continue
		var to_unit := attacker.current_damage()
		if unit.has_active_keyword("tough"):
			to_unit = maxi(to_unit - 1, 0)
		var to_attacker := unit.current_damage()
		if attacker.has_active_keyword("tough"):
			to_attacker = maxi(to_attacker - 1, 0)
		if to_unit >= unit.health and to_attacker < attacker.health:
			return unit
	return null


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
	player_gold = mini(GOLD_CAP, player_gold + GOLD_PER_ROUND)
	enemy_gold = mini(GOLD_CAP, enemy_gold + GOLD_PER_ROUND)
	_draw(true)
	_draw(false)
	for unit in player_board:
		_ready_unit(unit)
	for unit in enemy_board:
		_ready_unit(unit)
	player_turn = true
	mode = ""
	selected = null
	_log("Round %d. Both sides gain %d gold." % [round_number, GOLD_PER_ROUND])


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
	for _strike in strikes:
		if attacker.health <= 0:
			break
		if defender != null and defender.health <= 0:
			break
		var attacker_view := _view_for(attacker)
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
			var dealt := _apply_damage(defender, attacker.current_damage(), attacker)
			_popup_on_unit(defender, "-%d" % dealt, Color("ffb4a8"))
			if attacker.has_active_keyword("steal_gold"):
				_steal_gold(dealt, attacker_is_player)
			if defender.health > 0 and attacker.health > 0:
				var counter := _apply_damage(attacker, defender.current_damage(), defender)
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
	gold_label.text = "Gold  %d" % player_gold
	info_label.text = "Round %d     Enemy gold %d     Enemy hand %d" % [round_number, enemy_gold, enemy_hand.size()]
	end_button.disabled = busy or awaiting_choice or game_over or not player_turn
	var aiming := mode == "attack" and selected != null
	enemy_nexus_button.modulate = Color("ffd0c4") if aiming else Color.WHITE


func _refresh_units() -> void:
	for view in _every_view():
		if not is_instance_valid(view):
			continue
		view.selected = view == selected
		view.refresh()
		if view.zone == "hand":
			var affordable := player_gold >= view.instance.definition.gold_cost and player_board.size() < MAX_BOARD
			if not affordable:
				view.modulate = Color(0.45, 0.45, 0.45)


func _refresh_actions() -> void:
	_clear_box(action_row)
	action_row.position = Vector2(24, _player_row_y() + CardView.CARD_SIZE.y + 8)
	if selected == null or not player_turn or busy or game_over:
		return
	var unit := selected.instance
	if unit.health <= 0:
		return
	if unit.attacks_left > 0:
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
	_place(enemy_views, 78.0)
	_place(player_views, _player_row_y())
	_place(player_hand_views, _hand_y())
	var width := _width()
	enemy_nexus_button.position = Vector2(width * 0.5 - 180.0, 12.0)
	enemy_nexus_button.size = Vector2(360, 44)
	end_button.position = Vector2(width - 190.0, 12.0)
	end_button.size = Vector2(160, 44)
	info_label.position = Vector2(24, 14)
	info_label.size = Vector2(520, 30)
	player_nexus_label.position = Vector2(24, 48)
	player_nexus_label.size = Vector2(240, 32)
	gold_label.position = Vector2(280, 48)
	gold_label.size = Vector2(180, 32)
	status_label.position = Vector2(width * 0.5 - 340.0, 280.0)
	status_label.size = Vector2(680, 110)
	if action_row != null:
		action_row.position = Vector2(24, _player_row_y() + CardView.CARD_SIZE.y + 8)


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
		views[i].move_to(Vector2(start_x + step * float(i), row_y))


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
