extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

var port = 135

func _on_host_pressed() -> void:
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	pass

func _on_join_pressed() -> void:
	peer.create_client("localhost", port)
	
	multiplayer.multiplayer_peer = peer
	pass # Replace with function body.
	
