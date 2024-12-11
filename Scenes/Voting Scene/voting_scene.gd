extends Node2D

@onready var VoteOption = preload("res://Scenes/Voting Scene/VoteOption.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prepare(MultiplayerManager.cards.values())
	pass # Replace with function body.

var selection = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func prepare(cards):
	var index = 0
	for card in cards:
		if card.user_id != multiplayer.get_unique_id():
			var disp = VoteOption.instantiate()
			disp.get_child(0).get_child(0).text = str(card.title, " ", card.username)
			var button = disp.get_child(0).get_child(1)
			button.toggle_mode = true
			button.text = "Invest $100,000"
			button.connect("pressed", lock.bind(card.user_id))
			$VBoxContainer.add_child(disp)
			index += 1

func lock(user_id):
	selection = user_id
	var children = []
	for sect in $VBoxContainer.get_children():
		children.append(sect.get_child(1))
	for button in children:
		if button is Button:
				button.disabled = true

@rpc("any_peer", "call_local", "reliable")
func send_vote():
	import_vote.rpc(selection)

@rpc("any_peer", "call_local", "reliable")
func import_vote(vote: int):
	MultiplayerManager.votes[multiplayer.get_remote_sender_id()] = vote
