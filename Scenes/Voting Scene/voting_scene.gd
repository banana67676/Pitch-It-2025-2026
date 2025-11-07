extends Node2D

@onready var VoteOption = preload("res://Scenes/Voting Scene/VoteOption.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prepare(MultiplayerManager.cards.values())

func _process(_delta: float) -> void:
	if multiplayer.is_server():
		%TimeRemaining.text = str("Time remaining: ",round(MultiplayerManager.get_time_left()))

var selection = -1

func prepare(cards):
	var index: int = 0
	for card in cards:
		if card.user_id != multiplayer.get_unique_id():
			var vote_box = VoteOption.instantiate()
			vote_box.find_child("PlayerName").text = str(card.title, " ", card.username)
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
			button.text = "Invested"
			button.disabled = true

@rpc("any_peer", "call_local", "reliable")
func send_vote():
	import_vote.rpc(selection)

@rpc("any_peer", "call_local", "reliable")
func import_vote(vote: int):
	MultiplayerManager.votes[multiplayer.get_remote_sender_id()] = vote
