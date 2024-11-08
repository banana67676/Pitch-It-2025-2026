extends Node2D

@onready var SERVER_PORT_READ: TextEdit = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/HBoxContainer/TextEdit2

@onready var player_scene = preload("res://Scenes/Multiplayer Menu/Player.tscn")


var peer = ENetMultiplayerPeer.new()

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	self.get_parent().call_deferred("add_child", player)
	visible = false


func _on_host_pressed() -> void:
	if SERVER_PORT_READ.text != null:
		peer.create_server(SERVER_PORT_READ.text.to_int())
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(add_player)
		add_player()
		GameManager.change_game_state(GameManager.game_state_enum.lobby)

func _on_join_pressed() -> void:
	if SERVER_PORT_READ.text.to_int() != null:
		var ip_addresses = IP.get_local_addresses()
		for i in ip_addresses:
			if !i.begins_with("f"):
				print(i)
				peer.create_client(i, SERVER_PORT_READ.text.to_int())
				multiplayer.multiplayer_peer = peer




func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.title)
