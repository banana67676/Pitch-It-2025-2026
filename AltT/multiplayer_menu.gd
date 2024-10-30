extends Node2D

@onready var SERVER_PORT_READ: TextEdit = $MarginContainer/VBoxContainer/MarginContainer/TextEdit

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func _on_button_pressed():
	if SERVER_PORT_READ.text.to_int() != null:
		peer.create_server(SERVER_PORT_READ.text.to_int())
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(add_player)
		add_player()

func _on_button_2_pressed():
	if SERVER_PORT_READ.text.to_int() != null:
		var ip_addresses = IP.get_local_addresses()
		for i in ip_addresses:
			if !i.begins_with("f"):
				print(i)
				peer.create_client(i, SERVER_PORT_READ.text.to_int())
				multiplayer.multiplayer_peer = peer


func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
