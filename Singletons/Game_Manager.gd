extends Node

#the multiple states/stages of the game
enum game_state_enum {
	title,
	multiplayer_main_menu,
	lobby,
	creation,
	display,
	voting,
	results,
	settings,
}

#the potential game MODES (only the default mode right now)
enum game_mode_enum {
	standard
}

#sets the current gamemode to the standard game mode
var game_mode: game_mode_enum = game_mode_enum.standard

#returns the total time for the round, depending on gamemode
func get_round_time() -> int:
	match game_mode:
		game_mode_enum.standard:
			return 120 #returns 120 for the standard gamemode
	return 2135 #default port for testing

var game_state: int = game_state_enum.title #current game state (lobby, creation, voting, results, etc.)
var creation_time: float = 62 #time to create a product
var presentation_time: float = 3 #time to present a product
var voting_time: float = 30 #time to vote on a product
var win_threshold: int = 200000 #amount of money needed to win

var settings: bool = false

signal scene_changed

func _ready() -> void:
	GDSync.change_scene_called.connect(func(): print("scene change called"))
	GDSync.change_scene_failed.connect(func(): print("scene change failed"))
	GDSync.change_scene_success.connect(func(): print("scene change success"))

#function to quit the game
func quit_game(_protected: bool):
	get_tree().quit()

#returns the current scene
func get_current_scene():
	return enum_to_scene(game_state)

#the function that actually switches the game state
func _game_state_switcher(state: game_state_enum, _protected: bool):
	game_state = state
	#get_tree().current_scene.visible = false
	GDSync.change_scene(enum_to_scene(state))
	#var new_scene = load(enum_to_scene(state))
	#var scene_node = new_scene.instantiate()
	#get_tree().current_scene.free()
	#get_tree().root.add_child(scene_node)
	#get_tree().current_scene = scene_node
	scene_changed.emit()

#function to change the game state (e.g. lobby -> creation)
#this one can specifically be called by any connected peer, and this function will exeucte on ALL peers
#basically it changes the game state for everyone
@rpc("any_peer", "call_local", "reliable")
func change_game_state(state: game_state_enum, protected: bool):
	Camera.fade_out()
	await Camera.animation_player.animation_finished
	_game_state_switcher(state, protected)
	Camera.fade_in()

@rpc("any_peer", "call_local", "reliable")
func delayed_change_game_state(state: game_state_enum, protected: bool, initial_delay: float, final_delay: float):
	#The camera in movement to show the logo/title card
	title_card_intro_transition()
	
	await get_tree().create_timer(initial_delay).timeout #wait the initial delay before switching scenes
	_game_state_switcher(state, protected) #actually switch game states
	await get_tree().create_timer(final_delay).timeout #wait the final delay before showing the new scene
	
	#The camera out movement to fade back into the scene
	title_card_outro_transition()

#fades out the camera, then fades back into the "Pitch It!" screen
func title_card_intro_transition():
	Camera.fade_out()
	await Camera.animation_player.animation_finished
	Camera.find_child("GameArt").visible = true
	Camera.fade_in()
	await Camera.animation_player.animation_finished

#fades out the camera, then fades back in to the newly transitioned scene
func title_card_outro_transition():
	Camera.fade_out()
	await Camera.animation_player.animation_finished
	Camera.find_child("GameArt").visible = false
	Camera.fade_in()

#converts the given enum into the scene that needs to be changed into
func enum_to_scene(state: game_state_enum) -> String:
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
			return "res://Scenes/Results Scene/Results_Scene.tscn"
		game_state_enum.settings:
			return "res://Scenes/Settings Scene/settings_scene.tscn"
	return "2135"
