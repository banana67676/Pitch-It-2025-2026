extends Node2D

const CARD = preload("res://Card/Preset/card.tscn")

var card_spawn_pos = Vector2(1000, 150)
var hand_pos = Vector2(500, 500)
var move_time = 1

func _ready() -> void:
	pass # Add any initialization here if needed

func _on_card_pile_card_drawn() -> void:
	var card = CARD.instantiate()
	card.position = card_spawn_pos
	add_child(card)
	move_card(card, hand_pos)

func move_card(card, target_pos):
	var tween = create_tween()
	tween.tween_property(
		card, "position", target_pos,
		move_time
	)
