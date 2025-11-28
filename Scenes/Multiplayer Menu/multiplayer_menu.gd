extends Node2D

@onready var USERNAME_READ: LineEdit = %Username
@onready var ERROR_LABEL: Label = %ErrorText

signal back_to_title

func _ready() -> void:
	reset_animation()



#returns true if the player has inputted a username and port to host/join a lobby
func _check_textbox_conditions(host_or_join: String) -> bool:
	#host_or_join is a variable that changes depending on if the player clicked the Host or Join buttons
	var username: String = USERNAME_READ.text.strip_edges() #grabs the username text
	if username.is_empty(): #if no username
		ERROR_LABEL.text = "You need a Username to " + host_or_join + "!"
		return false
	else: #username has been provided
		return true


func _on_host_pressed() -> void:
	var success = _check_textbox_conditions("host")
	if success:
		var username: String = USERNAME_READ.text.strip_edges()
		MultiplayerManager.init_server(username)


func _on_join_pressed() -> void:
	var success = _check_textbox_conditions("join")
	if success:
		var username: String = USERNAME_READ.text.strip_edges()
		MultiplayerManager.join_server(username)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		back_to_title.emit()


func _on_username_text_changed(new_text: String) -> void:
	var max_length: int = 20
	if new_text.length() > max_length:
		USERNAME_READ.text = USERNAME_READ.text.substr(0,max_length)
		USERNAME_READ.set_caret_column(max_length)


func _on_back_button_pressed() -> void:
	back_to_title.emit()


func reset_animation() -> void:
	$BackButton.position = Vector2(-284, $BackButton.position.y)
	$SettingsScene.position = Vector2(1436.0, $SettingsScene.position.y)


func play_animation() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property($BackButton, "position", Vector2(16, $BackButton.position.y), 1)
	tween.tween_property($SettingsScene, "position", Vector2(1136, $SettingsScene.position.y), 1)
