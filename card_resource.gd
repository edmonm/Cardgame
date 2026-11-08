class_name CardResource
extends Resource

enum Faction { HUMAN, ORC, ELF, UNDEAD }
enum CardType { UNIT, TOKEN, FORM }

@export var card_id: String = ""
@export var card_name: String = ""
@export var faction: Faction = Faction.HUMAN
@export var card_type: CardType = CardType.UNIT
@export var damage: int = 0
@export var health: int = 0
## Play cost in gold. Tokens and forms stay at 0.
@export var gold_cost: int = 0
@export var keywords: PackedStringArray = PackedStringArray()
@export var abilities: Array[CardAbility] = []
@export var forms: Array[CardResource] = []
@export var ability_choice_required: bool = false
@export var rules_text: String = ""


static func from_document(document: Dictionary) -> CardResource:
	var card := CardResource.new()
	card.card_id = str(document.get("_id", ""))
	card.card_name = str(document.get("name", ""))
	card.faction = faction_from_id(str(document.get("faction", "human")))
	card.card_type = _type_from_id(str(document.get("type", "unit")))
	card.damage = int(document.get("damage", 0))
	card.health = int(document.get("health", 0))
	card.gold_cost = int(document.get("gold_cost", 0))
	card.ability_choice_required = bool(document.get("ability_choice_required", false))
	card.rules_text = str(document.get("text", ""))

	var keyword_list: Array = document.get("keywords", [])
	var packed := PackedStringArray()
	for keyword: Variant in keyword_list:
		packed.append(str(keyword))
	card.keywords = packed

	var ability_list: Array = document.get("abilities", [])
	for entry: Variant in ability_list:
		if entry is Dictionary:
			card.abilities.append(CardAbility.from_document(entry))

	var form_list: Array = document.get("forms", [])
	for entry: Variant in form_list:
		if entry is Dictionary:
			card.forms.append(CardResource.from_document(entry))
	return card


static func faction_from_id(faction_id: String) -> Faction:
	match faction_id:
		"orc":
			return Faction.ORC
		"elf":
			return Faction.ELF
		"undead":
			return Faction.UNDEAD
		_:
			return Faction.HUMAN


static func faction_to_id(faction_value: Faction) -> String:
	match faction_value:
		Faction.ORC:
			return "orc"
		Faction.ELF:
			return "elf"
		Faction.UNDEAD:
			return "undead"
		_:
			return "human"


func has_keyword(keyword_id: String) -> bool:
	return keywords.has(keyword_id)


func get_form(form_id: String) -> CardResource:
	for form: CardResource in forms:
		if form.card_id == form_id:
			return form
	return null


func to_document() -> Dictionary:
	var keyword_list: Array[String] = []
	for keyword: String in keywords:
		keyword_list.append(keyword)

	var ability_list: Array[Dictionary] = []
	for ability: CardAbility in abilities:
		ability_list.append({
			"id": ability.ability_id,
			"trigger": _trigger_to_id(ability.trigger),
			"text": ability.text,
			"params": ability.params,
			"choice_group": ability.choice_group,
		})

	var form_list: Array[Dictionary] = []
	for form: CardResource in forms:
		form_list.append(form.to_document())

	return {
		"_id": card_id,
		"name": card_name,
		"faction": faction_to_id(faction),
		"type": _type_to_id(card_type),
		"damage": damage,
		"health": health,
		"gold_cost": gold_cost,
		"keywords": keyword_list,
		"abilities": ability_list,
		"forms": form_list,
		"ability_choice_required": ability_choice_required,
		"text": rules_text,
	}


static func _type_from_id(type_id: String) -> CardType:
	match type_id:
		"token":
			return CardType.TOKEN
		"form":
			return CardType.FORM
		_:
			return CardType.UNIT


static func _type_to_id(type_value: CardType) -> String:
	match type_value:
		CardType.TOKEN:
			return "token"
		CardType.FORM:
			return "form"
		_:
			return "unit"


static func _trigger_to_id(trigger: CardAbility.Trigger) -> String:
	match trigger:
		CardAbility.Trigger.ON_ALLY_ATTACK:
			return "on_ally_attack"
		CardAbility.Trigger.ON_TAKE_DAMAGE:
			return "on_take_damage"
		CardAbility.Trigger.ON_DEAL_DAMAGE:
			return "on_deal_damage"
		CardAbility.Trigger.LAST_BREATH:
			return "last_breath"
		CardAbility.Trigger.ROUND_END:
			return "round_end"
		CardAbility.Trigger.ACTIVATED:
			return "activated"
		_:
			return "passive"
