extends Camera2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect


func fade_out():
	animation_player.play_backwards("Fade")

func fade_in():
	animation_player.play("Fade")
