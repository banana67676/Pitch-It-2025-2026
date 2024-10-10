extends Node2D

@export var drawing_scene: PackedScene
var drawing
func _start():
	preload("../scenes/Multiplayer_Menu.tscn")

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	drawing = drawing_scene.instantiate()
	get_parent().call_deferred("add_child", drawing)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if is_multiplayer_authority():
		global_position = get_global_mouse_position()
