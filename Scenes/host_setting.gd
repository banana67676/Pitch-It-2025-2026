# host_setting.gd
extends Control # Or whatever your root node is (e.g., Node2D)

# UI Element References - CHECK THESE NAMES!
@onready var lobby_name_input = $VBoxContainer/LobbyNameInput as LineEdit
@onready var max_players_input = $VBoxContainer/MaxPlayersSpinBox as SpinBox
@onready var creation_time_input = $VBoxContainer/CreationTimeSpinBox as SpinBox
@onready var voting_time_input = $VBoxContainer/VotingTimeSpinBox as SpinBox
@onready var create_button = $VBoxContainer/CreateButton as Button

# We assume the host's username was stored globally in MultiplayerManager.
var host_username: String = MultiplayerManager.username 

# Since we removed the port input, we'll use a constant default port.
const DEFAULT_PORT = 51337


func _ready():
	# Connect the Create Button's 'pressed' signal
	create_button.pressed.connect(_on_create_button_pressed)
	
	# Set reasonable default values for the SpinBoxes
	max_players_input.value = 4
	creation_time_input.value = 60
	voting_time_input.value = 45




func _on_create_button_pressed() async:
	# ... (validation code omitted) ...

	# 2. Call the new server initialization function (FIXED LINE BELOW)
	var success = **await** MultiplayerManager.init_server_with_settings(DEFAULT_PORT, host_username, game_settings) 
	
	if not success:
		print("Error: Failed to start server.")

	# 2. Call the new server initialization function
	var success = MultiplayerManager.init_server_with_settings(DEFAULT_PORT, host_username, game_settings) 
	
	if not success:
		print("Error: Failed to start server.") # Print to console
	# If successful, the MultiplayerManager handles the scene change to the Lobby.
