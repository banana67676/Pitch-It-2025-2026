extends CharacterBody2D

enum card_types {
	who,
	what
}

@export var card_type: card_types

@export var what_text = [
	"Microwave Ovens",
	"Frying Pans",
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

@export var who_text = [
	"Medical Professionals",
	"Firefighters",
	"Actors",
	"Engineers",
	"Airplane Pilots",
	"Used Car Salespersons",
	"Boy Scouts",
	"Girl Scouts",
	"Nuns",
	"Priests",
	"Hunters",
	"Sports Fans",
	"Nascar Fans",
	"Soccer Moms",
	"Teachers",
	"Bankers",
	"Lawn Care Specialists",
	"Construction Workers",
	"College Professors",
	"Accountants",
	"Lawyers",
	"Movie Directors",
	"Postal Workers",
	"Farmers",
	"Window Washers",
	"Fishing Boat Crew Members",
	"Lumberjacks",
	"Meteorologists",
	"Gardeners",
	"Cheerleaders",
	"High School Jocks",
	"Chess Team Members",
	"Rock N' Roll Music Fans",
	"Hip Hop Music Fans",
	"Country Music Fans",
	"Dog Owners",
	"Cat Owners",
	"Tattoo Artists",
	"Police Officers",
	"Military Service Personnel",
	"Barbers or Hairstylists",
	"Librarians",
	"Veterinarians",
	"Zookeepers",
	"Bartenders",
	"FBI Agents",
	"Opera Performers",
	"Graphic Artists"
]

var possible_text = []


@onready var front = $Front
@onready var back = $Back
@onready var label: Label = $Face/MarginContainer/ColorRect/MarginContainer/Label


@onready var currentSide = back

enum {
	stay,
	shrinking,
	growing
}
var state = stay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	if (card_type == card_types.who):
		possible_text = who_text
	elif (card_type == card_types.what):
		possible_text = what_text
	pick_text()

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move(Vector2(0,0))

func pick_text():
	label.text = possible_text[randi_range(0, possible_text.size() - 1)]

func move(location : Vector2):
	global_position = lerp(global_position, location, 0.2)
	global_rotation = lerp(global_rotation, 0, 0.2)
