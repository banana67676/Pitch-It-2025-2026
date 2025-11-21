extends Node2D

@onready var text_label = $MarginContainer/ExtraText

signal key_pressed

func _ready() -> void:
	GDSync.connection_failed.connect(func():
		modify_text("Connected failed", Color.from_rgba8(194, 78, 78, 255))
	)

func modify_text(text: String, color: Color) -> void:
	text_label.text = text
	text_label.add_theme_color_override("font_color", color)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton || event is InputEventKey) && !Input.is_action_just_pressed("Esc"):
		if MultiplayerManager.is_gdsync_connected:
			modify_text("Connected!", Color.from_rgba8(0, 194, 42, 255))
			#GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, false)
		else:
			modify_text("Waiting for connection...", Color.from_rgba8(255, 246, 125, 255))
			await GDSync.connected
			modify_text("Connected!", Color.from_rgba8(64, 194, 92, 255))
			#GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, false)
		key_pressed.emit()
	if Input.is_action_just_pressed("Esc"):
		GameManager.quit_game(true)

func reset_scene() -> void:
	modify_text("Press any key to start", Color.from_rgba8(255, 246, 125, 255))
