extends Control
class_name UsernameScene

@onready var USERNAME_READ: LineEdit = %Username
@onready var ERROR_LABEL: Label = %ErrorText

const TWEEN_TIME: float = 1

signal back_to_title
signal to_host
signal to_join

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
		to_host.emit(username)


func _on_join_pressed() -> void:
	var success = _check_textbox_conditions("join")
	if success:
		var username: String = USERNAME_READ.text.strip_edges()
		to_join.emit(username)
		#MultiplayerManager.join_server(username)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		back_to_title.emit()


func _on_username_text_changed(new_text: String) -> void:
	const MAX_LENGTH: int = 20
	if new_text.length() > MAX_LENGTH:
		USERNAME_READ.text = USERNAME_READ.text.substr(0,MAX_LENGTH)
		USERNAME_READ.set_caret_column(MAX_LENGTH)


func reset_animation() -> void:
	$BackButton.position = Vector2(-284, $BackButton.position.y)
	$BackButton.visible = false
	$SettingsScene.position = Vector2(1436, $SettingsScene.position.y)
	$SettingsScene.visible = false


func play_animation() -> void:
	$BackButton.visible = true
	$SettingsScene.visible = true
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property($BackButton, "position", Vector2(16, $BackButton.position.y), TWEEN_TIME)
	tween.tween_property($SettingsScene, "position", Vector2(1136, $SettingsScene.position.y), TWEEN_TIME)


func _on_back_button_pressed() -> void:
	back_to_title.emit()
