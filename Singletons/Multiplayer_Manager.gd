extends Timer

#grabs the player data from the PlayerData script
const PlayerData = preload("res://Scenes/Multiplayer Menu/PlayerData.gd")

#creating a peer for multiplayer usage
var peer

#variables for things
var cards = {}
var votes = {}
var score_card = {}
var players = {}
var username: String = ""
var done_players: int = 0
var host_id: int = 0
@onready var multiplayer_node = get_node("/root/MultiplayerManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_GDSync_signals()
	expose_functions()
	GDSync.start_multiplayer()

func connect_GDSync_signals() -> void:
	GDSync.connected.connect(connected) #connect the "connected" function to the "connected" signal
	GDSync.connection_failed.connect(connection_failed)
	
	GDSync.lobby_created.connect(lobby_created)
	GDSync.lobby_creation_failed.connect(lobby_creation_failed)
	
	GDSync.lobby_joined.connect(lobby_joined)
	GDSync.lobby_join_failed.connect(lobby_join_failed)

#exposes all functions that need to be exposed. This allows these functions to be called remotely
#GD-Sync's equivalent of @rpc calls
func expose_functions() -> void:
	GDSync.expose_func(set_remote_username)
	GDSync.expose_func(update_player_data)
	GDSync.expose_func(join_setup)
	GDSync.expose_func(rpc_remove_player)
	GDSync.expose_func(import_card)
	GDSync.expose_func(reset)

#when successfully connecting to a GD Sync server
func connected() -> void:
	print("Connected to server")

#when failing to connect to a GD Sync server
func connection_failed(error: int) -> void:
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			push_error("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			push_error("Unable to connect, please check your internet connection.")

#when successfully joining a lobby
func lobby_created(lobby_name: String) -> void:
	print("Created lobby with the name: " + lobby_name)

#when failing to join a lobby
func lobby_creation_failed(lobby_name: String, error: int) -> void:
	print("Failed to create lobby with the name: " + lobby_name)
	#if error == ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
		#GDSync.lobby_join(lobby_name)

func lobby_joined(lobby_name: String) -> void:
	print("Successfully joined lobby with the name: " + lobby_name)

func lobby_join_failed(lobby_name: String, _error: int) -> void:
	print("Failed to join lobby with the name: " + lobby_name)


#---------------------------------------------------------------------------------------------------------------------------

#called when a client tries to join a server
func create_new_peer() -> void:
	if peer == null: #is only null after a client has disconnected from a previous server
		peer = ENetMultiplayerPeer.new()

#initializes the server when a player makes a lobby
func init_server(port, usern):
	if port == null: #if the port doesn't exist, don't proceed
		return
	#peer = ENetMultiplayerPeer.new()
	#peer.create_server(port.to_int()) #create a server
	#multiplayer.multiplayer_peer = peer #registers the peer to the multiplayer
	GDSync.lobby_create("Test Lobby")
	GDSync.lobby_join("Test Lobby")
	print(GDSync.get_client_id())
	GDSync.set_gdsync_owner(multiplayer_node, GDSync.get_client_id())
	#print(GDSync.get_gdsync_owner(multiplayer_node))
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #calls the change state function to switch the game state to the lobby
	await GameManager.scene_changed #wait until the scene has changed
	username = usern #set their username
	set_remote_username(usern) #then set their username for all other players
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected) #connects the function to allow peers to disconnect


#function for other players to join the server
func join_server(port, usern):
	if port == null: #if the port doesn't exist, don't proceed
		return
	#peer.create_client("localhost", port.to_int()) #creates a client (replace "localhost" with IP address to connect to)
	#multiplayer.multiplayer_peer = peer #it is now the connected peer
	GDSync.lobby_join("Test Lobby")
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #change to lobby scene
	await GameManager.scene_changed #wait for scene to change
	MultiplayerManager.players.clear()
	username = usern #set username
	GDSync.call_func_on(GDSync.get_host(), set_remote_username, [usern])
	#set_remote_username.rpc_id(1, usern) #calls the set_remote_username function for the server to use
	#multiplayer.server_disconnected.connect(disconnect_everyone) #connects the function to allow peers to disconnect


#This function will be called for ALL connected peers when called with .rpc (so the effects of the function are replicated to all peers)
#this specific function sets the players username for the other people in the lobby
@rpc("any_peer", "reliable")
func set_remote_username(usern: String) -> void:
	#remote sender is the client that just joined
	var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
	#if this function is called by any client
	var sender_id = GDSync.get_sender_id()
	print(sender_id)
	print(GDSync.get_host())
	#var current_id = GDSync.get_client_id()
	if sender_id == GDSync.get_host(): #server is usually id = 1, but here is id = 0 for some reason
		MultiplayerManager.players[GDSync.get_client_id()] = PlayerData.new() #add player data to dictionary of players with their peerID as key, and their data as value
		MultiplayerManager.players[GDSync.get_client_id()].username = usern #change their username in the dictionary
		lobby_scene.show_player(GDSync.get_client_id()) #show the username in the lobby (this is the lobby host)
		print("Server called")
		
	else: #if this function is called by the server
		GDSync.call_func_on(sender_id, join_setup)
		#join_setup.rpc_id(multiplayer.get_remote_sender_id()) #have the client join the lobby
		MultiplayerManager.players[sender_id] = PlayerData.new() #new player data is added to the dictionary of players (key is their peerID)
		MultiplayerManager.players[sender_id].username = usern #sets the players username
		lobby_scene.show_player(sender_id) #show the player in the lobby
		print("Client called")
		
	#if the current instance is the server. update their data
	#for some reason, having this code under a separate if statement that checks if the isntance is the server causes it to work,
	#but putting it under the "else" portion directly above causes it to break, and it makes no sense, since BOTH ARE THE SERVER
	if GDSync.get_sender_id() == GDSync.get_host():
		GDSync.call_func_all(update_player_data, [MultiplayerManager.players])
		print("Server part 2")
		#update_player_data.rpc(serialize(MultiplayerManager.players)) #updates the player list for all peers


#used to communicate between peers. This specific function can be called by any peer
#This function will be called for ALL connected peers (so the effects of the function are replicated to all peers)
@rpc("any_peer", "reliable", "call_local")
func update_player_data(data) -> void:
	if !multiplayer.is_server(): #if client
		for player_id in data: #for every player in the passed table/dictionary
			#each player_id in the players table references a PlayerData object (not just flattened data)
			players[player_id] = deserialize(data[player_id]) #updates the players table with the recieved infromation in a readable format by deserializing
	cards = get_cards() #grab the product cards that the players created
	_lobby_scene_reset() #if it's currently the lobby scene, reset the shown player names

#used to communicate between peers. This specific function can be called by any peer
#This function will be called for ALL connected peers (so the effects of the function are replicated to all peers)
@rpc("any_peer", "reliable")
func join_setup() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #change state to the lobby state
	await GameManager.scene_changed #wait until the lobby is loaded
	var lobby_scene = get_parent().get_node("LobbyScene") #reference the lobby scene
	set_remote_username(username) #set the username
	lobby_scene.reset_player_data() #reset player data?

#END OF CREATING/JOINING LOBBY STUFF
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF DISCONNECTING FROM LOBBY

# The ID is automatically passed as an argument by the signal
func _on_peer_disconnected(id: int) -> void:
	#the paramater "id" is the unqiue ID of the client that just disconnected
	print("Client with ID " + str(id) + " disconnected.")
	if MultiplayerManager.players.has(id): #if the player exists in the playerlist
		rpc_remove_player.rpc(id) #remove the player for the server and ALL clients
	else:
		print("Error: Disconnected ID not found in player list.")

#called by the client to disconnect themselves from the server
func disconnect_from_server() -> void:
	if multiplayer.is_server(): #disconnecting the server itself
		MultiplayerManager.players.clear() #clear the player list
		peer.close() #close the connection
		GameManager.change_game_state(GameManager.game_state_enum.title,false) #switch to title scene
		
	else: #disconnecting the client
		var self_id = multiplayer.get_unique_id() # Get the client's own ID
		#the following if-statement is a visual for the disconnecting player's name disappearing from the player list
		if MultiplayerManager.players.has(self_id):
			MultiplayerManager.players.erase(self_id) # Remove self from local list
		
		_lobby_scene_reset() #if it's currently the lobby scene, reset the shown player names
		MultiplayerManager.players.clear() #then clear the list
		multiplayer.multiplayer_peer = null
		peer = null
		GameManager.change_game_state(GameManager.game_state_enum.title,false)

#this function is called by the server to tell the clients "Hey, I need you to remove this player from your playerlist"
@rpc("call_local", "reliable")
func rpc_remove_player(id_to_remove: int) -> void:
	# This function will run on EVERY peer (including the server itself, due to "call_local")
	if MultiplayerManager.players.has(id_to_remove): #if the id exists, remove it
		MultiplayerManager.players.erase(id_to_remove)
		_lobby_scene_reset() #if it's currently the lobby scene, reset the shown player names

#disconnect everyone
func disconnect_everyone() -> void:
	print("Server host disconnected")
	MultiplayerManager.players.clear() #clear the player list dictionary
	_lobby_scene_reset() #if it's currently the lobby scene, reset the shown player names
	multiplayer.multiplayer_peer = null
	peer = null
	GameManager.change_game_state(GameManager.game_state_enum.title, false)

#END OF DISCONNECTING FROM LOBBY
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF RUNNING THE GAME

#runs the game loop
func run_game_loop() -> void:
	if multiplayer.is_server(): #if this instance is the server
		run_game() #run the game

#function can be called by anyone in the network and will be replicated by everyone in the network
#@rpc("any_peer", "reliable")
func run_game() -> void: # Runs all of the phases of the game
	
	# CREATION PORTION
	GameManager.delayed_change_game_state.rpc(GameManager.game_state_enum.creation, false, 1.6, 0)
	await GameManager.scene_changed #wait for scene to change
	start(GameManager.creation_time) #starts the timer
	await self.timeout #wait until the timer runs out
	
	# DISPLAY PORTION
	get_parent().get_node("/root/Creation_Scene").export_card.rpc() #get the product cards that the players made
	GameManager.delayed_change_game_state.rpc(GameManager.game_state_enum.display, false, 0.5, 2.8) #change to display scene
	#cards = get_cards()
	#update_player_data.rpc(serialize(players))
	await GameManager.scene_changed #wait for scene to change
	update_player_data.rpc(serialize(players))
	#print("Cards:")
	print(cards)
	print("Too Late")
	
	await get_tree().create_timer(3.5).timeout #the delay before going into the display
	for product in cards.values(): #for every product
		#print("Product:")
		#print(product)
		get_parent().get_node("/root/DisplayScene").display_card.rpc(product.serialize()) #show the product
		start(GameManager.presentation_time) #start the timer
		await self.timeout #wait until the timer runs out
	
	# VOTING PORTION
	GameManager.delayed_change_game_state.rpc(GameManager.game_state_enum.voting, false, 0.8, 0)
	update_player_data.rpc(serialize(players))
	await GameManager.scene_changed #wait for scene to change
	start(GameManager.voting_time) #start the timer
	await self.timeout #wait until the time runs out
	
	get_parent().get_node("/root/VotingScene").send_vote.rpc()
	#while votes.size() < players.size():
		#await get_tree().create_timer(0.5).timeout
	
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
		
	# RESULTS
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

#END OF RUNNING THE GAME
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF MISCELLANEOUS STUFF 

#resets the shown names of players in the lobby scene IF it's currently the lobby scene
func _lobby_scene_reset() -> void:
	var current_scene = GameManager.get_current_scene() #grab the current scene
	if current_scene == GameManager.enum_to_scene(GameManager.game_state_enum.lobby): #if it's the lobby scene
		var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
		lobby_scene.reset_player_data() #reset the players data in the lobby scene

#resets the game for everyone
@rpc("any_peer","call_local","reliable")
func reset() -> void:
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

#function to grab the card (which is the product) that the player created
func get_cards():
	var ret = {}
	for key in players.keys(): #for every user id
		ret[key] = players[key].data #index of user id = the data for the player
	return ret

#function that can be called by anyone in the network
@rpc("any_peer", "call_local", "reliable")
func import_card(pd: Dictionary) -> void: #imports the cards
	#print(pd.keys())
	#print(pd["user"])
	print("Part 2 Called by:")
	print(multiplayer.get_remote_sender_id())
	print()
	MultiplayerManager.players[multiplayer.get_remote_sender_id()].data = PitchCardData.deserialize(pd)
	#print("data saved: " + str(MultiplayerManager.players[multiplayer.get_remote_sender_id()]))
