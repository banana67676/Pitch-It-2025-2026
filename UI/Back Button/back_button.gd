extends TextureButton

@export var initial_rotation: float
@export var final_rotation: float

const TWEEN_TIME: float = 0.5

func _on_mouse_entered() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(final_rotation), TWEEN_TIME)


func _on_mouse_exited() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(initial_rotation), TWEEN_TIME)
