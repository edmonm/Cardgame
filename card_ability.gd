class_name CardAbility
extends Resource

enum Trigger {
	PASSIVE,
	ON_ALLY_ATTACK,
	ON_TAKE_DAMAGE,
	ON_DEAL_DAMAGE,
	LAST_BREATH,
	ROUND_END,
	ACTIVATED,
}

@export var ability_id: String = ""
@export var trigger: Trigger = Trigger.PASSIVE
@export var text: String = ""
@export var params: Dictionary = {}
@export var choice_group: String = ""


static func from_document(document: Dictionary) -> CardAbility:
	var ability := CardAbility.new()
	ability.ability_id = str(document.get("id", ""))
	ability.trigger = _trigger_from_id(str(document.get("trigger", "passive")))
	ability.text = str(document.get("text", ""))
	var raw_params: Variant = document.get("params", {})
	ability.params = raw_params if raw_params is Dictionary else {}
	ability.choice_group = str(document.get("choice_group", ""))
	return ability


static func _trigger_from_id(trigger_id: String) -> Trigger:
	match trigger_id:
		"on_ally_attack":
			return Trigger.ON_ALLY_ATTACK
		"on_take_damage":
			return Trigger.ON_TAKE_DAMAGE
		"on_deal_damage":
			return Trigger.ON_DEAL_DAMAGE
		"last_breath":
			return Trigger.LAST_BREATH
		"round_end":
			return Trigger.ROUND_END
		"activated":
			return Trigger.ACTIVATED
		_:
			return Trigger.PASSIVE
