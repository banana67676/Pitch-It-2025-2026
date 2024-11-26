extends Node

const MM = preload("res://Singletons/Multiplayer_Manager.gd")
signal lobby_ready
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		lobby_ready.emit()
		pass
	else:
		$MarginContainer/VSplitContainer/MarginContainer2/Begin.visible = false
	pass # Replace with function body.

var player_count : int = 0

func show_player(id):
	var player_label = Label.new()
	player_label.text = MultiplayerManager.players[id].username
	$PlayerList.add_child(player_label)
	player_label.set_global_position(Vector2(200+250*(player_count % 3), 150+50*(int(player_count) / 3)))
	player_count += 1
	pass


func reset_player_data():
	for player in $PlayerList.get_children():
		remove_child(player)
		player.queue_free()
	player_count = 0
	for player in MultiplayerManager.players:
		var player_label = Label.new()
		player_label.text = MultiplayerManager.players[player].username
		$PlayerList.add_child(player_label)
		player_label.set_global_position(Vector2(200+250*(player_count % 3), 150+50*(int(player_count) / 3)))
		player_count += 1
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, true)

func _on_begin_pressed() -> void:
	print("pressed")
	MultiplayerManager.run_game_loop()
	pass # Replace with function body.
