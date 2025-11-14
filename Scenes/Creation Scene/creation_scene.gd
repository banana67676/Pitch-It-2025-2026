extends Node2D

const WIDTH = 800
const HEIGHT = 600


@onready var who: CharacterBody2D = $Who
@onready var what: CharacterBody2D = $What


var moving_cards_flag : bool = false
var is_done: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	_set_done_players(0, MultiplayerManager.players.size()) #set the label for the numbers of done players to 0 out of total (0/total)
	await get_tree().create_timer(.5).timeout #wait 0.5 seconds
	moving_cards_flag = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if moving_cards_flag:
		who.move(Vector2(880,220), PI/32)
		what.move(Vector2(830,420), -PI/32)


@rpc("any_peer", "call_local", "reliable") # Authority should be able to request this
func export_card():
	print("Called by:")
	print(multiplayer.get_unique_id())
	print()
	var data = PitchCardData.new()
	data.title = %Title.text
	data.slogan = %Slogan.text
	data.logo = %DrawingScene.image
	data.user_id = multiplayer.get_unique_id()
	data.username = MultiplayerManager.username
	data.who_card = $Who.find_child("Text").text
	data.what_card = $What.find_child("Text").text
	%DrawingScene.enabled = false
	var sData = data.serialize()
	#print(MultiplayerManager.username + "sent")
	MultiplayerManager.import_card.rpc_id(1,sData)

#when the done button is pressed
func _on_done_button_pressed() -> void:
	if not is_done:
		is_done = true
		%DoneButton.disabled = true
		done_button.rpc() #call the rpc function to replicate effects for all peers

#the effects of pressing the done button that need to be replicated for all peers
@rpc("any_peer", "call_local", "reliable")
func done_button():
	var num_players = MultiplayerManager.players.size()
	MultiplayerManager.done_players += 1
	_set_done_players(MultiplayerManager.done_players, num_players)

#function to set the label showing how many players are done
func _set_done_players(done_players: int, total_players: int):
	%DonePlayers.text = str(done_players) + "/" + str(total_players) #the formatting for done players
	if done_players == total_players: #if everyone has finished
		MultiplayerManager.paused = true #pause the timer
		MultiplayerManager.start(.1) #start the timer with .1 seconds left
		MultiplayerManager.paused = false #unpause the timer
		MultiplayerManager.done_players = 0


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.quit_game(true)
