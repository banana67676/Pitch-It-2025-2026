extends Node2D


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	Camera.fade_in()

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouse && !Input.is_action_just_pressed("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, false)
	if Input.is_action_just_pressed("Esc"):
		GameManager.quit_game(true)
