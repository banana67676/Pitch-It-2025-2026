extends TextureButton

var is_just_clicked: bool = false
const TWEEN_TIME: float = 0.75


func _on_pressed() -> void:
	is_just_clicked = true
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(360), TWEEN_TIME)
	await get_tree().create_timer(TWEEN_TIME + .1).timeout
	rotation = 0
	is_just_clicked = false


func _on_mouse_entered() -> void:
	if is_just_clicked:
		return
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(45), TWEEN_TIME)


func _on_mouse_exited() -> void:
	if is_just_clicked:
		return
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(0), TWEEN_TIME)
