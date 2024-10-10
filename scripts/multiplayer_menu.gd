extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

var SERVER_PORT  = 2135
var SERVER_IP = "192.168.4.67"

func _on_button_pressed():
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()

func _on_button_2_pressed():
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer


func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
