extends Node2D

#the two different drawing modes as an enum
enum drawing_modes {DRAW, ERASE}

var image
var image_texture
var mode = drawing_modes.DRAW
var enabled = true
var is_mouse_on_board = false
var mode_size = 5
var draw_color = Color.from_rgba8(0, 0, 0, 255)
var prev_mouse_pos
var draw_color_buffer = [Color.from_rgba8(0, 0, 0, 255)]
#var icon = load("res://Assets/color-preset.png")

#the preset colors
var color_presets = [
	Color.from_rgba8(0, 0, 0, 255), #black
	Color.from_rgba8(120, 120, 120, 255), #gray
	Color.from_rgba8(255, 255, 255, 255), #white
	Color.from_rgba8(223, 207, 164, 255), #biege
	Color.from_rgba8(118, 57, 14, 255), #dark brown
	Color.from_rgba8(220, 0, 0, 255), #red
	Color.from_rgba8(230, 149, 0, 255), #orange
	Color.from_rgba8(220, 220, 0, 255), #yellow
	Color.from_rgba8(0, 220, 0, 255), #light green
	Color.from_rgba8(0, 120, 0, 255), #dark green
	Color.from_rgba8(80, 235, 255, 255), #light blue
	Color.from_rgba8(0, 0, 220, 255), #blue
	Color.from_rgba8(140, 0, 140, 255), #purple
	Color.from_rgba8(220, 60, 180, 255), #pink
	Color.from_rgba8(255, 199, 199, 255), #rose
]

#constants
const cursor_offset = Vector2(0, 20)
const WIDTH = 800
const HEIGHT = 600

#textures
const eraser_icon = preload("res://Assets/eraser.svg")
const pencil_icon = preload("res://Assets/pencil.svg")
const color_preset_normal = preload("res://Assets/color-preset_normal.svg")
const color_preset_hover = preload("res://Assets/color-preset_hover.svg")
const pencil_selected_texture = preload("res://Assets/pencil-button_focused.svg")
const pencil_unselected_texture = preload("res://Assets/pencil-button_normal.svg")
const eraser_selected_texture = preload("res://Assets/eraser-button_focused.svg")
const eraser_unselected_texture = preload("res://Assets/eraser-button_normal.svg")

#reference variables
@onready var pencil_button: TextureButton = %PencilButton
@onready var eraser_button: TextureButton = %EraserButton
@onready var size_slider: HSlider = %SizeSlider
@onready var pencil_size: Panel = %PencilSize
@onready var eraser_outline: Sprite2D = $EraserOutline

func new_ui_button(color):
	var button = TextureButton.new()
	button.texture_normal = color_preset_normal
	button.texture_hover = color_preset_hover
	%ColorPresetsContainer.add_child(button)
	button.modulate = color;
	button.connect("pressed", func(): #when a color-preset is clicked
		draw_color = button.modulate #change the brush color
		%ColorPickerButton.color = draw_color #change the color on the color wheel to match
		var stylebox: StyleBoxFlat = pencil_size.get_theme_stylebox("panel")
		stylebox.bg_color = draw_color #change the color on the pencil size indicator to match
	)
	return button

#called when the scene first enters the tree
func _ready():
	var canvas_fill = PackedByteArray()
	canvas_fill.resize(WIDTH * HEIGHT * 4)
	self.repeat_fill(canvas_fill, PackedByteArray([0, 0, 0, 0]))
	image = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8, canvas_fill)
	image_texture = ImageTexture.create_from_image(image)
	for color in color_presets:
		new_ui_button(color)


#this function is called every frame
func _process(_delta: float) -> void:
	if not enabled:
		return
	
	mode_size = size_slider.value
	_change_pencil_size_display()
	_eraser_outline_follow()
	if Input.is_action_pressed("Left Click") or Input.is_action_pressed("Right Click"):
		# Plan: Create a parametric line equation where f(0) = prev_mouse_pos && f(1) = mouse_pos
		# Then measure each point's distance from the line segment
		var mouse_pos = get_local_mouse_position()
		if prev_mouse_pos == null:
			prev_mouse_pos = mouse_pos
		var low_x = min(mouse_pos.x, prev_mouse_pos.x)
		var low_y = min(mouse_pos.y, prev_mouse_pos.y)
		var high_x = max(mouse_pos.x, prev_mouse_pos.x)
		var high_y = max(mouse_pos.y, prev_mouse_pos.y)
		for i in range(max(low_x - mode_size, 0), min(high_x + mode_size, WIDTH)):
			for j in range(max(low_y - mode_size, 0), min(high_y + mode_size, HEIGHT)):
				if min_distance(prev_mouse_pos, mouse_pos, Vector2(i, j)) < mode_size:
					if mode == drawing_modes.DRAW:
						image.set_pixel(i, j, draw_color)
					elif mode == drawing_modes.ERASE:
						image.set_pixel(i, j, Color8(0, 0, 0, 0))
		prev_mouse_pos = mouse_pos
	else:
		prev_mouse_pos = null
	image_texture.update(image)


