extends Control

@onready var VoteOption = preload("res://Scenes/Voting Scene/VoteOption.tscn")
var selection = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.expose_func(send_vote)
	GDSync.expose_func(import_vote)
	prepare(MultiplayerManager.cards.values())


#prepares the voteboxes for each product
func prepare(cards) -> void:
	for card: PitchCardData in cards: #for each product card
		if card.user_id != GDSync.get_client_id():
			var vote_box = VoteOption.instantiate() #make a new votebox
			vote_box.name = str(card.user_id) #set its name to the player's user id
			vote_box.find_child("ProductName").text = str(card.title) #find the ProductName label and change its text to the product
			vote_box.find_child("PlayerName").text = "By: " + str(card.username) #find the PlayerName label and change its text to the username
			var button = vote_box.find_child("VoteButton") #find the Vote Button
			button.toggle_mode = true #set toggle mode to true
			button.connect("pressed", lock.bind(card.user_id)) #attach the lock function to be called when the button is pressed
			%VotingContainer.add_child(vote_box) #add the votebox to the grid container containg the vote boxes


#whenever a button is pressed, this function is called. The user id for the button has been binded
#meaning it is set it stone. It will ALWAYS be the user_id that was assigned to the specific button
func lock(user_id) -> void:
	if selection != -1: #only if no voting selection has been made
		return
	
	selection = user_id
	for vote_box: PanelContainer in %VotingContainer.get_children():
		var button = vote_box.find_child("VoteButton")
		if int(vote_box.name) == user_id:
			_change_theme_to_voted(vote_box)
		button.disabled = true


func send_vote():
	GDSync.call_func_all(import_vote, [selection, GDSync.get_client_id()])


func import_vote(voted_id: int, sender_id: int):
	MultiplayerManager.votes[sender_id] = voted_id


func _change_theme_to_voted(vote_box: PanelContainer) -> void:
	var YELLOW_COLOR: Color = Color.from_rgba8(240, 221, 12, 150)
	var RED_COLOR: Color = Color.from_rgba8(153, 29, 35, 255)
	
	#background of panel container modifications
	var stylebox = StyleBoxFlat.new() #stylebox to change the background color of the card
	stylebox.bg_color = YELLOW_COLOR
	stylebox.set_corner_radius_all(20) #setting the corner radius for all corners
	vote_box.add_theme_stylebox_override(&"panel", stylebox) #changing the background color
	
	#player name text label modifications
	var label: Label = vote_box.find_child("PlayerName")
	label.add_theme_color_override("font_color", RED_COLOR)
	
	#button modifications
	var button: Button = vote_box.find_child("VoteButton")
	button.theme_type_variation = "ButtonSmallRed"
	button.text = "Invested"
