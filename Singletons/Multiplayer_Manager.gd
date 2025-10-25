extends Timer

var peer = ENetMultiplayerPeer.new()

#grabs the player data from the PlayerData script
const PlayerData = preload("res://Scenes/Multiplayer Menu/PlayerData.gd")

#called when a client tries to join a server
func create_new_peer():
	if peer == null: #is only null after a client has disconnected from a previous server
		peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect("lobby_ready", continue_init)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#continues initilization by setting the player's username
func continue_init():
	set_username(username)

#initializes the server when a player makes a lobby
func init_server(port, usern):
	username = usern
	if port != null: #proceed if the port exists
		peer.create_server(port.to_int()) #create a server with the port as an integer
		multiplayer.multiplayer_peer = peer #registers the peer to the multiplayer
		multiplayer.peer_connected.connect(add_player) #a signal. Whenever a peer is connected to the lobby, the add_player function will be called
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #calls the change state function to switch the game state to the lobby
		
		#wait until the scene has changed to continue initilization
		await GameManager.scene_changed
		#while !get_parent().has_node("/root/LobbyScene"):
		#	await get_tree().create_timer(0.1).timeout
		#	pass
		#await get_tree().create_timer(5.0).timeout
		continue_init()

#variables for things
var cards = {}
var votes = {}
var score_card = {}
var players = {}
var username = ""

#unused function?
func add_player(id):
	pass

#function for other players to join the server
func join_server(port, usern):
	username = usern #set their username
	#print(port.to_int())
	#if the player isn't already in a multiplayer status and the port exists
	multiplayer.multiplayer_peer = null
	if multiplayer.multiplayer_peer == null && port.to_int() != null:
	
		#this defines an array of IP addresses to try and connect to
		#in this case, the only definition is "localhost", meaning it will only try to connect to a server on the same device
		var ip_addresses = ["localhost"]
		for i in ip_addresses:
			#print(i)
			if !i.begins_with("f"):
				peer.create_client(i, port.to_int()) #creates a client
				multiplayer.multiplayer_peer = peer #it is now the connected peer
				print(players)
				#if the signal isn't connected to the _on_conncted_ok() function, connect it to the function
				if !multiplayer.connected_to_server.is_connected(_on_connected_ok):
					multiplayer.connected_to_server.connect(_on_connected_ok)

func _on_connected_ok():
	#changes the game state to the lobby and waits until the scene has changed
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false)
	await GameManager.scene_changed
	set_username.rpc_id(1, username) #then it sets the username using the rpc function set_username

# The ID is automatically passed as an argument by the signal
func _on_peer_disconnected(id: int):
	# This 'id' is the unique ID of the client that just left.
	print("Client with ID " + str(id) + " disconnected.")
	# Use the ID to remove their data from your list
	if MultiplayerManager.players.has(id):
		print(str(peer.get_unique_id()) + " printed this line")
		print(players)
		rpc_remove_player.rpc(id) #remove the player for the server and ALL clients
		print(players)
		# You would also use this ID to remove their Node2D/Node3D representation from the scene
	else:
		print("Error: Disconnected ID not found in player list.")

#called by the client to disconnect themselves from the server
func disconnect_from_server():
	var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
	print("attempted to disconnect id " + str(peer.get_unique_id()))
	#multiplayer.multiplayer_peer.disconnect_peer(peer.get_unique_id())
	# Inside the client's disconnect_from_server() function:
	var self_id = multiplayer.get_unique_id() # Get the client's own ID
	if MultiplayerManager.players.has(self_id):
		MultiplayerManager.players.erase(self_id) # Remove self from local list
	lobby_scene.reset_player_data()
	multiplayer.multiplayer_peer = null
	peer = null
	print(players)

#this function is called by the server to tell the clients "Hey, I need you to remove players from your playerlist"
@rpc("call_local", "reliable")
func rpc_remove_player(id_to_remove: int):
	# This function will run on EVERY peer (including the server itself, due to "call_local")
	if MultiplayerManager.players.has(id_to_remove): #if the id exists, remove it
		MultiplayerManager.players.erase(id_to_remove)
		print("Peer " + str(multiplayer.get_unique_id()) + ": Removed player ID " + str(id_to_remove))
		print(str(peer.get_unique_id()) + " printed this line")
		var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
		lobby_scene.reset_player_data()

#function can be called by anyone in the network
#allows communication between multiple peers
@rpc("any_peer", "reliable")
func set_username(username: String):
	var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
	#if this function is called by the server, create its own username
	if multiplayer.get_remote_sender_id() == 0:
		#new player data added to the dictionary of players
		MultiplayerManager.players[multiplayer.get_unique_id()] = PlayerData.new()
		#sets the username for the server
		MultiplayerManager.players[multiplayer.get_unique_id()].username = username
		lobby_scene.show_player(multiplayer.get_unique_id()) #show the username in the lobby (this is the lobby host)
	#if the game is not currently in the lobby state
	elif GameManager.game_state != GameManager.game_state_enum.lobby:
		#call the rpc function join_setup
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), false)
	else:
		#call the rpc function join_setup (for the client)
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), true)
		MultiplayerManager.players[multiplayer.get_remote_sender_id()] = PlayerData.new() #new player data is added to the dictionary of players
		MultiplayerManager.players[multiplayer.get_remote_sender_id()].username = username #sets the players username based on their id
		lobby_scene.show_player(multiplayer.get_remote_sender_id()) #show the player in the lobby
	#if the current instance is the server
	if multiplayer.is_server():
		#send the clients an updated list of all the players in the game
		update_player_data.rpc(serialize(players))

