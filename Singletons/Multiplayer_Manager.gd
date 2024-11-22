extends Node

var peer = ENetMultiplayerPeer.new()
const Lobby = preload("res://Scenes/Lobby Scene/lobby.gd")
const PlayerData = preload("res://Scenes/Multiplayer Menu/PlayerData.gd")
signal player_ready
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.connect("scene_changed", continue_init)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func continue_init():
	set_username(username)

func init_server(port, usern):
	username = usern
	if port != null:
		peer.create_server(port.to_int())
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(add_player)
		GameManager.change_game_state(GameManager.game_state_enum.lobby, false)

var cards = []
var players = {}
var username = ""

func add_player(id):
	var player

func join_server(port, usern):
	username = usern
	print(port.to_int())
	if port.to_int() != null:
		var ip_addresses = ["localhost"]
		for i in ip_addresses:
			print(i)
			if !i.begins_with("f"):
				peer.create_client(i, port.to_int())
				multiplayer.multiplayer_peer = peer
				if !multiplayer.connected_to_server.is_connected(_on_connected_ok):
					multiplayer.connected_to_server.connect(_on_connected_ok)

func _on_connected_ok():
	set_username.rpc_id(1, username)

@rpc("any_peer", "call_local", "reliable")
func set_username(username: String):
	if !multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() == 0:
		MultiplayerManager.players[multiplayer.get_unique_id()] = PlayerData.new()
		MultiplayerManager.players[multiplayer.get_unique_id()].username = username
		get_parent().get_node("LobbyScene").connect("player_ready", get_parent().get_node("LobbyScene").show_player)
		player_ready.emit(multiplayer.get_unique_id())
	if GameManager.game_state != GameManager.game_state_enum.lobby:
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), false)
	else:
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), true)
		MultiplayerManager.players[multiplayer.get_remote_sender_id()] = PlayerData.new()
		MultiplayerManager.players[multiplayer.get_remote_sender_id()].username = username
		player_ready.emit(multiplayer.get_remote_sender_id())


@rpc("any_peer", "reliable")
func join_setup(success: bool):
	if success:
		GameManager.change_game_state(GameManager.game_state_enum.lobby, false)
	else:
		multiplayer.multiplayer_peer = null

@rpc("any_peer", "call_local", "reliable")
func receive_player_data(players: Array[PlayerData]):
	MultiplayerManager.players = players

func run_game():
	# Run creation screen
	GameManager.change_game_state.rpc(GameManager.game_state_enum.creation, false)
	await get_tree().create_timer(GameManager.creation_time).timeout

	# Get cards
	get_parent().get_node("Creation_Scene").export_card.rpc()

	print(cards)
	# Change to display
	GameManager.change_game_state.rpc(GameManager.game_state_enum.display, false)
	for product in cards:
		get_tree().current_scene.display.rpc(product)
		await get_tree().create_timer(GameManager.presentation_time).timeout

	# Voting
	receive_player_data.rpc(players)
	GameManager.change_game_state.rpc(GameManager.game_state_enum.voting, false)
	await get_tree().create_timer(20).timeout


	# Results
	GameManager.change_game_state.rpc(GameManager.game_state_enum.results, false)
