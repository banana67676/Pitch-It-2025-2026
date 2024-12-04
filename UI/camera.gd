extends Camera2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	Camera.fade_in()

func fade_out():
	animation_player.play_backwards("Fade")

func fade_in():
	animation_player.play("Fade")
