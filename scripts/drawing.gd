extends Node2D

enum drawing_modes {DRAW, ERASE}

var image
var image_texture
var mode = drawing_modes.DRAW
var enabled = true
const WIDTH = 800
const HEIGHT = 600
var mode_size = 20
var draw_color = Color8(255,255,255,255)

func _ready():
	position = Vector2(0,0)
	var canvas_fill = PackedByteArray()
	canvas_fill.resize(WIDTH*HEIGHT*4)
	self.repeat_fill(canvas_fill, PackedByteArray([0,0,0,255]))
	image = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8, canvas_fill)
	image_texture = ImageTexture.create_from_image(image)
	
	
func _process(delta: float) -> void:
	if enabled:
		if Input.is_action_pressed("Mouse Click"):
			var mouse_pos = get_global_mouse_position()
			for i in range(max(mouse_pos.x-mode_size, 0), min(mouse_pos.x+mode_size, WIDTH)):
				for j in range(max(mouse_pos.y-mode_size, 0), min(mouse_pos.y+mode_size, HEIGHT)):
					if mouse_pos.distance_to(Vector2(i, j)) < mode_size:
						if mode == drawing_modes.DRAW:
							image.set_pixel(i, j, draw_color)
						elif mode == drawing_modes.ERASE:
							image.set_pixel(i,j,Color8(0,0,0,0))
	image_texture.update(image)
			
		
func _draw() -> void:
	self.draw_texture(image_texture, Vector2(0,0))
#
func repeat_fill(array: PackedByteArray, suppliant: PackedByteArray) -> void:
	for i in range(array.size()):
		array.set(i, suppliant[i % suppliant.size()])
	
