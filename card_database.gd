extends Node

const CATALOG_PATH := "res://data/cards.json"

var cards_by_id: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> void:
	cards_by_id.clear()
	if not FileAccess.file_exists(CATALOG_PATH):
		push_error("Card catalog missing: %s" % CATALOG_PATH)
		return

	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not (parsed is Array):
		push_error("Card catalog is not a JSON array.")
		return

	for entry: Variant in parsed:
		if not entry is Dictionary:
			continue
		var card := CardResource.from_document(entry)
		cards_by_id[card.card_id] = card
		for form: CardResource in card.forms:
			cards_by_id[form.card_id] = form


func get_card(card_id: String) -> CardResource:
	return cards_by_id.get(card_id) as CardResource


func get_faction(faction: CardResource.Faction) -> Array[CardResource]:
	var result: Array[CardResource] = []
	for card: CardResource in cards_by_id.values():
		if card.faction == faction and card.card_type != CardResource.CardType.FORM:
			result.append(card)
	return result


func create_instance(card_id: String) -> CardInstance:
	var card := get_card(card_id)
	if card == null:
		return null
	return CardInstance.new(card)
