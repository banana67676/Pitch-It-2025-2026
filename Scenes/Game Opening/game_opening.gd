extends Node2D

@onready var title_scene: Node2D = $Title_Scene
@onready var multiplayer_menu: Node2D = $Multiplayer_Menu

const tween_time = 1.5
const vertical_shift = 800


func _ready() -> void:
	title_scene.key_pressed.connect(_transition_to_menu)
	multiplayer_menu.back_to_title.connect(_transition_to_title)

func _transition_to_title() -> void:
	title_scene.reset_scene()
	GameManager.game_state = GameManager.game_state_enum.title
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property($Title_Scene, "position", $Title_Scene.position + Vector2(0, vertical_shift), tween_time)
	tween.tween_property($Multiplayer_Menu, "position", $Multiplayer_Menu.position + Vector2(0, vertical_shift), tween_time)


func _transition_to_menu() -> void:
	if GameManager.game_state == GameManager.game_state_enum.title or GameManager.game_state == GameManager.game_state_enum.game_opening:
		GameManager.game_state = GameManager.game_state_enum.multiplayer_main_menu
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property($Title_Scene, "position", $Title_Scene.position + Vector2(0, -vertical_shift), tween_time)
		tween.tween_property($Multiplayer_Menu, "position", $Multiplayer_Menu.position + Vector2(0, -vertical_shift), tween_time)
