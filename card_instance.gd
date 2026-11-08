class_name CardInstance
extends RefCounted

var definition: CardResource
var damage: int
var health: int
var max_health: int
var fury_bonus: int = 0
var revives_remaining: int = 0
var attacks_left: int = 0
var current_form_id: String = ""
var chosen_ability_id: String = ""
var ability_used: bool = false
var silenced: bool = false


func _init(card_definition: CardResource) -> void:
	definition = card_definition
	_apply_stats(card_definition)
	if card_definition.has_keyword("revive"):
		revives_remaining = 1


func current_definition() -> CardResource:
	if current_form_id.is_empty():
		return definition
	var form: CardResource = definition.get_form(current_form_id)
	if form == null:
		return definition
	return form


func current_damage() -> int:
	return damage + fury_bonus


func has_active_keyword(keyword_id: String) -> bool:
	if silenced:
		return false
	return current_definition().has_keyword(keyword_id)


func apply_fury() -> void:
	fury_bonus += 3


func gain_health(amount: int) -> void:
	if amount <= 0:
		return
	max_health += amount
	health += amount


func full_heal() -> void:
	health = max_health


func shapeshift(form_id: String) -> bool:
	var form: CardResource = definition.get_form(form_id)
	if form == null:
		return false
	current_form_id = form_id
	fury_bonus = 0
	_apply_stats(form)
	return true


func choose_ability(ability_id: String) -> bool:
	for ability: CardAbility in definition.abilities:
		if ability.ability_id == ability_id:
			chosen_ability_id = ability_id
			return true
	return false


func _apply_stats(source: CardResource) -> void:
	damage = source.damage
	health = source.health
	max_health = source.health
