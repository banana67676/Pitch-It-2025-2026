extends Node2D

@onready var VoteOption = preload("res://Scenes/Voting Scene/VoteOption.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.expose_func(send_vote)
	GDSync.expose_func(import_vote)
	prepare(MultiplayerManager.cards.values())

var selection = -1

func prepare(cards):
	@warning_ignore("unused_variable")
	var index: int = 0
	#the card is the product that the user made bro...
	for card in cards:
		if card.user_id != multiplayer.get_unique_id():
			var vote_box = VoteOption.instantiate()
			vote_box.find_child("ProductName").text = str(card.title) #find the ProductName label and change its text to the product
			vote_box.find_child("PlayerName").text = "By: " + str(card.username) #find the PlayerName label and change its text to the username
			
			#vote_box.find_child("PlayerName").text = "Product: " + str(card.title) + " | By: " + str(card.username) + "'s"
			#disp.get_child(0).get_child(0).text = str(card.title, " ", card.username)
			var button = vote_box.find_child("VoteButton")
			button.toggle_mode = true
			button.text = "Invest $100,000"
			button.connect("pressed", lock.bind(card.user_id))
			%VotingContainer.add_child(vote_box)
			index += 1

func lock(user_id):
	selection = user_id
	var children = []
	for sect in %VotingContainer.get_children():
		children.append(sect.get_child(1))
	for button in children:
		if button is Button:
			#button.text = "Invested"
			button.disabled = true

@rpc("any_peer", "call_local", "reliable")
func send_vote():
	GDSync.call_func_all(import_vote, [selection])

@rpc("any_peer", "call_local", "reliable")
func import_vote(vote: int):
	MultiplayerManager.votes[multiplayer.get_remote_sender_id()] = vote
