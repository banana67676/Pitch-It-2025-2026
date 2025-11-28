extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.lobby_join_failed.connect(_lobby_join_failed)
	GDSync.lobby_joined.connect(MultiplayerManager.join_server)

func _on_join_button_pressed() -> void:
	var server_name: String = %ServerName.text
	var password: String = %Password.text
	
	if server_name.is_empty() and password.is_empty():
		%ErrorMessage.text = "Please enter a server name and password"
	elif server_name.is_empty():
		%ErrorMessage.text = "Please enter a server name"
	elif password.is_empty():
		%ErrorMessage.text = "Please enter a password"
	
	GDSync.lobby_join(server_name, password)
	#does the entered server name exist?
	#is the entered password correct for the lobby

func _lobby_join_failed(error: int) -> void:
	var message
	match(error):
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
			message = "Lobby does not exist"
		ENUMS.LOBBY_JOIN_ERROR.INCORRECT_PASSWORD:
			message = "Incorrect password"
		ENUMS.LOBBY_JOIN_ERROR.DUPLICATE_USERNAME:
			message = "Cannot have same username as another player"
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_FULL:
			message = "Lobby is full"
	%ErrorMessage.text = message

func _is_join_paramater_filled() -> bool:
	return false
