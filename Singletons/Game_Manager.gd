extends Node


enum game_state_enum{
	title,
	main_menu,
	lobby,
	creation,
	presentaion,
	voting,
	results,
	end_game
}

var game_state : int = game_state_enum.title

var settings : bool = false
