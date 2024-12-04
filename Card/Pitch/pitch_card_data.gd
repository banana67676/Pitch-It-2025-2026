extends Resource
class_name PitchCardData
var title : String
var slogan : String
var username : String
var user_id : int
var logo : Image
var online : bool

const WIDTH = 800
const HEIGHT = 600

func serialize() -> Dictionary:
	var data = {
		'title': title,
		'slogan': slogan,
		'user': username,
		'userId': user_id,
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
	pcData.logo = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8,
		data["logo"]
	)
	return pcData
# Called when the node enters the scene tree for the first time.
