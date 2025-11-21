extends Node2D

@onready var SERVER_PORT_READ: LineEdit = %Port
@onready var USERNAME_READ: LineEdit = %Username
@onready var ERROR_LABEL: Label = %ErrorText

@onready var player_scene = preload("res://Scenes/Multiplayer Menu/Player.tscn")

signal back_to_title


#returns true if the player has inputted a username and port to host/join a lobby
func _check_textbox_conditions(host_or_join: String) -> bool:
	#host_or_join is a variable that changes depending on if the player clicked the Host or Join buttons
	var username: String = USERNAME_READ.text.strip_edges() #grabs the username text
	var port: String = SERVER_PORT_READ.text.strip_edges() #grabs the port text
	if username.is_empty() and port.is_empty(): #if they're both empty
		ERROR_LABEL.text = "You need a Username and Port to " + host_or_join + "!"
		return false
	elif username.is_empty(): #if no username
		ERROR_LABEL.text = "You need a Username to " + host_or_join + "!"
		return false
	elif port.is_empty(): #if no port
		ERROR_LABEL.text = "You need a Port to " + host_or_join + "!"
		return false
	else: #both username and port have been provided
		return true


func _on_host_pressed() -> void:
	var success = _check_textbox_conditions("host")
	if success:
		var username: String = USERNAME_READ.text.strip_edges()
		MultiplayerManager.init_server(SERVER_PORT_READ.text, username)


func _on_join_pressed() -> void:
	var success = _check_textbox_conditions("join")
	if success:
		var username: String = USERNAME_READ.text.strip_edges()
		MultiplayerManager.join_server(SERVER_PORT_READ.text, username)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		back_to_title.emit()


func _on_settings_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.settings, false)


func _on_username_text_changed(new_text: String) -> void:
	var max_length: int = 20
	if new_text.length() > max_length:
		USERNAME_READ.text = USERNAME_READ.text.substr(0,max_length)
		USERNAME_READ.set_caret_column(max_length)


func _on_back_button_pressed() -> void:
	back_to_title.emit()
