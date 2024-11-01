extends Node2D

const WIDTH = 800
const HEIGHT = 600

const PitchCardData = preload("res://pitch_card_data.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("authority", "call_local", "reliable") # Authority should be able to request this
func export_card() -> PitchCardData:
	var data = PitchCardData.new()
	data.title = $MarginContainer/VSplitContainer/MarginContainer/VBoxContainer/Title.text
	data.slogan = $MarginContainer/VSplitContainer/MarginContainer/VBoxContainer/MarginContainer/Slogan.text
	data.logo = $MarginContainer/VSplitContainer/HSplitContainer/DrawingScene.image_texture
	data.creator = ""
	return data
