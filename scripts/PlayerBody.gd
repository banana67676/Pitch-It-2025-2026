extends Node2D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if is_multiplayer_authority():
		global_position = get_global_mouse_position()
