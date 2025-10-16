extends Node2D

const WIDTH = 800
const HEIGHT = 600


@onready var who: CharacterBody2D = $Who
@onready var what: CharacterBody2D = $What


var moving_cards_flag : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(.5).timeout
	moving_cards_flag = true
	
	#await get_tree().create_timer(GameManager.get_round_time()).timeout
	
	#GameManager.change_game_state(GameManager.game_state_enum.display, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving_cards_flag:
		who.move(Vector2(860,220), PI/32)
		what.move(Vector2(860,400), -PI/32)
	if multiplayer.is_server():
		$Label.text = str("Time remaining: ",round(MultiplayerManager.get_time_left()))
	

@rpc("any_peer", "call_local", "reliable") # Authority should be able to request this
func export_card():
	var data = PitchCardData.new()
	data.title = %Title.text
	data.slogan = %Slogan.text
	data.logo = $MarginContainer/VSplitContainer/HSplitContainer/DrawingScene.image
	data.user_id = multiplayer.get_unique_id()
	data.username = MultiplayerManager.username
	$MarginContainer/VSplitContainer/HSplitContainer/DrawingScene.enabled = false
	var sData = data.serialize()
	print(MultiplayerManager.username + "sent")
	MultiplayerManager.import_card.rpc_id(1,sData)



func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("Esc"):
		GameManager.quit_game(true)
