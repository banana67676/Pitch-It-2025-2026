extends Node2D


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouse:
		get_tree().change_scene_to_file("res://Scenes/Multiplayer Menu/Multiplayer_Menu.tscn") 
		
