extends Node2D

@export var drawing_scene: PackedScene
var drawing
func _start():
	preload("./Multiplayer_Menu.tscn")

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	drawing = drawing_scene.instantiate()
	get_parent().call_deferred("add_child", drawing)
