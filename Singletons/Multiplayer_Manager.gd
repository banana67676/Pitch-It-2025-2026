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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#multiplayer.multiplayer_peer = peer
	pass

#called when a client tries to join a server
func create_new_peer():
	if peer == null: #is only null after a client has disconnected from a previous server
		peer = ENetMultiplayerPeer.new()

#initializes the server when a player makes a lobby
func init_server(port, usern):
	if port == null: #if the port doesn't exist, don't proceed
		return
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port.to_int()) #create a server
	multiplayer.multiplayer_peer = peer #registers the peer to the multiplayer
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #calls the change state function to switch the game state to the lobby
	await GameManager.scene_changed #wait until the scene has changed
	set_username(usern) #then set the player's username
	multiplayer.peer_disconnected.connect(_on_peer_disconnected) #connects the function to allow peers to disconnect

#function for other players to join the server
func join_server(port, usern):
	if port == null: #if the port doesn't exist, don't proceed
		return
	peer.create_client("localhost", port.to_int()) #creates a client (replace "localhost" with IP address to connect to)
	multiplayer.multiplayer_peer = peer #it is now the connected peer
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #change to lobby scene
	await GameManager.scene_changed #wait for scene to change
	MultiplayerManager.players.clear()
	username = usern #set username (this needs to stay here)
	set_username.rpc_id(1, usern) #calls the set_username function for the server to use
	multiplayer.server_disconnected.connect(disconnect_everyone) #connects the function to allow peers to disconnect

#used to communicate between peers. This specific function can be called by any peer
#This function will be called for ALL connected peers (so the effects of the function are replicated to all peers)
@rpc("any_peer", "reliable")
func set_username(usern: String):
	username = usern #set their username
	var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
	#if this function is called by the server, create its own username
	if multiplayer.get_remote_sender_id() == 0:
		MultiplayerManager.players[multiplayer.get_unique_id()] = PlayerData.new() #add player data to dictionary of players with their peerID as key, and their data as value
		MultiplayerManager.players[multiplayer.get_unique_id()].username = usern #change their username in the dictionary
		lobby_scene.show_player(multiplayer.get_unique_id()) #show the username in the lobby (this is the lobby host)
	
	#if the game is not currently in the lobby state
	elif GameManager.game_state != GameManager.game_state_enum.lobby:
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), false) #call the rpc function join_setup
		print("NOT IN LOBBY STATE. CHECK LINE 86 IN MULTIPLAYER MANAGER")
	
	else:
		#call the rpc function join_setup (for the client)
		join_setup.rpc_id(multiplayer.get_remote_sender_id(), true)
		MultiplayerManager.players[multiplayer.get_remote_sender_id()] = PlayerData.new() #new player data is added to the dictionary of players (key is their peerID)
		MultiplayerManager.players[multiplayer.get_remote_sender_id()].username = usern #sets the players username
		lobby_scene.show_player(multiplayer.get_remote_sender_id()) #show the player in the lobby
	
	#if the current instance is the server
	if multiplayer.is_server():
		update_player_data.rpc(serialize(MultiplayerManager.players)) #updates the player list for all peers

#used to communicate between peers. This specific function can be called by any peer
#This function will be called for ALL connected peers (so the effects of the function are replicated to all peers)
@rpc("any_peer", "reliable", "call_local")
func update_player_data(data):
	if !multiplayer.is_server(): #if client
		for player_id in data: #for every player in the passed table/dictionary
			#each player_id in the players table references a PlayerData object (not just flattened data)
			players[player_id] = deserialize(data[player_id]) #updates the players table with the recieved infromation in a readable format by deserializing
	cards = get_cards() #grab the product cards that the players created
	_lobby_scene_reset() #if it's currently the lobby scene, reset the shown player names

#used to communicate between peers. This specific function can be called by any peer
#This function will be called for ALL connected peers (so the effects of the function are replicated to all peers)
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

#END OF CREATING/JOINING LOBBY STUFF
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF DISCONNECTING FROM LOBBY

# The ID is automatically passed as an argument by the signal
func _on_peer_disconnected(id: int):
	#the paramater "id" is the unqiue ID of the client that just disconnected
	print("Client with ID " + str(id) + " disconnected.")
	if MultiplayerManager.players.has(id): #if the player exists in the playerlist
		rpc_remove_player.rpc(id) #remove the player for the server and ALL clients
	else:
		print("Error: Disconnected ID not found in player list.")

#called by the client to disconnect themselves from the server
func disconnect_from_server():
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
func rpc_remove_player(id_to_remove: int):
	# This function will run on EVERY peer (including the server itself, due to "call_local")
	if MultiplayerManager.players.has(id_to_remove): #if the id exists, remove it
		MultiplayerManager.players.erase(id_to_remove)
		_lobby_scene_reset() #if it's currently the lobby scene, reset the shown player names

#disconnect everyone
func disconnect_everyone():
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
func run_game_loop():
	if multiplayer.is_server(): #if this instance is the server
		run_game() #run the game

#function can be called by anyone in the network and will be replicated by everyone in the network
#@rpc("any_peer", "reliable")
func run_game(): # Runs all of the phases of the game
	
	# CREATION PORTION
	GameManager.delayed_change_game_state.rpc(GameManager.game_state_enum.creation, false, 0.8, 0.8)
	await GameManager.scene_changed #wait for scene to change
	start(GameManager.get_creation_time()) #starts the timer
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
		start(GameManager.get_presentation_time()) #start the timer
		await self.timeout #wait until the timer runs out
	
	# VOTING PORTION
	GameManager.delayed_change_game_state.rpc(GameManager.game_state_enum.voting, false, 0.8, 0)
	update_player_data.rpc(serialize(players))
	await GameManager.scene_changed #wait for scene to change
	start(GameManager.get_voting_time()) #start the timer
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
func _lobby_scene_reset():
	var current_scene = GameManager.get_current_scene() #grab the current scene
	if current_scene == GameManager.enum_to_scene(GameManager.game_state_enum.lobby): #if it's the lobby scene
		var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
		lobby_scene.reset_player_data() #reset the players data in the lobby scene

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

#function to grab the card (which is the product) that the player created
func get_cards():
	var ret = {}
	for key in players.keys(): #for every user id
		ret[key] = players[key].data #index of user id = the data for the player
	return ret

#function that can be called by anyone in the network
@rpc("any_peer", "call_local", "reliable")
func import_card(pd: Dictionary): #imports the cards
	#print(pd.keys())
	#print(pd["user"])
	print("Part 2 Called by:")
	print(multiplayer.get_remote_sender_id())
	print()
	MultiplayerManager.players[multiplayer.get_remote_sender_id()].data = PitchCardData.deserialize(pd)
	#print("data saved: " + str(MultiplayerManager.players[multiplayer.get_remote_sender_id()]))
