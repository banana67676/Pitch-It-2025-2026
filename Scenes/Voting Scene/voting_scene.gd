extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var selection = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func prepare(cards : Array[PitchCardData]):
	var index = 0
	for card in cards:
		var disp = Label.new()
		disp.text = str(card.title," ",card.slogan, " ",MultiplayerManager.players[card.user_id].username)
		disp.global_position = Vector2(50,index*150+150)
		var button = Button.new()
		button.text = "Invest $100,000"
		button.global_position = Vector2(250,index*150+150)
		button.connect("on_pressed", lock.bind(card.user_id))
		disp.add_child(button)
		$List.add_child(disp)
		index+=1

func lock(user_id):
	selection = user_id
	for button in $List.get_children():
		button.disabled=true

@rpc("any_peer", "call_local", "reliable")
func send_vote():
	import_vote.rpc(selection)

@rpc("authority", "reliable")
func import_vote(vote : int):
	MultiplayerManager.votes[multiplayer.get_remote_sender_id()] = vote
