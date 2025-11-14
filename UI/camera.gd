extends Camera2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect
@onready var mouse_sfx: AudioStreamPlayer = $Mouse_SFX

#When first loading the game
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	Camera.fade_in()

#normal fading out (into black screen)
func fade_out():
	animation_player.play_backwards("Fade")

#normal fading in (outo of black screen)
func fade_in():
	animation_player.play("Fade")

#button click sound?
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Mouse Click"):
		mouse_sfx.pitch_scale = randf_range(0.9,1.1)
		# mouse_sfx.play()
