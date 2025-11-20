@tool
extends Control

@onready var settings_menu: PanelContainer = $SettingsMenu

@export var show_settings: bool:
	set(value):
		$SettingsMenu.visible = value
		show_settings = value

var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SettingsMenu.visible = show_settings
	#print("volume: " + str(AudioServer.get_bus_volume_db(music_bus_index)))


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))


func _on_sfx_slider_value_changed(_value: float) -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if show_settings:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(45), 1) #moving its position
		settings_menu.visible = false
		show_settings = false
	else:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(-90), 1) #moving its position
		settings_menu.visible = true
		show_settings = true


func _on_settings_button_mouse_entered() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($SettingsButton, "rotation", deg_to_rad(45), 1) #moving its position


func _on_settings_button_mouse_exited() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($SettingsButton, "rotation", deg_to_rad(0), 1) #moving its position
