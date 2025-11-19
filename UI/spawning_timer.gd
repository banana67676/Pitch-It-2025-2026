extends MultiplayerSpawner

@export var attached_timer: PackedScene

func _ready() -> void:
	_spawn_timer()

func _spawn_timer() -> void:
	if multiplayer.is_server():
		var timer = attached_timer.instantiate()
		get_node(spawn_path).add_child(timer, true)
		#get_node(spawn_path).call_deferred("add_child", timer)
