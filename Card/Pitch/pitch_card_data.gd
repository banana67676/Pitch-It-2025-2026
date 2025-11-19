extends Resource
class_name PitchCardData

#TITLE
var title : String:
	set(value): #when this value is attempted to be changed
		title = value
		if value.is_empty(): #if the string is empty
			title = "-" #set it to a dash instead

#SLOGAN
var slogan : String:
	set(value): #when this value is attempted to be changed
		slogan = value
		if value.is_empty(): #if the string is empty
			slogan = "-" #set it to a dash instead

#Rest of the variables that don't need the set() function
var username : String
var user_id : int
var logo : Image
var who_card : String
var what_card : String
var online : bool

const WIDTH = 800
const HEIGHT = 600

func serialize() -> Dictionary:
	var data = {
		'title': title,
		'slogan': slogan,
		'user': username,
		'userId': user_id,
		'whoCard': who_card,
		'whatCard': what_card,
	}
	var test = logo.data
	data["logo"] = test["data"]
	return data

static func deserialize(data: Dictionary) -> PitchCardData:
	var pcData : PitchCardData = PitchCardData.new()
	pcData.title = data["title"]
	pcData.slogan = data["slogan"]
	pcData.username = data["user"]
	pcData.user_id = data["userId"]
	pcData.who_card = data["whoCard"]
	pcData.what_card = data["whatCard"]
	pcData.logo = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8,
		data["logo"]
	)
	return pcData
# Called when the node enters the scene tree for the first time.
