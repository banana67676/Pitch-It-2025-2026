extends Node

const PitchCardData = preload("res://Card/Pitch/pitch_card_data.gd")
const Drawing = preload("res://Drawing/drawing.gd")
var output : Sprite2D
@onready var prod_name: Label = %Product
@onready var slogan: Label = %Slogan
@onready var player_name: Label = %PlayerName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	output = Sprite2D.new()
	output.centered = false
	var canvas_fill = PackedByteArray()
	canvas_fill.resize(Drawing.WIDTH * Drawing.HEIGHT * 4)
	self.repeat_fill(canvas_fill, PackedByteArray([0, 0, 0, 0]))
	var image = Image.create_from_data(Drawing.WIDTH, Drawing.HEIGHT, false, Image.FORMAT_RGBA8, canvas_fill)
	output.texture = ImageTexture.create_from_image(image)
	output.visible = false
	output.global_position = Vector2(478, 82) #where the drawing is put on the screen
	output.scale = Vector2(0.807, 0.807) #scale the drawing appropriately to fit the frame
	add_child(output)

#function to display the card (this function is called on connected peer)
@rpc("any_peer", "call_local", "reliable")
func display_card(card_serialized: Dictionary):
	var card = PitchCardData.deserialize(card_serialized)
	output.texture.update(card.logo)
	prod_name.text = card.title #display the product name
	slogan.text = card.slogan #display the slogan
	player_name.text = card.username #display the player's username who made the product
	$Who.find_child("Text").text = card.who_card #change the text to show the "Who" card the player got
	$What.find_child("Text").text = card.what_card #change the text to show the "What" card the player got
	output.visible = true

func repeat_fill(array: PackedByteArray, suppliant: PackedByteArray) -> void:
	for i in range(array.size()):
		array.set(i, suppliant[i % suppliant.size()])
