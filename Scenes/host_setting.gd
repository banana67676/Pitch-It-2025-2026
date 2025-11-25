extends Control

# UI Element References
@onready var lobby_name_input = $VBoxContainer/LobbyNameInput as LineEdit
@onready var max_players_input = $VBoxContainer/MaxPlayersSpinBox as SpinBox
@onready var creation_time_input = $VBoxContainer/CreationTimeSpinBox as SpinBox
@onready var voting_time_input = $VBoxContainer/VotingTimeSpinBox as SpinBox
@onready var create_button = $VBoxContainer/CreateButton as Button

var host_username: String = MultiplayerManager.username 

# Note: This is a String so .to_int() works in the manager
const DEFAULT_PORT = "51337" 

func _ready():
	# We will connect the signal via the Editor, not code
	max_players_input.value = 4
	creation_time_input.value = 60
	voting_time_input.value = 45 

# Godot needs to find this EXACT name
func _on_create_button_presse():
	print("Button Pressed!") 
	
	if lobby_name_input.text.strip_edges().is_empty():
		print("Error: Lobby Name is empty.")
		return

	var game_settings = {
		"lobby_name": lobby_name_input.text.strip_edges(),
		"max_players": int(max_players_input.value),
		"time_creation": int(creation_time_input.value),
		"time_voting": int(voting_time_input.value)
	}

	print("Attempting to start server...") 

	# 'await' is used here, but we do NOT use 'async' in the function definition
	var success = await MultiplayerManager.init_server_with_settings(DEFAULT_PORT, host_username, game_settings) 
	
	if not success:
		print("Error: Failed to start server.")
	else:
		print("Server started! Waiting for scene change...")

func _on_create_button_pressed() -> void:
	pass # Replace with function body.
