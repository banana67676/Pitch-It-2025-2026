extends Node2D

@onready var blitzInfo: VBoxContainer = $"Blitz Game mode/Information"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blitzInfo.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_back_button_2_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false, 0)
	await GameManager.scene_changed
	var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
	lobby_scene.reset_player_data()


func _on_blitz_game_mode_pressed() -> void:
	GameManager.game_mode = GameManager.game_mode_enum.blitz
	#GameManager.change_game_state(GameManager.game_state_enum.lobby, false)
	blitzInfo.visible = !blitzInfo.visible
	
	
