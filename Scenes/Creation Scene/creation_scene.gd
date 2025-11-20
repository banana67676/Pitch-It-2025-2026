extends Node2D

const WIDTH = 800
const HEIGHT = 600
var is_done: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.expose_func(done_button)
	_setup_tween()
	_set_done_players(0, MultiplayerManager.players.size()) #set the label for the numbers of done players to 0 out of total (0/total)
	await get_tree().create_timer(1).timeout #initial delay
	_play_tween()
	await get_tree().create_timer(1.5).timeout #delay before cards tween
	_play_cards_tween()


#this function grabs all of the data that the user created for their product to store and export it
#reffered to as a card in the code, but easier to think of them as "product cards"
@rpc("any_peer", "call_local", "reliable") # Authority should be able to request this
func export_card():
	print("Called by:")
	print(GDSync.get_client_id())
	print()
	var data = PitchCardData.new()
	data.title = %Title.text
	data.slogan = %Slogan.text
	data.logo = %DrawingScene.image
	data.user_id = GDSync.get_client_id()
	data.username = MultiplayerManager.username
	data.who_card = $Who.find_child("Text").text
	data.what_card = $What.find_child("Text").text
	%DrawingScene.enabled = false
	var sData = data.serialize()
	MultiplayerManager.import_card.rpc_id(1,sData)


#when the done button is pressed
func _on_done_button_pressed() -> void:
	if not is_done:
		is_done = true
		%DoneButton.disabled = true
		GDSync.call_func_all(done_button) #call the function to replicate effects for all peers


#the effects of pressing the done button that need to be replicated for all peers
@rpc("any_peer", "call_local", "reliable")
func done_button():
	var num_players = MultiplayerManager.players.size()
	MultiplayerManager.done_players += 1
	_set_done_players(MultiplayerManager.done_players, num_players)


#function to set the label showing how many players are done
func _set_done_players(done_players: int, total_players: int):
	%DonePlayers.text = "(" + str(done_players) + "/" + str(total_players) + ")" #the formatting for done players
	if done_players == total_players: #if everyone has finished
		MultiplayerManager.paused = true #pause the timer
		MultiplayerManager.start(.1) #start the timer with .1 seconds left
		MultiplayerManager.paused = false #unpause the timer
		MultiplayerManager.done_players = 0


#whenever there is an input
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"): #if the input is the "Escape" key
		GameManager.quit_game(true) #quit the game


#moves all of the nodes to their initial positions for the tweens to move them back into their original positions
func _setup_tween():
	$TypingMargin.position = Vector2(0, -200)
	%DrawingScene.position = Vector2(1200, %DrawingScene.position.y) #y-position doesn't matter for this one
	$SidebarMargin.position = Vector2(0, 200)
	$What.position = Vector2(-550, 300)
	$Who.position = Vector2(-550, 200)
	$What.rotation_degrees = 5
	$Who.rotation_degrees = -8


#plays all of the tweens, which is just just a visual of all of the nodes moving into the screen
func _play_tween():
	#the reason there are 3 different tweens is because godot doesn't allow for an easy way to delay tweens while a tween
	#is already occuring. It waits for the tween to finish before moving on.
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	var tween2 = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	var tween3 = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property($TypingMargin, "position", Vector2(0, 0), 2) #moving its position
	tween2.tween_interval(0.5) #this is the delay
	tween2.tween_property(%DrawingScene, "position", Vector2(290.4, %DrawingScene.position.y), 2) #y-position doesn't matter for this one
	tween3.tween_interval(1.0)
	tween3.tween_property($SidebarMargin, "position", Vector2(0, 0), 2)


#plays the tweens for the cards specifically, since these tweens need to be played at the same time
#and the delays used in the _play_tween() function don't work when tweens are parallel (run at the same time)
func _play_cards_tween():
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property($What, "position", Vector2(25, 210), 1.5)
	tween.tween_property($Who, "position", Vector2(25, 320), 1.5)
	tween.tween_property($What, "rotation", deg_to_rad(-5), 1.5)
	tween.tween_property($Who, "rotation", deg_to_rad(8), 1.5)
