extends Node

var peer = ENetMultiplayerPeer.new()
const PlayerData = preload("res://Scenes/Multiplayer Menu/PlayerData.gd")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect("lobby_ready", continue_init)
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
		await GameManager.scene_changed
		#while !get_parent().has_node("/root/LobbyScene"):
		#	await get_tree().create_timer(0.1).timeout
		#	pass
		#await get_tree().create_timer(5.0).timeout
		continue_init()

var cards = []
var players = {}
var username = ""

func add_player(id):
	pass

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

@rpc("any_peer", "reliable")
func set_username(username: String):
	var lobby_scene = get_node("/root/LobbyScene")
	if multiplayer.get_remote_sender_id() == 0:
		MultiplayerManager.players[multiplayer.get_unique_id()] = PlayerData.new()
		MultiplayerManager.players[multiplayer.get_unique_id()].username = username
		lobby_scene.show_player(multiplayer.get_unique_id())
	elif GameManager.game_state != GameManager.game_state_enum.lobby:
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), false)
	else:
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), true)
		MultiplayerManager.players[multiplayer.get_remote_sender_id()] = PlayerData.new()
		MultiplayerManager.players[multiplayer.get_remote_sender_id()].username = username
		lobby_scene.show_player(multiplayer.get_remote_sender_id())
	if multiplayer.is_server():
		update_player_data.rpc(serialize(players))

@rpc("any_peer", "reliable")
func update_player_data(data):
	if !multiplayer.is_server():
		for player_id in data:
			players[player_id] = deserialize(data[player_id])
	var lobby_scene = get_node("/root/LobbyScene")
	if lobby_scene != null:
		lobby_scene.reset_player_data()

@rpc("any_peer", "reliable")
func join_setup(success: bool):
	if success:
		await GameManager.change_game_state(GameManager.game_state_enum.lobby, false)
		var lobby_scene = get_node("/root/LobbyScene")
		set_username(username)
		lobby_scene.reset_player_data()
	else:
		multiplayer.multiplayer_peer = null


func run_game():
	# Run creation screen
	GameManager.change_game_state.rpc(GameManager.game_state_enum.creation, false)
	await get_tree().create_timer(GameManager.creation_time).timeout

	# Get cards
	get_parent().get_node("Creation_Scene").export_card.rpc()

	print(cards)
	# Change to display
	GameManager.change_game_state.rpc(GameManager.game_state_enum.display, false)
	await get_tree().create_timer(0.5).timeout # Protects against the game state moving ahead too quickly
	for product in cards:
		get_tree().current_scene.display.rpc(product)
		await get_tree().create_timer(GameManager.presentation_time).timeout

	# Voting
	update_player_data.rpc(players)
	GameManager.change_game_state.rpc(GameManager.game_state_enum.voting, false)
	await get_tree().create_timer(20).timeout


	# Results
	GameManager.change_game_state.rpc(GameManager.game_state_enum.results, false)


func deserialize(data: Dictionary):
	var player = PlayerData.new()
	player.username = data["username"]
	player.score = data["score"]
	player.data = data["data"].deserialize() if data["data"] != null else null
	return player

func serialize(list: Dictionary):
	var ret = {}
	for player_id in list.keys():
		ret[player_id] = list[player_id].serialize()
	return ret
