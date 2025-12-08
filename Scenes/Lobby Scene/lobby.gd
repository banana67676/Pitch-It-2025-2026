extends Control

#preloads
const MM = preload("res://Singletons/Multiplayer_Manager.gd")

#node references
@onready var player_list: GridContainer = %PlayerList
@onready var player_name_template: PanelContainer = $PlayerNameTemplate


#signals
signal lobby_ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%LobbyHeader.text = MultiplayerManager.LOBBY_NAME
	if GDSync.is_host():
		lobby_ready.emit()
	else:
		%Begin.visible = false


func show_player(id):
	var player_box = player_name_template.duplicate()
	var player_name = player_box.get_node("Padding/Name") #the actual label for the player
	player_name.text = MultiplayerManager.players[id].username #the text equals their chosen username
	player_list.add_child(player_box) #adds the child to the node displaying the list
	player_box.visible = true #making the label visible


func reset_shown_players():
	for player in %PlayerList.get_children():
		#remove_child(player)
		player.queue_free()
	#player is the key (their user id)
	for player in MultiplayerManager.players:
		var player_box = player_name_template.duplicate()
		player_box.name = str(player) #make the label name their player id as a string
		var player_name = player_box.get_node("Padding/Name") #the actual label for the player
		player_name.text = MultiplayerManager.players[player].username #the text equals their chosen username
		player_list.add_child(player_box) #adds the child to the node displaying the list
		player_box.visible = true #making the label visible


func _on_begin_pressed() -> void:
	MultiplayerManager.run_game()


func _on_back_button_pressed() -> void:
	MultiplayerManager.client_left()
