extends Control
class_name JoinScene

signal back_to_username
signal lobby_success(bool)

var username: String
const TWEEN_TIME: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.lobby_joined.connect(_lobby_success)
	GDSync.lobby_join_failed.connect(_lobby_join_failed)
	GDSync.lobbies_received.connect(show_lobbies)
	%RefreshButton.pressed.connect(fetch_servers)
	#GDSync.lobby_joined.connect(MultiplayerManager.join_server)


func show_lobbies(lobbies: Array) -> void:
	_clear_lobby_list()
	for lobby: Dictionary in lobbies: #for every lobby that is public
		#grab the data of the lobby
		var lobby_name: String = lobby["Name"]
		var current_players: int = lobby["PlayerCount"]
		var max_players: int = lobby["PlayerLimit"]
		
		if current_players == max_players: #if the lobby is full, don't display it
			continue #move on to the next iteration of the for loop (meaning the next lobby)
		
		#set the display to show the data of the lobby
		var display_box: PanelContainer = $DisplayBoxTemplate.duplicate() #get a copy of the display box
		var lobby_name_label: Label = display_box.get_node("MarginContainer/HBoxContainer/LobbyName")
		var player_count_label: Label = display_box.get_node("MarginContainer/HBoxContainer/PlayerCount")
		display_box.name = lobby_name #set the name of the node to the lobby name
		lobby_name_label.text = lobby_name #set the displayed lobby name text to the lobby name
		player_count_label.text = "(" + str(current_players) + "/" + str(max_players) + ")" #show the current players out of total
		%LobbyList.add_child(display_box)
		display_box.visible = true
		
		#make the join button for the display box work
		var join_button: Button = display_box.get_node("MarginContainer/HBoxContainer/JoinButton")
		join_button.connect("pressed", _join_listed_lobby.bind(lobby_name)) #attach the _join_listed_lobby function


#the lobby_name is binded to the function, meaning it will always be the same
func _join_listed_lobby(lobby_name: String) -> void:
	GDSync.lobby_join(lobby_name)
	MultiplayerManager.join_server(username, lobby_name)
	#find a way to call MultiplayerManager.join_server() and provide the username to officially join the lobby

#when the join button is pressed
func _on_join_button_pressed() -> void:
	#%ErrorMessage.text = ""
	var lobby_name: String = %LobbyName.text
	var password: String = %Password.text
	
	#checking if the join paramaters are valid
	if lobby_name.is_empty():
		%ErrorMessage.text = "Please enter a server name"
		return
	
	GDSync.lobby_join(lobby_name, password) #attempt to join the lobby
	var is_success: bool = await lobby_success #the signal passes a boolean, depending on if it could successfully join the lobby
	if is_success:
		%ErrorMessage.text = "Lobby found!"
		MultiplayerManager.join_server(username, lobby_name)


func _clear_lobby_list() -> void:
	for child in %LobbyList.get_children():
		child.queue_free()


#this function will be called by the Game Opening scene
func fetch_servers() -> void:
	GDSync.get_public_lobbies()


#this function will also be called by the Game Opening scene
func update_username(usern: String) -> void:
	username = usern


#when joining the lobby is successful (this function is connected to the signal GDSYNC.lobby_joined, meaning the lobby was joined)
func _lobby_success(_lobby_name: String) -> void:
	lobby_success.emit(true)


func _lobby_join_failed(lobby_name: String, error: int) -> void:
	print("Failed to join lobby: " + lobby_name)
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
	lobby_success.emit(false)


func _on_back_button_pressed() -> void:
	back_to_username.emit()


#limit the text limit when the player enters the lobby name
func _on_lobby_name_text_changed(new_text: String) -> void:
	const MAX_LENGTH: int = GameManager.MAX_LOBBY_NAME_LENGTH
	if new_text.length() > MAX_LENGTH:
		%LobbyName.text = %LobbyName.text.substr(0, MAX_LENGTH)
		%LobbyName.set_caret_column(MAX_LENGTH)


#limit the text limit when the player enters the password
func _on_password_text_changed(new_text: String) -> void:
	const MAX_LENGTH: int = GameManager.MAX_PASSWORD_LENGTH
	if new_text.length() > MAX_LENGTH:
		%Password.text = %Password.text.substr(0, MAX_LENGTH)
		%Password.set_caret_column(MAX_LENGTH)


func reset_animation() -> void:
	$BackButton.position = Vector2($BackButton.position.x, -284)
	$BackButton.visible = false
	$SettingsScene.position = Vector2($SettingsScene.position.x, -284)
	$SettingsScene.visible = false


func play_animation() -> void:
	$BackButton.visible = true
	$SettingsScene.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var tween2 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($BackButton, "position", Vector2($BackButton.position.x, 16), TWEEN_TIME)
	tween2.tween_interval(0.2) #0.2 second delay before next tween
	tween2.tween_property($SettingsScene, "position", Vector2($SettingsScene.position.x, 16), TWEEN_TIME)