#function can be called by anyone in the network
@rpc("any_peer", "reliable")
func update_player_data(data):
	#if client
	if !multiplayer.is_server():
		#for every player in the passed table/dictionary
		for player_id in data:
			#each player_id in the players table references a PlayerData object (not just flattened data)
			players[player_id] = deserialize(data[player_id]) #updates the players table with the recieved infromation in a readable format by deserializing
		cards = get_cards() #grab the cards
	var lobby_scene = get_parent().get_node("LobbyScene") #reference the lobby scene
	
	#if the lobby scene exists
	if lobby_scene != null:
		lobby_scene.reset_player_data() #reset the players data in the lobby scene
	else:
		print("lobby scene is null")

#function can be called by anyone in the network
@rpc("any_peer", "reliable")
func join_setup(success: bool):
	#if successful in joining the setup
	if success:
		GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #change state to the lobby state
		await GameManager.scene_changed #wait until the lobby is loaded
		var lobby_scene = get_parent().get_node("LobbyScene") #reference the lobby scene
		set_username(username) #set the username
		lobby_scene.reset_player_data() #reset player data?
	else:
		multiplayer.multiplayer_peer = null #if not successful, then there is no connected peer

#runs the game loop
func run_game_loop():
	#if this instance is the server
	if multiplayer.is_server():
		run_game() #run the game

#function can be called by anyone in the network
@rpc("any_peer", "reliable")
func run_game(): # Runs all of the phases of the game
	GameManager.change_game_state.rpc(GameManager.game_state_enum.creation, false)
	start(GameManager.creation_time) #starts the timer
	await self.timeout #wait until the time runs out

	#get cards
	get_parent().get_node("/root/Creation_Scene").export_card.rpc()
	while get_cards().size() < players.size():
		await get_tree().create_timer(0.5).timeout
	print(get_cards())
	#update_player_data.rpc(serialize(players))
	#Change to display ste
	GameManager.change_game_state.rpc(GameManager.game_state_enum.display, false)
	await get_tree().create_timer(2).timeout
	#grabs the cards
	cards = get_cards()
	for product in get_cards().values():
		get_parent().get_node("/root/DisplayScene").display_card.rpc(product.serialize())
		start(GameManager.presentation_time)
		await self.timeout

	# Voting
	update_player_data.rpc(serialize(players))
	#switch to the voting phase
	GameManager.change_game_state.rpc(GameManager.game_state_enum.voting, false)
	await get_tree().create_timer(20).timeout #timer for the voting phase

	get_parent().get_node("/root/VotingScene").send_vote.rpc()
	while votes.size() < players.size():
		await get_tree().create_timer(0.5).timeout

	#the voting calculations
	var round_results = {}
	for player in players.keys():
		round_results[player] = 0
	
	var has_winner = false
	for vote in votes.values():
		if vote == -1:
			continue
		round_results[vote] += 1
		MultiplayerManager.players[vote].score += 100000
		#if the player has more money than the money needed to win, they win
		if MultiplayerManager.players[vote].score >= GameManager.win_threshold: 
			has_winner = true
		
	# Results
	GameManager.change_game_state.rpc(GameManager.game_state_enum.results, false) #switch to the results phase
	await get_tree().create_timer(3).timeout 
	update_player_data.rpc(serialize(players))
	get_parent().get_node("/root/ResultsScene").show_scores.rpc(round_results) #shows the scores for the round
	await get_tree().create_timer(15).timeout #the timer for that phase
	
	#if somebody won, reset the game, otherwise continue playing the game
	if has_winner:
		reset.rpc()
	else:
		run_game()

	# Optional: Offer replay

#function can be called by anyone in the network
@rpc("any_peer", "call_local", "reliable")
func handle_display_pain(card: Dictionary):
	await GameManager.scene_changed
	get_parent().get_node("/root/DisplayScene").display_card(card) #displays the cards

#function can be called by anyone in the network
@rpc("any_peer","call_local","reliable")
func reset():
	GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, false) #back to the main menu
	multiplayer.multiplayer_peer.close() #disconnect
	await GameManager.scene_changed
	var home_scene = get_parent().get_node("/root/Multiplayer_Menu")
	home_scene.USERNAME_READ.text = username
	#reset variables
	cards = {}
	votes = {}
	score_card = {}
	players = {}

#function to deserialize the data
func deserialize(data: Dictionary):
	var player = PlayerData.new()
	player.username = data["username"]
	player.score = data["score"]
	player.data = PitchCardData.deserialize(data["data"]) if data["data"] != null else null
	return player

#function to serialize the provided data
func serialize(list: Dictionary):
	var ret = {}
	for player_id in list.keys():
		ret[player_id] = list[player_id].serialize()
	return ret

#function to grab the cards that the player had
func get_cards():
	var ret = {}
	for key in players.keys():
		ret[key] = players[key].data
	return ret

#function that can be called by anyone in the network
@rpc("any_peer", "call_local", "reliable")
#imports the cards
func import_card(pd: Dictionary):
	print(pd.keys())
	print(pd["user"])
	MultiplayerManager.players[multiplayer.get_remote_sender_id()].data = PitchCardData.deserialize(pd)
	print("data saved: " + str(MultiplayerManager.players[multiplayer.get_remote_sender_id()]))
