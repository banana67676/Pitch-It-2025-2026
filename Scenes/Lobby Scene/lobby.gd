extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		pass
		MultiplayerManager.player_ready.connect(show_player)
	else:
		$Begin.visible = false
	pass # Replace with function body.

func show_player(id):
	var player_label = Label.new()
	player_label.text = MultiplayerManager.players[id].username
	$PlayerList.add_child(player_label)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, true)

func _on_begin_pressed() -> void:
	MultiplayerManager.run_game()
	pass # Replace with function body.
