extends Control

@onready var title_scene: TitleScene = $Title_Scene
@onready var username_scene: UsernameScene = $Username
@onready var host_scene: HostScene = $HostScene
@onready var join_scene: JoinScene = $JoinScene

var currently_transitioning: bool = false
const tween_time: float = 1
const x_shift: float = 1600
const y_shift: float = 800


func _ready() -> void: #the following are all signals located in the respective scenes
	title_scene.connect("key_pressed", _transition_to_username.bind(0, -y_shift, tween_time/4))
	host_scene.connect("back_to_username", _transition_to_username.bind(-x_shift, 0, tween_time))
	join_scene.connect("back_to_username", _transition_to_username.bind(x_shift, 0, tween_time))
	username_scene.back_to_title.connect(_transition_to_title)
	username_scene.to_host.connect(_transition_to_host)
	username_scene.to_join.connect(_transition_to_join)


func _transition_to_title() -> void:
	title_scene.reset_scene()
	_move_all_scenes(0, y_shift)
	await get_tree().create_timer(tween_time).timeout
	GameManager.game_state = GameManager.game_state_enum.title
	username_scene.reset_animation()


func _transition_to_username(change_x: float, change_y: float, delay: float) -> void:
	if currently_transitioning:
		return
	#if GameManager.game_state == GameManager.game_state_enum.title or GameManager.game_state == GameManager.game_state_enum.game_opening:
	currently_transitioning = true
	for scene: Control in self.get_children():
		scene.visible = true
	_move_all_scenes(change_x, change_y)
	await get_tree().create_timer(delay).timeout
	GameManager.game_state = GameManager.game_state_enum.username
	username_scene.play_animation()
	host_scene.reset_animation()
	join_scene.reset_animation()
	await get_tree().create_timer(1).timeout #just wait another second before making this the only visible scene
	currently_transitioning = false


func _transition_to_host(username: String) -> void:
	host_scene.update_username(username)
	_move_all_scenes(x_shift, 0)
	await get_tree().create_timer(tween_time).timeout
	host_scene.play_animation()
	GameManager.game_state = GameManager.game_state_enum.host
	username_scene.reset_animation()
	username_scene.visible = false


func _transition_to_join(username: String) -> void:
	join_scene.update_username(username)
	join_scene.fetch_servers()
	_move_all_scenes(-x_shift, 0)
	await get_tree().create_timer(tween_time).timeout
	join_scene.play_animation()
	GameManager.game_state = GameManager.game_state_enum.join
	username_scene.reset_animation()
	username_scene.visible = false


func _move_all_scenes(horizontal_shift: float, vertical_shift: float) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(title_scene, "position", title_scene.position + Vector2(horizontal_shift, vertical_shift), tween_time)
	tween.tween_property(username_scene, "position", username_scene.position + Vector2(horizontal_shift, vertical_shift), tween_time)
	tween.tween_property(host_scene, "position", host_scene.position + Vector2(horizontal_shift, vertical_shift), tween_time)
	tween.tween_property(join_scene, "position", join_scene.position + Vector2(horizontal_shift, vertical_shift), tween_time)
