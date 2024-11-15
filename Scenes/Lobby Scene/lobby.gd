extends Node

const MM = preload("res://Singletons/Multiplayer_Manager.gd")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		pass
	else:
		$MarginContainer/VSplitContainer/MarginContainer2/Begin.visible = false
	pass # Replace with function body.

var player_count : int = 0

func show_player(id):
	var player_label = Label.new()
	player_label.text = MultiplayerManager.players[id].username
	$PlayerList.add_child(player_label)
	player_label.set_global_position(Vector2(200+100*player_count % 3, 150+50*(int(player_count) / 3)))
	player_count += 1
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, true)

func _on_begin_pressed() -> void:
	MultiplayerManager.run_game()
	pass # Replace with function body.
