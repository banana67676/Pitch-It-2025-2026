extends Node

#preloads
const MM = preload("res://Singletons/Multiplayer_Manager.gd")
const theme = preload("res://Assets/Font.tres")

#node references
@onready var player_list: GridContainer = %PlayerList
@onready var player_name_template: PanelContainer = $PlayerNameTemplate
@onready var settings_popup: Control = $Overlay/Setting/SettingsPopup
@onready var lobby_name_label: Label = %LobbyNameLabel 
@onready var max_players_label: Label = %MaxPlayersLabel 

#signals
signal lobby_ready

#values
var player_count : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the visibility of the start button
	if multiplayer.is_server():
		%Begin.visible = true # Host can see the start button
		lobby_ready.emit()
	else:
		%Begin.visible = false # Clients cannot start the game
		
	settings_popup.visible = false
	
	# NEW: Display the custom lobby settings
	update_lobby_display()


func update_lobby_display():
	# Retrieve the settings dictionary
	var settings = MultiplayerManager.game_settings
	
	# 1. Set the custom lobby name
	lobby_name_label.text = settings.get("lobby_name", "Untitled Lobby")
	
	# 2. Update the max players text
	var max_players = settings.get("max_players", 4)
	max_players_label.text = "Max Players: " + str(max_players)
	
	# Note: Your player count display (e.g., 1/4) is handled inside reset_player_data.
func show_player(id):
	var player_box = player_name_template.duplicate()
	var player_name = player_box.get_node("Padding/Name") #the actual label for the player
	player_name.text = MultiplayerManager.players[id].username #the text equals their chosen username
	player_list.add_child(player_box) #adds the child to the node displaying the list
	player_box.visible = true #making the label visible
	player_count += 1 #increase player count


func reset_player_data():
	# Get the max player count from settings
	var settings = MultiplayerManager.game_settings
	var max_players = settings.get("max_players", 4) # Default to 4
	
	# Remove existing player boxes
	for player in %PlayerList.get_children():
		player.queue_free()
		
	player_count = 0
	
	# Populate the list with current players
	for player_id in MultiplayerManager.players: # Use player_id for clarity
		var player_box = player_name_template.duplicate()
		player_box.name = str(player_id) # make the label name their player id as a string
		var player_name = player_box.get_node("Padding/Name") #the actual label for the player
		player_name.text = MultiplayerManager.players[player_id].username #the text equals their chosen username
		player_list.add_child(player_box) #adds the child to the node displaying the list
		player_box.visible = true #making the label visible
		player_count += 1 #increase player count
		
	# NEW: Update the player count display (assuming you have a label for this)
	# If your player count label is max_players_label, you might want to format it here too:
	max_players_label.text = "Players: " + str(player_count) + "/" + str(max_players)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, true)


func _on_begin_pressed() -> void:
	MultiplayerManager.run_game_loop()


func _on_back_button_pressed() -> void:
	MultiplayerManager.disconnect_from_server()



func _on_game_mode_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.game_mode, false)


func _on_setting_pressed() -> void:
	settings_popup.visible = !settings_popup.visible
	pass # Replace with function body.
