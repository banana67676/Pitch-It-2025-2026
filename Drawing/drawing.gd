extends Node2D

enum drawing_modes {DRAW, ERASE}

var image
var image_texture
var mode = drawing_modes.DRAW
var enabled = true
const WIDTH = 800
const HEIGHT = 600
var mode_size = 5
var draw_color = Color8(255,255,255,255)
var prev_mouse_pos

func _ready():
	position = Vector2(0,0)
	var canvas_fill = PackedByteArray()
	canvas_fill.resize(WIDTH*HEIGHT*4)
	self.repeat_fill(canvas_fill, PackedByteArray([0,0,0,0]))
	image = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8, canvas_fill)
	image_texture = ImageTexture.create_from_image(image)
	
	
func _process(delta: float) -> void:
	if enabled:
		if Input.is_action_pressed("Mouse Click"):
			# Plan: Create a parametric line equation where f(0) = prev_mouse_pos && f(1) = mouse_pos
			# Then measure each point's distance from the line segment
			var mouse_pos = get_global_mouse_position()
			if prev_mouse_pos == null:
				prev_mouse_pos = mouse_pos
			var low_x = min(mouse_pos.x, prev_mouse_pos.x)
			var low_y = min(mouse_pos.y, prev_mouse_pos.y)
			var high_x = max(mouse_pos.x, prev_mouse_pos.x)
			var high_y = max(mouse_pos.y, prev_mouse_pos.y)
			for i in range(max(low_x-mode_size, 0), min(high_x+mode_size, WIDTH)):
				for j in range(max(low_y-mode_size, 0), min(high_y+mode_size, HEIGHT)):
					if min_distance(prev_mouse_pos, mouse_pos, Vector2(i,j)) < mode_size:
						if mode == drawing_modes.DRAW:
							image.set_pixel(i, j, draw_color)
						elif mode == drawing_modes.ERASE:
							image.set_pixel(i,j,Color8(0,0,0,0))
					
					
			prev_mouse_pos = mouse_pos
		else:
			prev_mouse_pos = null
	image_texture.update(image)
			
		
func _draw() -> void:
	self.draw_texture(image_texture, Vector2(15,15))
#
func repeat_fill(array: PackedByteArray, suppliant: PackedByteArray) -> void:
	for i in range(array.size()):
		array.set(i, suppliant[i % suppliant.size()])
		
func min_distance(start: Vector2, end: Vector2, compare: Vector2) -> float:
	var distanceS = start.distance_squared_to(end)
	if (distanceS < 0.003):
		return compare.distance_to(end)
	
	var inter1 = compare-start
	var inter2 = end-start
	var dot = inter1.dot(inter2)
	var t = max(0, min(1, dot/distanceS))
	var proj = start + t * (end - start)
	return proj.distance_to(compare)
	
	


func _on_draw_erase_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mode = drawing_modes.ERASE
		mode_size *= 1.10
	else:
		mode = drawing_modes.DRAW
		mode_size /= 1.10
	pass # Replace with function body.
