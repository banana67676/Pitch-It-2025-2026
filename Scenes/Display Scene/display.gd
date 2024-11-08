extends Node

const PitchCardData = preload("res://Card/Pitch/pitch_card_data.gd")
const Drawing = preload("res://Drawing/drawing.gd")
var output : Drawing
@onready var prod_name: Label = $CardInfo/ProdName
@onready var slogan: Label = $CardInfo/Slogan

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	output = Drawing.new()
	output.enabled = false
	output.visible = false
	add_child(output)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer", "reliable")
func display(card: PitchCardData):
	output.set_image(card.logo)
	prod_name.text=card.title
	slogan.text=card.slogan
	pass
