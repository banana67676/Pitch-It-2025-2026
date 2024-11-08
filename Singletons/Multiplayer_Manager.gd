extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var cards = []

func run_game():
	# Run creation screen
	GameManager.change_game_state.rpc(GameManager.game_state_enum.creation)
	await get_tree().create_timer(GameManager.creation_time).timeout
	
	# Get cards
	get_tree().find_child("Creation_Scene").export_card.rpc()
	# Change to display
	GameManager.change_game_state.rpc(GameManager.game_state_enum.display)
	for product in cards:
		get_tree().current_scene.display.rpc(product)
		await get_tree().create_time(GameManager.presentation_time)
	
	# Voting
	GameManager.change_game_state.rpc(GameManager.game_state_enum.voting)
	
	# Results
	GameManager.change_game_state.rpc(GameManager.game_state_enum.results)
