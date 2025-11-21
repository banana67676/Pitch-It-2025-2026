extends Node2D

@onready var SERVER_PORT_READ: LineEdit = %Port
@onready var USERNAME_READ: LineEdit = %Username
@onready var ERROR_LABEL: Label = %ErrorText

@onready var player_scene = preload("res://Scenes/Multiplayer Menu/Player.tscn")




#returns true if the player has inputted a username and port to host/join a lobby
func _check_textbox_conditions(host_or_join: String) -> bool:
	#host_or_join is a variable that changes depending on if the player clicked the Host or Join buttons
	var username: String = USERNAME_READ.text.strip_edges() #grabs the username text
	var port: String = SERVER_PORT_READ.text.strip_edges() #grabs the port text
	
	# Check 1: Username is mandatory for both hosting and joining
	if username.is_empty():
		ERROR_LABEL.text = "You need a Username to " + host_or_join + "!"
		return false
	
	# Check 2: Port is only mandatory if the player is trying to JOIN
	if host_or_join == "join" and port.is_empty():
		ERROR_LABEL.text = "You need a Port to join!"
		return false
		
	# If hosting, we passed Check 1 (username is present).
	# If joining, we passed Check 1 and Check 2 (username and port are present).
	return true


func _on_host_pressed() -> void:
	var success = _check_textbox_conditions("host")
	if success:
		var username: String = USERNAME_READ.text.strip_edges()
		
		# 1. Store the username for the next scene to use
		MultiplayerManager.username = username 
		
		# 2. Redirect to the host settings scene
		GameManager.change_game_state(GameManager.game_state_enum.host_settings, false)


func _on_join_pressed() -> void:
	var success = _check_textbox_conditions("join")
	if success:
		var username: String = USERNAME_READ.text.strip_edges()
		MultiplayerManager.create_new_peer()
		MultiplayerManager.join_server(SERVER_PORT_READ.text, username)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.title, false)


func _on_back_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.title, false)


func _on_settings_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.settings, false)


func _on_username_text_changed(new_text: String) -> void:
	var max_length: int = 20
	if new_text.length() > max_length:
		USERNAME_READ.text = USERNAME_READ.text.substr(0,max_length)
		USERNAME_READ.set_caret_column(max_length)
