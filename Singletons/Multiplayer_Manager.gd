extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var results = []

func run_game():
	GameManager.change_game_state.rpc(GameManager.game_state_enum.creation)
	await get_tree().create_timer(GameManager.creation_time).timeout
	get_tree().find_child("Creation_Scene").export_card.rpc()
	for product in results:
		get_tree().find_child("ResultsScene").display().rpc(product)
		await get_tree().create_time(GameManager.presentation_time)
	GameManager.change_game_state.rpc(GameManager.game_state_enum.display)
	
