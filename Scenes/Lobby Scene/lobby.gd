extends Node

#preloads
const MM = preload("res://Singletons/Multiplayer_Manager.gd")
const theme = preload("res://Assets/Font.tres")

#node references
@onready var player_list: GridContainer = %PlayerList
@onready var player_name_template: PanelContainer = $PlayerNameTemplate

#signals
signal lobby_ready

#values
var player_count : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		lobby_ready.emit()
		pass
	else:
		%Begin.visible = false
	pass # Replace with function body.

func show_player(id):
	var player_box = player_name_template.duplicate()
	var player_name = player_box.get_node("Padding/Name") #the actual label for the player
	player_name.text = MultiplayerManager.players[id].username #the text equals their chosen username
	player_list.add_child(player_box) #adds the child to the node displaying the list
	player_box.visible = true #making the label visible
	player_count += 1 #increase player count
	#var player_label = Label.new()
	#player_label.text = MultiplayerManager.players[id].username
	#$PlayerList.add_child(player_label)
	#player_label.set_global_position(Vector2(200+250*(player_count % 3), 150+50*(int(player_count) / 3)))
	#player_count += 1
	pass


func reset_player_data():
	for player in %PlayerList.get_children():
		remove_child(player)
		player.queue_free()
	player_count = 0
	#player is the key (their user id)
	for player in MultiplayerManager.players:
		var player_box = player_name_template.duplicate()
		player_box.name = str(player) #make the label name their player id as a string
		var player_name = player_box.get_node("Padding/Name") #the actual label for the player
		player_name.text = MultiplayerManager.players[player].username #the text equals their chosen username
		player_list.add_child(player_box) #adds the child to the node displaying the list
		player_box.visible = true #making the label visible
		player_count += 1 #increase player count
		#var player_label : Label = Label.new() #new label (to display them in the lobby)
		#player_label.name = str(player) #make the label name their player id as a string
		#player_label.theme = theme #set the labels theme
		#player_label.text = MultiplayerManager.players[player].username #the text equals their chosen username
		#$PlayerList.add_child(player_label) #adds the child to the node handling the list
		#player_label.set_global_position(Vector2(200+250*(player_count % 3), 150+50*(int(player_count) / 3))) #set pos
		#player_count += 1 #increase player count
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.change_game_state(GameManager.game_state_enum.multiplayer_main_menu, true)

func _on_begin_pressed() -> void:
	print("pressed")
	MultiplayerManager.run_game_loop()
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	GameManager.change_game_state(GameManager.game_state_enum.title,false)
	MultiplayerManager.disconnect_from_server()
	#reset_player_data()
