extends Node2D

@export var flavor_text : String
@export var icon : Texture2D
@export_enum("Top Left", "Top Right", "Bottom Left", "Bottem Right") var location : int

@onready var label: Label = $PanelContainer/MarginContainer/Label
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	label.text = flavor_text
	sprite.texture = icon
	match location:
		"Top Left": 
			sprite.position = Vector2(-100,-100)
		"Top Right": 
			sprite.position = Vector2(100,-100)
		"Bottom Left": 
			sprite.position = Vector2(-100,100)
		"Bottom Right": 
			sprite.position = Vector2(100,100)
