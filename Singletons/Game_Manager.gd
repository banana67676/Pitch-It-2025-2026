extends Node


enum game_state_enum{
	title,
	multiplayer_main_menu,
	lobby,
	creation,
	display,
	voting,
	results
}

enum game_mode_enum{
	standard
}

var game_mode : game_mode_enum = game_mode_enum.standard

func get_round_time() -> int:
	
	match game_mode:
		game_mode_enum.standard:
			return 120
	
	return 2135

var game_state : int = game_state_enum.title
var creation_time : float = 8
var presentation_time : float = 60

var settings : bool = false

signal scene_changed

func quit_game(protected:bool):
	get_tree().quit()

@rpc("any_peer", "call_local", "reliable")
func change_game_state(state:game_state_enum, protected : bool):
	Camera.fade_out()
	await Camera.animation_player.animation_finished
	game_state = state
	get_tree().current_scene.visible=false
	var new_scene = load(enum_to_scene(state))
	var scene_node = new_scene.instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(scene_node)
	get_tree().current_scene = scene_node

	#get_tree().change_scene_to_file(enum_to_scene(state))
	scene_changed.emit()
	Camera.fade_in()


func enum_to_scene(state:game_state_enum) -> String:
	match state:
		game_state_enum.title:
			return "res://Scenes/Title Scene/Title_Scene.tscn"
		game_state_enum.multiplayer_main_menu:
			return "res://Scenes/Multiplayer Menu/Multiplayer_Menu.tscn"
		game_state_enum.lobby:
			return "res://Scenes/Lobby Scene/Lobby_Scene.tscn"
		game_state_enum.creation:
			return "res://Scenes/Creation Scene/Creation_Scene.tscn"
		game_state_enum.display:
			return "res://Scenes/Display Scene/Display_Scene.tscn"
		game_state_enum.voting:
			return "res://Scenes/Voting Scene/Voting_Scene.tscn"
		game_state_enum.results:
			return "res://Scenes/Results Scene/Results Scene.tscn"
	return "2135"
