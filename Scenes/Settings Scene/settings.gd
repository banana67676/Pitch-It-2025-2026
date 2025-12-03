
extends Control

@onready var settings_menu: PanelContainer = $SettingsMenu

@export var show_settings: bool:
	set(value):
		if settings_menu == null:
			return
		settings_menu.visible = value
		show_settings = value

var music_bus_index = AudioServer.get_bus_index("Music")
var sfx_bus_index = AudioServer.get_bus_index("SFX")

var is_just_clicked: bool = false
const TWEEN_TIME: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_menu.visible = show_settings
	_get_stored_settings()
	#print("volume: " + str(AudioServer.get_bus_volume_db(music_bus_index)))

func _get_stored_settings():
	%MusicSlider.value = GameManager.volume_music
	%SFXSlider.value = GameManager.volume_sfx

func _on_music_slider_value_changed(value: float) -> void:
	GameManager.volume_music = value
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	GameManager.volume_sfx = value


func _on_settings_button_pressed() -> void:
	_get_stored_settings()
	is_just_clicked = true
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if show_settings:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(0), TWEEN_TIME)
		settings_menu.visible = false
		show_settings = false
	else:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(-90), TWEEN_TIME)
		settings_menu.visible = true
		show_settings = true
	await get_tree().create_timer(TWEEN_TIME).timeout
	is_just_clicked = false


func _on_settings_button_mouse_entered() -> void:
	if is_just_clicked:
		return
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if settings_menu.visible:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(-135), TWEEN_TIME)
	else:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(45), TWEEN_TIME)


func _on_settings_button_mouse_exited() -> void:
	if is_just_clicked:
		return
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if settings_menu.visible:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(-90), TWEEN_TIME)
	else:
		tween.tween_property($SettingsButton, "rotation", deg_to_rad(0), TWEEN_TIME)
