extends Node2D

@export var FLIP_TIME = .5

@export var possible_text = [
	"Microwave Ovens",
	"Frying Pans",
	"Personal Data Organizers",
	"Barbecue Grills",
	"Tennis Shoes",
	"Baseball Caps",
	"Bug Repellant",
	"Bicycles",
	"Swimsuits",
	"Lip Balm",
	"Snow Skis",
	"Surfboards",
	"Garbage Bags",
	"Toothbrushes",
	"Toilet Paper",
	"Handguns",
	"Houseplants",
	"Bath Toys",
	"Coffee Maker",
	"Facial Tissues",
	"Golf Clubs",
	"Raincoats",
	"Electric Fans",
	"Kites",
	"Cell Phones",
	"Laptops",
	"Ladders",
	"Garden Hoses",
	"Frisbees",
	"Lawnmowers",
	"Solar Powered Calculators",
	"Potting Soil",
	"Bookmarks",
	"Insulated Can Holders",
	"Beach Balls",
	"MP3 Music Players",
	"Sunglasses",
	"Backpacks",
	"Pain Relief Pills",
	"Chewing Gum",
	"Toaster Ovens",
	"Ear Swabs",
	"Foot Powder",
	"Antacid Tablets",
	"Digital Video Cameras",
	"Ice"
]

@export var text: String

@onready var front = $Front
@onready var back = $Back
@onready var label: Label = $Front/MarginContainer/ColorRect/MarginContainer/Label

@onready var currentSide = front

enum {
	stay,
	shrinking,
	growing
}
var state = stay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pick_text()

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_accept")):
		print("card clicked")
		flip()
		#test()

func pick_text():
	if (text == ""):
		text = possible_text[randi_range(0, possible_text.size() - 1)]
	label.text = text

func shrink() -> Tween:
	print("shrinking")
	var shrinkTween = create_tween()
	shrinkTween.tween_property(self, "scale:x", 0, FLIP_TIME)
	shrinkTween.tween_callback(grow)
	print("current side is ", currentSide)
	print("disabled current side")
	print("done shrinking")
	return shrinkTween

func grow():
	print("growing")
	print(self.scale.x)
	print("current side is ", currentSide)

	swap_current_side()

	var tween = create_tween()
	state = growing
	tween.tween_property(self, "scale:x", 1, FLIP_TIME)

func swap_current_side():
	print("swapping side was ", currentSide)
	var oldSide = currentSide
	if currentSide == back:
		currentSide = front
	elif currentSide == front:
		currentSide = back
	else:
		print("side is null")

	currentSide.visible = true
	oldSide.visible = false
	print("enabled " + str(currentSide))
	print(currentSide.visible)

func flip() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0, FLIP_TIME)
	tween.chain().tween_callback(grow)
	state = stay


func test():
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0, FLIP_TIME)
	tween.chain().tween_property(self, "scale:x", 1, FLIP_TIME)
	pass
