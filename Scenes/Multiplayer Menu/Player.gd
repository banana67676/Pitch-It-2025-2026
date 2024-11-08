extends Node2D

func _start():
	preload("./Multiplayer_Menu.tscn")

func _enter_tree():
	set_multiplayer_authority(name.to_int())
