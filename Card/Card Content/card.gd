extends PanelContainer

#preloading the textures (that aren't needed anymore)
#const WHAT_CARD_ASSET = preload("res://Assets/What-card-asset.png")
#const WHO_CARD_ASSET = preload("res://Assets/Who-card-asset.png")

#the potential card types
enum card_types {
	who,
	what
}

@export var card_type: card_types #exporting the type of card that this card is (either a "who" card or a "what" card)


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

#references to the nodes in the scene
@onready var label: Label = $Text

#the red and yellow color constants for text (Godot doesn't let them be constants
var YELLOW_COLOR: Color = Color.from_rgba8(240, 221, 12, 255)
var RED_COLOR: Color = Color.from_rgba8(153, 29, 35, 255)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#CARD VISUALS
	var stylebox = StyleBoxFlat.new() #stylebox to change the background color of the card
	if card_type == card_types.who:
		stylebox.bg_color = YELLOW_COLOR
		label.add_theme_color_override(&"font_color", RED_COLOR) #make the text red
	else:
		stylebox.bg_color = RED_COLOR
		label.add_theme_color_override(&"font_color", YELLOW_COLOR) #make the text yellow
	stylebox.set_corner_radius_all(20) #setting the corner radius for all corners
	self.add_theme_stylebox_override(&"panel", stylebox) #changing the background color
	
	#TECHNICAL STUFF
	await get_tree().create_timer(.1).timeout
	if (card_type == card_types.who):
		possible_text = who_text
	elif (card_type == card_types.what):
		possible_text = what_text
	pick_text()

# Call this to (re)pick/update the text on the card
func pick_text():
	label.text = possible_text[randi_range(0, possible_text.size() - 1)]
