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
	pass


func shrink() -> Tween:
	print("shrinking")
	var shrinkTween = create_tween()
	shrinkTween.tween_property(
	self, "scale:x", 0,
		FLIP_TIME
	)
	currentSide.visible = false
	print("done shrinking")
	return shrinkTween


func grow() -> Tween:
	print("growing")
	currentSide.visible = true
	var growTween = create_tween()
	growTween.tween_property(
	self, "scale:x", 1,
		FLIP_TIME
	)
	print("done growing?")
	return growTween
	

func swap_current_side():
	if (currentSide == back):
		currentSide = front
	elif (currentSide == front):
		currentSide = back
	else:
		print("side is null")

func flip():
	state = shrinking
	await shrink()
	print("actually done growing")
	
	grow()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("card clicked")
		#state = shrinking
		flip()
