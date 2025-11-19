extends Node

#preloads
const MM = preload("res://Singletons/Multiplayer_Manager.gd")
const theme = preload("res://Assets/Font.tres")

#node references
@onready var player_list: GridContainer = %PlayerList
@onready var player_name_template: PanelContainer = $PlayerNameTemplate

#signals
signal lobby_ready

#values
var player_count : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		lobby_ready.emit()
	else:
		%Begin.visible = false


func show_player(id):
	var player_box = player_name_template.duplicate()
	var player_name = player_box.get_node("Padding/Name") #the actual label for the player
	player_name.text = MultiplayerManager.players[id].username #the text equals their chosen username
	player_list.add_child(player_box) #adds the child to the node displaying the list
	player_box.visible = true #making the label visible
	player_count += 1 #increase player count


func reset_player_data():
	for player in %PlayerList.get_children():
		#remove_child(player)
		player.queue_free()
	player_count = 0
	#player is the key (their user id)
	for player in MultiplayerManager.players:
		var player_box = player_name_template.duplicate()
		player_box.name = str(player) #make the label name their player id as a string
		var player_name = player_box.get_node("Padding/Name") #the actual label for the player
		player_name.text = MultiplayerManager.players[player].username #the text equals their chosen username
		player_list.add_child(player_box) #adds the child to the node displaying the list
		player_box.visible = true #making the label visible
		player_count += 1 #increase player count


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, true)


func _on_begin_pressed() -> void:
	MultiplayerManager.run_game_loop()


func _on_back_button_pressed() -> void:
	MultiplayerManager.disconnect_from_server()
