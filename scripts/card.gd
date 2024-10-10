extends Node2D

@onready var timer: Timer = $FlipTimer


@onready var front: Node2D = $Front
@onready var back: Node2D = $Back

@onready var currentSide = back

enum {
	stay,
	shrinking,
	growing
}
var state = stay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(state == shrinking):
		shrink()
	if(state == growing):
		grow()

func _on_button_pressed() -> void:
	print("button pressed")
	state = shrinking
	

func shrink():
	var tween = create_tween()
	tween.tween_property(
		self, "scale:y", 0,
		1
	)
	currentSide.visible = false
	swap_current_side()
	state = growing
	print("swapped state")

func grow():
	var tween = create_tween()
	
	tween.tween_property(
		self, "scale:y", 1,
		1
	)
	
	await tween.finished
	
	

func swap_current_side():
	if(currentSide == back):
		currentSide = front
	elif(currentSide == front):
		currentSide = back
	else:
		print("side is null")
