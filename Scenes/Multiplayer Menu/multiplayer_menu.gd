extends Node2D

@onready var SERVER_PORT_READ: TextEdit = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/HBoxContainer/TextEdit2
@onready var USERNAME_READ: TextEdit = $MarginContainer/VSplitContainer/MarginContainer/GridContainer/HBoxContainer2/TextEdit

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
		GameManager.change_game_state(GameManager.game_state_enum.lobby, false)

func _on_join_pressed() -> void:
	print(SERVER_PORT_READ.text.to_int())
	if SERVER_PORT_READ.text.to_int() != null:
		var ip_addresses = IP.get_local_addresses()
		for i in ip_addresses:
			if !i.begins_with("f"):
				peer.create_client(i, SERVER_PORT_READ.text.to_int())
				multiplayer.multiplayer_peer = peer
				await multiplayer.connected_to_server
				set_username.rpc(USERNAME_READ.text)

@rpc("authority","reliable")
func set_username(name: String):
	if GameManager.game_state != GameManager.game_state_enum.lobby:
		join_setup.rpc(multiplayer.get_remote_sender_id(), false)
	else:
		join_setup.rpc(multiplayer.get_remote_sender_id(), true)
		MultiplayerManager.users[multiplayer.get_remote_sender_id()] = name

@rpc("any_peer", "reliable")
func join_setup(success: bool):
	if success:
		GameManager.change_game_state(GameManager.game_state_enum.lobby, false)
	else:
		multiplayer.multiplayer_peer = null


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.title,false)
