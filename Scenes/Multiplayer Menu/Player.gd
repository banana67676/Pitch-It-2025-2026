extends Node2D



func _enter_tree():
	set_multiplayer_authority(name.to_int())


func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		global_position = get_global_mouse_position()
