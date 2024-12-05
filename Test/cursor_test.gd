extends Node2D

@onready var right: Button = $right
@onready var down: Button = $down
@onready var up: Button = $up
@onready var label: Label = $Label

const eraser_icon = preload("res://Assets/pencil.svg")

var offsetVector = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_pressed("Esc")):
		label.text = "Holding: " + str(offsetVector)
		Input.set_custom_mouse_cursor(null)
	else:
		label.text = str(offsetVector)
		Input.set_custom_mouse_cursor(eraser_icon, Input.CURSOR_ARROW, offsetVector)
	pass

func _on_left_pressed() -> void:
	offsetVector += Vector2(-1, 0)

func _on_right_pressed() -> void:
	offsetVector += Vector2(1, 0)

func _on_down_pressed() -> void:
	offsetVector += Vector2(0, -1)

func _on_up_pressed() -> void:
	offsetVector += Vector2(0, 1)
