extends Node

#the multiple states/stages of the game
enum game_state_enum {
	title,
	username,
	lobby,
	creation,
	display,
	voting,
	results,
	settings,
	host,
	join,
	game_opening,
}



#the potential game MODES (only the default mode right now)
enum GameMode {
	CLASSIC,
	ALL_TOGETHER,
}

#current game_mode and game_state
var game_mode: GameMode = GameMode.CLASSIC
var game_state: int = game_state_enum.title #current game state (lobby, creation, voting, results, etc.)

#the DEFAULT times for the different sections of the game
const CREATION_DEFAULT: float = 180
const DISPLAY_DEFAULT: float = 60
const VOTING_DEFAULT: float = 30
const RESULTS_DEFAULT: float = 10

#times for the different sections of the game (these can be modified in game by the lobby host)
var creation_time: float = CREATION_DEFAULT #time to create a product
var display_time: float = DISPLAY_DEFAULT #time to present a product
var voting_time: float = VOTING_DEFAULT #time to vote on a product
var results_time: float = RESULTS_DEFAULT #time that the results are displayed
var show_winner_time: float = 5

const SCORE_INCREMENT: int = 1000000 #gain this much money per vote
const WIN_THRESHOLD: int = 5000000 #amount of money needed to win

#variables for the game settings (stored here so that the values can be transferred between scenes)
var volume_music: float = 75.0
var volume_sfx: float = 75.0

#variables for maximum lobby name lengths and password lengths (for the lobby)
const MAX_LOBBY_NAME_LENGTH: int = 32
const MAX_PASSWORD_LENGTH: int = 16


signal scene_changed

func _ready() -> void:
	GDSync.expose_func(change_game_state)
	GDSync.expose_func(_multiplayer_state_switcher)
	#GDSync.change_scene_called.connect(func(_arg): print("scene change called"))
	#GDSync.change_scene_failed.connect(func(): print("scene change failed"))
	#GDSync.change_scene_success.connect(func(_arg): print("scene change success"))

#function to quit the game
func quit_game(_protected: bool):
	get_tree().quit()


#returns the current scene
func get_current_scene():
	return enum_to_scene(game_state)


#the function that actually switches the game state
func _singleplayer_state_switcher(state: game_state_enum):
	game_state = state
	get_tree().current_scene.visible = false
	var new_scene = load(enum_to_scene(state))
	var scene_node = new_scene.instantiate()
	get_tree().current_scene.free()
	get_tree().root.add_child(scene_node)
	get_tree().current_scene = scene_node
	scene_changed.emit()


func _multiplayer_state_switcher(state: game_state_enum) -> void:
	#print("actually called from " + str(GDSync.get_client_id()))
	game_state = state
	if GDSync.is_host():
		GDSync.change_scene(enum_to_scene(state)) #use GDSync's built in function to switch scenes for everyone
	await GDSync.change_scene_success
	scene_changed.emit()


func change_game_state(state: game_state_enum, use_singleplayer: bool, delay: float):
	Camera.fade_out()
	await Camera.animation_player.animation_finished
	await get_tree().create_timer(delay/2).timeout
	if GDSync.is_host() and state != game_state_enum.lobby and state != game_state_enum.game_opening: #if there is an active multiplayer lobby and you are the host
		GDSync.call_func_all(_multiplayer_state_switcher, [state])
		await GameManager.scene_changed
	elif use_singleplayer: #otherwise use the singeplayer scene switching system if it should be used
		_singleplayer_state_switcher(state)
	await get_tree().create_timer(delay/2).timeout
	Camera.fade_in()

#converts the given enum into the scene that needs to be changed into
func enum_to_scene(state: game_state_enum) -> String:
	match state:
		game_state_enum.title:
			return "res://Scenes/Title Scene/Title_Scene.tscn"
		game_state_enum.username:
			return "res://Scenes/Username/Username.tscn"
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
		game_state_enum.host: 
			return "res://Scenes/Host Scene/Host_Scene.tscn"
		game_state_enum.game_opening:
			return "res://Scenes/Game Opening/Game_Opening.tscn"
	return "2135"
