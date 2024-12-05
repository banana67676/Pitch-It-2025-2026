extends Node2D

enum drawing_modes {DRAW, ERASE}

var image
var image_texture
var mode = drawing_modes.DRAW
var enabled = true
const WIDTH = 800
const HEIGHT = 600
var mode_size = 5
var draw_color = Color8(255, 255, 255, 255)
var defaults = [Color8(255, 0, 0, 255),
Color8(0, 255, 0, 255), Color8(0, 0, 255, 255), Color8(0, 0, 0, 255), Color8(255, 255, 255, 255), Color8(139, 69, 19, 255)]
var color_plte
var prev_mouse_pos
var draw_color_buffer = [Color(0, 0, 0, 255)]
var icon = load("res://Assets/palette.png")

const eraser_icon = preload("res://Assets/mouse-eraser.png")
const pencil_icon = preload("res://Assets/pencil.svg")
const eraser_offset = Vector2(35, 5)
const pencil_offset = Vector2(0, 20)


@onready var size_slider: HSlider = $Control/SizeSlider

func new_ui_button(color):
	var button = TextureButton.new()
	button.texture_normal = icon
	color_plte.add_child(button)
	button.size.x = 20
	button.size.y = 20
	var index = color_plte.get_child_count() - 1
	button.set_position(Vector2((index % 2) * 30, (index / 2) * 30))
	button.modulate = color;
	button.connect("pressed", func(): draw_color = button.modulate)
	return button

func _ready():
	position = Vector2(0, 0)
	var canvas_fill = PackedByteArray()
	canvas_fill.resize(WIDTH * HEIGHT * 4)
	self.repeat_fill(canvas_fill, PackedByteArray([0, 0, 0, 0]))
	image = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8, canvas_fill)
	image_texture = ImageTexture.create_from_image(image)
	color_plte = $Control/ColorPicker/ColorPalette
	for color in defaults:
		new_ui_button(color)
		#obj.call_deferred("set","theme_override_colors/icon_normal_color", color)
	new_ui_button(Color8(255, 255, 255, 255))


func _process(_delta: float) -> void:
	if enabled:
		if Input.is_action_pressed("Mouse Click"):
			# Plan: Create a parametric line equation where f(0) = prev_mouse_pos && f(1) = mouse_pos
			# Then measure each point's distance from the line segment
			var mouse_pos = get_local_mouse_position()
			mode_size = size_slider.value
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
	self.draw_texture(image_texture, Vector2(15, 15))
#
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


func _on_draw_erase_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mode = drawing_modes.ERASE
		Input.set_custom_mouse_cursor(eraser_icon, Input.CURSOR_ARROW, eraser_offset)
		mode_size *= 1.10
	else:
		mode = drawing_modes.DRAW
		Input.set_custom_mouse_cursor(eraser_icon, Input.CURSOR_ARROW, pencil_offset)

		mode_size /= 1.10
	pass # Replace with function body.


func _on_color_picker_button_color_changed(color: Color) -> void:
	draw_color_buffer.append(draw_color)
	draw_color = color
	color_plte.get_child(color_plte.get_child_count() - 1).modulate = color
	pass # Replace with function body.

func set_image(texture: Image):
	image_texture.update(texture)


func _on_erase_all_button_pressed() -> void:
	for x in range(WIDTH):
		for y in range(HEIGHT):
			image.set_pixel(x, y, Color8(0, 0, 0, 0))
	image_texture.update(image)
