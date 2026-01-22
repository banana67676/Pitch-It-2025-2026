extends Node

#creating a class for GameModes
class GameMode:
	var name: String
	var description: String
	var mode: GameManager.GameMode
	
	#the contstructor for the class
	func _init(p_name: String, p_description: String, p_mode: GameManager.GameMode):
		name = p_name
		description = p_description
		mode = p_mode


#descriptions for all of the gamemodes
var classic_description: String = "Default game mode. Everyone is together where they get the same 'Who' and 'What' cards. Reach $5 million dollars to win"
var Random_description: String = "Random cards. Everyone is different getting different 'Who' and 'What' cards. Reach $5 million dollars to win"

#each of the different gamemodes
var game_mode_array: Array[GameMode]
#var classic_mode: GameMode


func _ready() -> void:
	var classic_mode: GameMode = GameMode.new("Classic", classic_description, GameManager.GameMode.CLASSIC)
	game_mode_array.append(classic_mode)
	game_mode_array.append(GameMode.new("New cards", Random_description, GameManager.GameMode.ALL_TOGETHER))
	_create_buttons()
	_update_game_mode(classic_mode) #make it so that the classic gamemode is selected by default


func _create_buttons() -> void:
	for game_mode: GameMode in game_mode_array:
		var button: Button = %ButtonTemplate.duplicate()
		button.name = game_mode.name
		button.text = game_mode.name
		button.theme_type_variation = "ButtonSmall"
		button.connect("pressed", _update_game_mode.bind(game_mode))
		%ButtonContainer.add_child(button)
		button.visible = true


func _update_game_mode(game_mode: GameMode) -> void:
	#set the text and gamemode in the backend
	%ModeTitle.text = game_mode.name
	%ModeDescription.text = game_mode.description
	GameManager.game_mode = game_mode.mode
	
	#update the button visual
	for button: Button in %ButtonContainer.get_children():
		button.disabled = false #disbale every button
		if button.name == game_mode.name:
			button.disabled = true #except the one that matches the currently clicked one
