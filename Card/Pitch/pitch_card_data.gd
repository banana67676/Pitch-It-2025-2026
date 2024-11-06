extends Resource
class_name PitchCardData
var title : String
var slogan : String
var user : String
var user_id : int
var logo : Image
var online : bool

const WIDTH = 800
const HEIGHT = 600

func serialize() -> Dictionary:
	return {
		'title': title,
		'slogan': slogan,
		'user': user,
		'userId': user_id,
		'logo' : logo.data
	}

static func deserialize(data: Dictionary) -> PitchCardData:
	var pcData : PitchCardData = PitchCardData.new()
	pcData.logo = Image.create_from_data(WIDTH, HEIGHT, false, Image.FORMAT_RGB8,
		data['logo']
	)
	return pcData
# Called when the node enters the scene tree for the first time.
