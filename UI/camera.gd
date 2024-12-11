extends Camera2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect
@onready var mouse_sfx: AudioStreamPlayer = $Mouse_SFX


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	Camera.fade_in()

func fade_out():
	animation_player.play_backwards("Fade")

func fade_in():
	animation_player.play("Fade")

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Mouse Click"):
		mouse_sfx.pitch_scale = randf_range(0.95,1.05)
		mouse_sfx.play()
