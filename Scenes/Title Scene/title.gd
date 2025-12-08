extends Control
class_name TitleScene

@onready var text_label = $ExtraTextContainer/ExtraText

signal key_pressed

func _ready() -> void:
	GDSync.connection_failed.connect(func():
		modify_text("Connected failed", Color.from_rgba8(194, 78, 78, 255))
	)
	if GameManager.game_state == GameManager.game_state_enum.game_opening:
		GameManager.game_state = GameManager.game_state_enum.title


#changes the text at the bottom of the title screen
func modify_text(text: String, color: Color) -> void:
	text_label.text = text
	text_label.add_theme_color_override("font_color", color)


func _input(event: InputEvent) -> void:
	if GameManager.game_state != GameManager.game_state_enum.title:
		return
	if (event is InputEventMouseButton || event is InputEventKey):
		if MultiplayerManager.is_gdsync_connected:
			modify_text("Connected!", Color.from_rgba8(0, 194, 42, 255))
		else:
			modify_text("Waiting for connection...", Color.from_rgba8(255, 246, 125, 255))
			await GDSync.connected
			modify_text("Connected!", Color.from_rgba8(64, 194, 92, 255))
		key_pressed.emit()


func reset_scene() -> void:
	modify_text("Press any key to start", Color.from_rgba8(255, 246, 125, 255))


func _on_quit_button_pressed() -> void:
	GameManager.quit_game(true)
