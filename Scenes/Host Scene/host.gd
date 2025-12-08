extends Control
class_name HostScene

signal back_to_username

var username: String
var is_private: bool = false
const TWEEN_TIME: float = 1

#texture preloads (for the "is private" button)
const checked_normal = preload("res://Assets/checked_normal.svg")
const checked_hover = preload("res://Assets/checked_hover.svg")
const unchecked_normal = preload("res://Assets/unchecked_normal.svg")
const unchecked_hover = preload("res://Assets/unchecked_hover.svg")

func _ready():
	reset_values()
	$ResetButton.pressed.connect(reset_values) #when the reset button is pressed, call the function reset_values


#when the is_private button is pressed, toggle private mode on and off
func _on_is_private_button_pressed() -> void:
	if is_private:
		%Password.editable = false
		%Password.text = ""
		%IsPrivateButton.texture_normal = unchecked_normal
		%IsPrivateButton.texture_hover = unchecked_hover
		is_private = false
	else:
		%Password.editable = true
		%IsPrivateButton.texture_normal = checked_normal
		%IsPrivateButton.texture_hover = checked_hover
		is_private = true


#when the host button is pressed
func _on_host_button_pressed() -> void:
	#checking lobby name
	%LobbyName.text = %LobbyName.text.strip_edges() #remove spaces
	var lobby_name: String = %LobbyName.text
	if lobby_name.length() < 3:
		%ErrorMessage.text = "Lobby name must be longer than 3 characters"
		return
	
	#grabbing password (they don't need one for a private lobby)
	var password: String = ""
	if is_private: #only look for a password if the lobby is private
		%Password.text = %Password.text.strip_edges() #remove spaces
		password = %Password.text
	#if is_private and password.is_empty(): #if private gamemode and no password entered
		#%ErrorMessage.text = "Please enter a password for a private lobby"
		#return
	
	#if both of the above checks passed, then we're good to create a lobby
	%ErrorMessage.text = ""
	var max_players: int = %MaxPlayersValue.value
	MultiplayerManager.init_server(username, lobby_name, password, !is_private, max_players)
	#change the timings for the different sections of the game
	GameManager.creation_time = %CreationTimeValue.value
	GameManager.display_time = %DisplayTimeValue.value
	GameManager.voting_time = %VotingTimeValue.value
	GameManager.results_time = %ResultsTimeValue.value


#resets all of the values for lobby options
func reset_values() -> void:
	set_default_lobby_name()
	%MaxPlayersValue.value = 4
	%CreationTimeValue.value = GameManager.CREATION_DEFAULT
	%DisplayTimeValue.value = GameManager.DISPLAY_DEFAULT
	%VotingTimeValue.value = GameManager.VOTING_DEFAULT
	%ResultsTimeValue.value = GameManager.RESULTS_DEFAULT
	is_private = false
	%IsPrivateButton.texture_normal = unchecked_normal
	%IsPrivateButton.texture_hover = unchecked_hover
	%Password.editable = false


#sets a default lobby name (called by the Game Opening scene)
func set_default_lobby_name():
	%LobbyName.text = username + "'s Lobby"


#updates the username for the scene (also called by the Game Opening scene)
func update_username(usern: String) -> void:
	username = usern
	set_default_lobby_name()


#when the lobby name line edit is changed, limit its text if it exceeds the length limit
func _on_lobby_name_text_changed(new_text: String) -> void:
	const MAX_LENGTH: int = GameManager.MAX_LOBBY_NAME_LENGTH
	if new_text.length() > MAX_LENGTH:
		%LobbyName.text = %LobbyName.text.substr(0, MAX_LENGTH)
		%LobbyName.set_caret_column(MAX_LENGTH)


func _on_back_button_pressed() -> void:
	back_to_username.emit()


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
	$ResetButton.position = Vector2($ResetButton.position.x, 862)
	$ResetButton.visible = false
	$GameMode.position = Vector2($GameMode.position.x, 519)
	$GameMode.visible = false


func play_animation() -> void:
	$BackButton.visible = true
	$SettingsScene.visible = true
	$ResetButton.visible = true
	$GameMode.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var tween2 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var tween3 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var tween4 = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($SettingsScene, "position", Vector2($SettingsScene.position.x, 16), TWEEN_TIME)
	tween2.tween_interval(0.2) #0.2 second delay before next tween
	tween2.tween_property($BackButton, "position", Vector2($BackButton.position.x, 16), TWEEN_TIME)
	tween3.tween_interval(0.4) #another 0.2 seconds before next tween (because the all the tween interval timers start together)
	tween3.tween_property($ResetButton, "position", Vector2($ResetButton.position.x, 562), TWEEN_TIME)
	tween4.tween_interval(0.6) #ANOTHER 0.2 second delay before next tween
	tween4.tween_property($GameMode, "position", Vector2($GameMode.position.x, 219), TWEEN_TIME)
