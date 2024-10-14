extends Node2D

@export var FLIP_TIME = .5

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

func shrink():
	var shrinkTween = create_tween()
	print("start tween")
	shrinkTween.tween_property(
		self, "scale:x", -.1,
		FLIP_TIME
	)
	await shrinkTween.finished
	print("end tween")
	currentSide.visible = false
	print("disabled ${currentSide}")
	swap_current_side()
	state = growing
	print("swapped state")

func grow():
	var growTween = create_tween()
	print("growing")
	currentSide.visible = true
	growTween.tween_property(
		self, "scale:x", 1,
		FLIP_TIME
	)
	print("done growing")
	await growTween.finished
	swap_current_side()
	state = stay
	
	

func swap_current_side():
	if(currentSide == back):
		currentSide = front
	elif(currentSide == front):
		currentSide = back
	else:
		print("side is null")


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("card clicked")
		state = shrinking
