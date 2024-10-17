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
	shrinkTween.tween_property(self, "scale:x", 0, FLIP_TIME)
	shrinkTween.tween_callback(grow)
	currentSide.visible = false
	print("done shrinking")
	return shrinkTween

func grow():
	print("growing")
	print(self.scale.x)
	print("current side is ", currentSide)
	swap_current_side()
	var tween = create_tween()
	print("growing")
	state = growing
	currentSide.visible = true

	tween.tween_property(self, "scale:x", 1, FLIP_TIME)

func swap_current_side():
	print("swapping side was ", currentSide)
	if currentSide == back:
		currentSide = front
	elif currentSide == front:
		currentSide = back
	else:
		print("side is null")

func flip() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0, FLIP_TIME)
	tween.chain().tween_callback(grow)
	state = stay

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("card clicked")
		flip()
		# test()


func test():
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0, FLIP_TIME)
	tween.chain().tween_property(self, "scale:x", 1, FLIP_TIME)
	pass
