extends Node2D

var linkedNode
var lines = []
var points = []

func placeLineNode() -> void:
	if linkedNode != null:
		if linkedNode.get_point_count() == 0:
			linkedNode.free()
		elif linkedNode.get_point_count() == 1:
			linkedNode.add_point(linkedNode.get_point(0)+Vector2(1,1))
	linkedNode = Line2D.new()
	linkedNode.joint_mode = Line2D.LINE_JOINT_ROUND
	$Node2D.add_child(linkedNode)
	pass

var markerSet = []
#var drawing_unit = preload("res://drawing_unit.tscn")
var collShape
var collCirc

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("Mouse Click"):
		if markerSet.size() == 0 || markerSet[markerSet.size() - 1].global_position != get_global_mouse_position():
			#var draw_instance = drawing_unit.instantiate()
			#draw_instance.global_position = get_global_mouse_position()
			points.append(get_global_mouse_position())
			linkedNode.add_point(get_global_mouse_position())
			#add_child(draw_instance)
	if Input.is_action_just_released("Mouse Click"):
		placeLineNode()
	pass

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	placeLineNode()
