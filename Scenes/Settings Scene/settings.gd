extends Control

@onready var settings_popup: Control = $Overlay/Setting/VSplitContainer



var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_popup.visible = false
	print("volume: " + str(AudioServer.get_bus_volume_db(music_bus_index)))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, false)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_setting_pressed() -> void:
	settings_popup.visible = !settings_popup.visible
	pass # Replace with function body.
