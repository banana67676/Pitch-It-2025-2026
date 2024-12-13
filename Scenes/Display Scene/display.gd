extends Node

const PitchCardData = preload("res://Card/Pitch/pitch_card_data.gd")
const Drawing = preload("res://Drawing/drawing.gd")
var output : Sprite2D
@onready var prod_name: Label = $DisplayScene/VBoxContainer/ProdName
@onready var slogan: Label = $DisplayScene/VBoxContainer/Slogan

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	output = Sprite2D.new()
	var canvas_fill = PackedByteArray()
	canvas_fill.resize(Drawing.WIDTH * Drawing.HEIGHT * 4)
	self.repeat_fill(canvas_fill, PackedByteArray([0, 0, 0, 0]))
	var image = Image.create_from_data(Drawing.WIDTH, Drawing.HEIGHT, false, Image.FORMAT_RGBA8, canvas_fill)
	output.texture = ImageTexture.create_from_image(image)
	output.visible = false
	output.global_position = Vector2(1152/2,400)
	output.scale = Vector2(0.7,0.7)
	add_child(output)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.is_server():
		$TimeLabel.text = str("Time remaining: ",round(MultiplayerManager.get_time_left()))
	pass

@rpc("any_peer", "call_local", "reliable")
func display_card(card_serialized: Dictionary):
	var card = PitchCardData.deserialize(card_serialized)
	output.texture.update(card.logo)
	prod_name.text=card.title
	slogan.text=card.slogan
	output.visible = true
	pass

func repeat_fill(array: PackedByteArray, suppliant: PackedByteArray) -> void:
	for i in range(array.size()):
		array.set(i, suppliant[i % suppliant.size()])
