class_name CardHandManager
extends Node2D

@export var spread_radius: float = 400.0
@export var max_angle_spread: float = 30.0 # Degrees
@export var arc_height: float = 50.0
@export var card_vertical_offset: float = 200.0

func _process(_delta: float) -> void:
	update_card_positions()

func update_card_positions() -> void:
	var cards: Array[Node] = get_children()
	var card_count: int = cards.size()
	
	if card_count == 0:
		return
		
	for i in range(card_count):
		var card: Node2D = cards[i] as Node2D
		if not card:
			continue
			
		# Normalize index between -1.0 and 1.0
		var normalized_index: float = 0.0
		if card_count > 1:
			normalized_index = float(i) / float(card_count - 1) * 2.0 - 1.0
		
		# Calculate target X and Y offset based on arc parameters
		var target_x: float = normalized_index * (spread_radius / 2.0)
		var target_y: float = pow(normalized_index, 2.0) * arc_height - card_vertical_offset
		
		# Calculate rotation angle
		var target_rotation: float = normalized_index * deg_to_rad(max_angle_spread)
		
		# Smoothly interpolate position and rotation (Tween or lerp can be added later)
		card.position = Vector2(target_x, target_y)
		card.rotation = target_rotation
