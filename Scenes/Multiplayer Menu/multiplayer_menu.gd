extends Node2D

@onready var SERVER_PORT_READ: TextEdit = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/HBoxContainer/TextEdit2
@onready var USERNAME_READ: TextEdit = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/HBoxContainer2/TextEdit

@onready var player_scene = preload("res://Scenes/Multiplayer Menu/Player.tscn")


func _on_host_pressed() -> void:
	MultiplayerManager.init_server(SERVER_PORT_READ.text, USERNAME_READ.text)

func _on_join_pressed() -> void:
	MultiplayerManager.join_server(SERVER_PORT_READ.text, USERNAME_READ.text)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.title,false)


func _on_back_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.title,false)
	