func _draw() -> void:
	self.draw_texture(image_texture, Vector2.ZERO)


func repeat_fill(array: PackedByteArray, suppliant: PackedByteArray) -> void:
	for i in range(array.size()):
		array.set(i, suppliant[i % suppliant.size()])


func min_distance(start: Vector2, end: Vector2, compare: Vector2) -> float:
	var distanceS = start.distance_squared_to(end)
	if (distanceS < 0.003):
		return compare.distance_to(end)
	var inter1 = compare - start
	var inter2 = end - start
	var dot = inter1.dot(inter2)
	var t = max(0, min(1, dot / distanceS))
	var proj = start + t * (end - start)
	return proj.distance_to(compare)


#switches the cursor to the pencil and the ability to draw
func _switch_to_pencil():
	mode = drawing_modes.DRAW
	Input.set_custom_mouse_cursor(pencil_icon, Input.CURSOR_ARROW, cursor_offset)
	mode_size /= 1.10
	pencil_button.texture_normal = pencil_selected_texture
	pencil_button.texture_focused = pencil_selected_texture
	eraser_button.texture_normal = eraser_unselected_texture
	eraser_button.texture_focused = eraser_unselected_texture


#switches the cursor to the eraser and the ability to erase
func _switch_to_eraser():
	mode = drawing_modes.ERASE
	Input.set_custom_mouse_cursor(eraser_icon, Input.CURSOR_ARROW, cursor_offset)
	mode_size *= 1.10
	eraser_button.texture_normal = eraser_selected_texture
	eraser_button.texture_focused = eraser_selected_texture
	pencil_button.texture_normal = pencil_unselected_texture
	pencil_button.texture_focused = pencil_unselected_texture

func _eraser_outline_follow():
	if mode == drawing_modes.ERASE and is_mouse_on_board:
		eraser_outline.visible = true
		eraser_outline.scale = Vector2(mode_size/50, mode_size/50)
		eraser_outline.position = get_local_mouse_position()
	else:
		eraser_outline.visible = false


func _change_pencil_size_display():
	var size_multiplier = mode_size * 2 #multiplies the size to make it accurate to how the pencil actually draws
	pencil_size.set_anchors_preset(Control.PRESET_CENTER) #set the anchor to the center
	pencil_size.set_position(pencil_size.get_parent().size / 2 - pencil_size.size / 2) #position it properly within its container
	pencil_size.pivot_offset = pencil_size.size/2
	pencil_size.size = Vector2(size_multiplier, size_multiplier)


func _on_color_picker_button_color_changed(color: Color) -> void:
	draw_color_buffer.append(draw_color)
	draw_color = color


func set_image(texture: Image):
	image_texture.update(texture)


#when the clear button is pressed, erase everything on the board
func _on_erase_all_button_pressed() -> void:
	for x in range(WIDTH):
		for y in range(HEIGHT):
			image.set_pixel(x, y, Color8(0, 0, 0, 0))
	image_texture.update(image)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT: # right click to erase
			if event.pressed:
				_switch_to_eraser()
			else:
				_switch_to_pencil()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP: # scroll wheel to change size
			size_slider.value += size_slider.step
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			size_slider.value -= size_slider.step


#when the pencil button is clicked, switch the drawing mode to the pencil
func _on_pencil_button_pressed() -> void:
	_switch_to_pencil()


#when the eraser button is clicked, switch the drawing mode to the eraser
func _on_eraser_button_pressed() -> void:
	_switch_to_eraser()


func _on_board_mouse_entered() -> void:
	if mode == drawing_modes.DRAW:
		_switch_to_pencil()
	else:
		_switch_to_eraser()
	is_mouse_on_board = true


func _on_board_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(null)
	is_mouse_on_board = false
