extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(show_player)
	pass # Replace with function body.

func show_player():
	var player_label = Label.new()
	player_label.text = "who knows?"
	$PlayerList.add_child(player_label)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu)
