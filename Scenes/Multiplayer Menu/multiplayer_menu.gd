extends Node2D

@onready var SERVER_PORT_READ: TextEdit = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/HBoxContainer/TextEdit2
@onready var USERNAME_READ: TextEdit = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/HBoxContainer2/TextEdit
@onready var ERROR_LABEL: Label = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/Error

@onready var player_scene = preload("res://Scenes/Multiplayer Menu/Player.tscn")



func _on_host_pressed() -> void:
	# 1. Get the username text and clean it up (remove leading/trailing spaces).
	var user_name: String = USERNAME_READ.text.strip_edges()

	# 2. Validation Gate: Check if the name is empty.
	if user_name.is_empty():
		# If empty, show the error label and stop execution.
		ERROR_LABEL.show()
		return

	# 3. If the name is valid, proceed with hosting the server.
	# Hide the error label (in case it was visible from a previous failure).
	ERROR_LABEL.hide()
	
	# The original hosting logic now runs
	MultiplayerManager.init_server(SERVER_PORT_READ.text, user_name)




func _on_join_pressed() -> void:
	# 1. Get the username text and clean it up (trim spaces).
	var user_name: String = USERNAME_READ.text.strip_edges()
	# 2. Check if the name is empty.
	if user_name.is_empty():
		# If empty, show the error label and stop execution (return).
		ERROR_LABEL.show() # Equivalent to ERROR_LABEL.visible = true
		return

	# 3. If the name is valid, proceed with joining the server.
	# Hide the error label in case it was showing from a previous failed attempt.
	ERROR_LABEL.hide() # Equivalent to error.visible = false
	
	# The original logic now runs
	MultiplayerManager.join_server(SERVER_PORT_READ.text, user_name)




func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.title, false)


func _on_back_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.title, false)


func _on_settings_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.settings, false)
