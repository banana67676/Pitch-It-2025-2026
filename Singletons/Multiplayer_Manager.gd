extends Timer

#grabs the player data from the PlayerData script
const PlayerData = preload("res://Scenes/Multiplayer Menu/PlayerData.gd")

signal display_ready

#variables for things
var cards = {}
var votes = {}
var score_card = {}
var players = {}
var username: String = ""
var done_players: int = 0
var is_gdsync_connected: bool = false
@onready var multiplayer_node = get_node("/root/MultiplayerManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_GDSync_signals()
	expose_functions()
	GDSync.start_multiplayer()

#exposes all functions that need to be exposed. This allows these functions to be called remotely
#GD-Sync's equivalent of @rpc calls
func expose_functions() -> void:
	GDSync.expose_func(import_card)
	GDSync.expose_func(reset)
	GDSync.expose_func(client_joined)
	GDSync.expose_func(update_player_list)
	GDSync.expose_func(remove_player_from_list)
	GDSync.expose_func(disconnect_client)

#---------------------------------------------------------------------------------------------------------------------------------

#initializes the server when a player makes a lobby
func init_server(usern):
	username = usern #set their username
	GDSync.lobby_create("Test Lobby")
	GDSync.lobby_join("Test Lobby")
	GameManager.change_game_state(GameManager.game_state_enum.lobby, true, 0.5) #calls the change state function to switch the game state to the lobby
	await GameManager.scene_changed #wait until the scene has changed
	client_joined(GDSync.get_client_id(), usern)


#function for other players to join the server
func join_server(usern):
	username = usern #set username
	GDSync.lobby_join("Test Lobby")
	print(GDSync.lobby_get_name())
	GameManager.change_game_state(GameManager.game_state_enum.lobby, true, 0.5) #change to lobby scene
	await GameManager.scene_changed #wait for scene to change
	GDSync.call_func_on(GDSync.get_host(), client_joined, [GDSync.get_client_id(), usern])


#when a client joins a lobby
func client_joined(joined_id: int, usern: String) -> void:
	if !GDSync.is_host(): #if you're not the host, return
		return
	#only for the server host:
	MultiplayerManager.players[joined_id] = PlayerData.new() #add player data to dictionary of players with their peerID as key, and their data as value
	MultiplayerManager.players[joined_id].username = usern #change their username in the dictionary
	if GameManager.game_state != GameManager.game_state_enum.lobby: #if not currently the lobby
		await GameManager.scene_changed #wait for it to be the lobby
	#serialize the data to compress it and make it easier to send across the internet
	GDSync.call_func(update_player_list, [serialize(players)]) #update the player list for all connected peers
	_lobby_scene_update() #update the player name visibility in the lobby scene


#the player_list argument is sent as serialized data (which is easier to send back and forth)
#it is deserialized here to be able to be read by the program
func update_player_list(player_list) -> void:
	for player_id in player_list: #for every player in the passed table/dictionary
		players[player_id] = deserialize(player_list[player_id]) #unpacks the sent data
	_lobby_scene_update() #update the player name visibility in the lobby scene


#END OF CREATING AND JOINING LOBBY
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF DISCONNECTING FROM LOBBY


#when a client wants to leave the lobby
func client_left() -> void:
	if GDSync.is_host():
		GDSync.call_func_all(disconnect_client) #disconnects EVERYONE
	else:
		GDSync.call_func(remove_player_from_list, [GDSync.get_client_id()])
		disconnect_client()


#removes a specific player from the player list and updates the lobby scene
func remove_player_from_list(client_id: int) -> void:
	print("ID " + str(client_id) + " disconnected")
	if MultiplayerManager.players.has(client_id):
		MultiplayerManager.players.erase(client_id)
		_lobby_scene_update()


#disconnects the client from the lobby
func disconnect_client() -> void:
	MultiplayerManager.players.clear()
	GameManager.change_game_state(GameManager.game_state_enum.game_opening, true, 0)
	await GameManager.scene_changed
	GDSync.lobby_leave()


#END OF DISCONNECTING FROM LOBBY
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF RUNNING THE GAME


#runs through the phases of the game
func run_game() -> void:
	if not GDSync.is_host():
		return #don't continue if not the host
	
	# CREATION PORTION
	GDSync.call_func_all(GameManager.change_game_state, [GameManager.game_state_enum.creation, false, 1])
	await GameManager.scene_changed #wait for scene to change
	start(GameManager.get_creation_time()) #starts the timer
	await self.timeout #wait until the timer runs out
	
	# DISPLAY PORTION
	var creation_scene = get_parent().get_node("/root/Creation_Scene")
	GDSync.call_func_all(creation_scene.export_card) #have every player compile and export their card (so the server can import)
	for i in range(MultiplayerManager.players.size()):
		await display_ready #wait for everyone to have exported their cards
	
	GDSync.call_func_all(GameManager.change_game_state, [GameManager.game_state_enum.display, false, 2]) #change to display scene
	cards = get_cards() #grab the product cards of each player in the meantime
	await GameManager.scene_changed #wait for scene to change
	await get_tree().create_timer(1).timeout #delay before going into the display (this is needed for some reason, makes no sense)
	
	for product in cards.values(): #for every product
		var display_scene = get_parent().get_node("/root/DisplayScene") #refernce display scene
		GDSync.call_func_all(display_scene.display_card, [product.serialize()]) #show the product
		start(GameManager.presentation_time) #start the timer
		await self.timeout #wait until the timer runs out
	
	# VOTING PORTION
	GDSync.call_func_all(GameManager.change_game_state, [GameManager.game_state_enum.voting, false, 1]) #switch to voting scene
	await GameManager.scene_changed #wait for scene to change
	start(GameManager.get_voting_time()) #start the timer
	await self.timeout #wait until the time runs out
	
	var voting_scene = get_parent().get_node("/root/VotingScene")
	GDSync.call_func_all(voting_scene.send_vote)
	#get_parent().get_node("/root/VotingScene").send_vote.rpc()
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
	GDSync.call_func_all(GameManager.change_game_state, [GameManager.game_state_enum.results, false, 1]) #switch to the results phase
	await GameManager.scene_changed
	await get_tree().create_timer(1).timeout
	var results_scene = get_parent().get_node("/root/ResultsScene")
	GDSync.call_func_all(results_scene.show_scores, [round_results])
	start(GameManager.results_time) #start the timer
	await self.timeout #wait until the time runs out
	#await get_tree().create_timer(3).timeout
	#update_player_data.rpc(serialize(players))
	#get_parent().get_node("/root/ResultsScene").show_scores.rpc(round_results) #shows the scores for the round
	#await get_tree().create_timer(15).timeout #the timer for that phase
	
	#if somebody won, reset the game, otherwise continue playing the game
	if has_winner:
		GDSync.call_func_all(reset)
	else:
		run_game()

	# Optional: Offer replay


#END OF RUNNING THE GAME
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF GDSYNC SIGNAL ASSIGNMENT AND MESSAGES


func connect_GDSync_signals() -> void:
	GDSync.connected.connect(connected) #connect the "connected" function to the "connected" signal
	GDSync.connection_failed.connect(connection_failed)
	
	#GDSync.lobby_created.connect(lobby_created)
	GDSync.lobby_creation_failed.connect(lobby_creation_failed)
	
	#GDSync.lobby_joined.connect(lobby_joined)
	GDSync.lobby_join_failed.connect(lobby_join_failed)
	
	#GDSync.client_joined.connect(client_joined)
	#GDSync.client_left.connect(client_left)


#when successfully connecting to a GD Sync server
func connected() -> void:
	print("Connected to server")
	is_gdsync_connected = true


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
func lobby_creation_failed(lobby_name: String, _error: int) -> void:
	print("Failed to create lobby with the name: " + lobby_name)
	#if error == ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
		#GDSync.lobby_join(lobby_name)


func lobby_joined(lobby_name: String) -> void:
	print("Successfully joined lobby with the name: " + lobby_name)


func lobby_join_failed(lobby_name: String, _error: int) -> void:
	print("Failed to join lobby with the name: " + lobby_name)


#END OF GDSYNC SIGNAL ASSIGNMENT AND MESSAGES
#------------------------------------------------------------------------------------------------------------------------------#
#--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--#
#------------------------------------------------------------------------------------------------------------------------------#
#START OF MISCELLANEOUS STUFF 


#resets the shown names of players in the lobby scene IF it's currently the lobby scene
func _lobby_scene_update() -> void:
	var current_scene = GameManager.get_current_scene() #grab the current scene
	if current_scene == GameManager.enum_to_scene(GameManager.game_state_enum.lobby): #if it's the lobby scene
		var lobby_scene = get_node("/root/LobbyScene") #make reference to the lobby scene
		lobby_scene.reset_shown_players() #reset the players data in the lobby scene


#resets game variables and send player back to the title screen
func reset() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, true, 0) #back to the main menu
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


#imports the cards of the other players after they send their data to the server
func import_card(player_data: PackedByteArray, player_id: int) -> void: #imports the cards
	MultiplayerManager.players[player_id].data = PitchCardData.deserialize(player_data)
	display_ready.emit()
