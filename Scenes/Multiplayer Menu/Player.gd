extends Node2D

@export var creation_scene = preload("res://Scenes/Creation Scene/Creation_Scene.tscn")
var creation
func _start():
	preload("./Multiplayer_Menu.tscn")

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	creation = creation_scene.instantiate()
	get_parent().call_deferred("add_child", creation)
