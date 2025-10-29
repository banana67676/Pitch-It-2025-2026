extends Timer

#grabs the player data from the PlayerData script
const PlayerData = preload("res://Scenes/Multiplayer Menu/PlayerData.gd")

#creating a peer for multiplayer usage
var peer = ENetMultiplayerPeer.new()

#variables for things
var cards = {}
var votes = {}
var score_card = {}
var players = {}
var username = ""

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
	print(players)
	GameManager.change_game_state(GameManager.game_state_enum.lobby, false) #change to lobby scene
	await GameManager.scene_changed #wait for scene to change
	username = usern #set username (this needs to stay here)
	set_username.rpc_id(1, usern) #calls the set_username function for the server to use
	
	#this defines an array of IP addresses to try and connect to
	#in this case, the only definition is "localhost", meaning it will only try to connect to a server on the same device
	#var ip_addresses = ["localhost"]
	#for i in ip_addresses:
		##print(i)
		#if !i.begins_with("f"):
			#peer.create_client(i, port.to_int()) #creates a client
			#multiplayer.multiplayer_peer = peer #it is now the connected peer
			#print(players)
			##if the signal isn't connected to the _on_conncted_ok() function, connect it to the function
			#if !multiplayer.connected_to_server.is_connected(_on_connected_ok):
				#multiplayer.connected_to_server.connect(_on_connected_ok)

#AFTER the client has successfully connected to the server
#func _on_connected_ok():
	##changes the game state to the lobby and waits until the scene has changed
	#GameManager.change_game_state(GameManager.game_state_enum.lobby, false)
	#await GameManager.scene_changed
	#set_username.rpc_id(1, username) #then it sets the username using the rpc function set_username

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
		update_player_data.rpc(serialize(players)) #updates the player list for all peers

#used to communicate between peers. This specific function can be called by any peer
#This function will be called for ALL connected peers (so the effects of the function are replicated to all peers)
@rpc("any_peer", "reliable")
func update_player_data(data):
	if !multiplayer.is_server(): #if client
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

#END OF DISCONNECTING FROM LOBBY
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF RUNNING THE GAME

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
