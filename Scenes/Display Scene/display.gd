extends Control


const Drawing = preload("res://Drawing/drawing.gd")
var output: Sprite2D
@onready var prod_name: Label = %Product
@onready var slogan: Label = %Slogan
@onready var player_name: Label = %PlayerName

var is_done: bool = false



func _ready() -> void:
	MultiplayerManager.done_players = 0
	_set_done_players(0, MultiplayerManager.players.size())
	GDSync.expose_func(display_card)
	GDSync.expose_func(display_done_button)
	output = Sprite2D.new()
	output.centered = false
	var canvas_fill = PackedByteArray()
	canvas_fill.resize(Drawing.WIDTH * Drawing.HEIGHT * 4)
	self.repeat_fill(canvas_fill, PackedByteArray([0, 0, 0, 0]))
	var image = Image.create_from_data(Drawing.WIDTH, Drawing.HEIGHT, false, Image.FORMAT_RGBA8, canvas_fill)
	output.texture = ImageTexture.create_from_image(image)
	output.visible = false
	output.global_position = Vector2(478, 92) #where the drawing is put on the screen
	output.scale = Vector2(0.807, 0.807) #scale the drawing appropriately to fit the frame
	add_child(output)
	reset_done_button_for_round()


@rpc("any_peer", "call_local", "reliable")
func display_done_button() -> void:
	MultiplayerManager.done_players += 1
	var total_players := MultiplayerManager.players.size()
	_set_done_players(MultiplayerManager.done_players, total_players)



#function to display the card (this function is called on connected peer)
#EVERYONE is calling this
func display_card(card_serialized: PackedByteArray):
	reset_done_button_for_round()
	var card = PitchCardData.deserialize(card_serialized)
	MultiplayerManager.cards[card.user_id] = card #update the product cards for MultiplayerManager (the data is needed later)
	output.texture.update(card.logo)
	prod_name.text = card.title #display the product name
	slogan.text = card.slogan #display the slogan
	player_name.text = card.username #display the player's username who made the product
	$WhoCard/WhoText.text = card.who_card #change the text to show the "Who" card the player got
	$WhatCard/WhatText.text = card.what_card #change the text to show the "What" card the player got
	output.visible = true


func repeat_fill(array: PackedByteArray, suppliant: PackedByteArray) -> void:
	for i in range(array.size()):
		array.set(i, suppliant[i % suppliant.size()])

func _set_done_players(done_players: int, total_players: int) -> void:
	%DonePlayers.text = "(" + str(done_players) + "/" + str(total_players) + ")" #the formatting for done players
	if done_players == total_players: #if everyone has finished
		MultiplayerManager.paused = true #pause the timer
		MultiplayerManager.start(.1) #start the timer with .1 seconds left
		MultiplayerManager.paused = false #unpause the timer
		MultiplayerManager.done_players = 0
		
		%DonePlayers.text = "(0/" + str(total_players) + ")"


func _on_done_button_pressed() -> void:
	if is_done:
		return # already pressed this round, do nothing
	is_done = true
	%DoneButton.disabled = true
	# tell EVERYONE that this player finished viewing
	GDSync.call_func_all(display_done_button)
	

func reset_done_button_for_round() -> void:
	is_done = false
	%DoneButton.disabled = false
