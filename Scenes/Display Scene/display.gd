extends Node

const PitchCardData = preload("res://Card/Pitch/pitch_card_data.gd")
const Drawing = preload("res://Drawing/drawing.gd")
var output : Drawing
@onready var prod_name: Label = $DisplayScene/ProdName
@onready var slogan: Label = $DisplayScene/Slogan

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	output = Drawing.new()
	output.enabled = false
	output.visible = false
	output.global_position = Vector2(100,300)
	add_child(output)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer", "call_local", "reliable")
func display(card: PitchCardData):
	output.set_image(card.logo)
	prod_name.text=card.title
	slogan.text=card.slogan
	output.visible = true
	pass
