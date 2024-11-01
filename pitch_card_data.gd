extends Resource
class_name PitchCardData
var title : String
var slogan : String
var user : String
var user_id : int
var logo : Image
var online : bool

func serialize() -> Dictionary:
	return {
		'title': title,
		'slogan': slogan,
		'user': user,
		'userId': user_id,
		'logo' : logo.data
	}

static func deserialize(data: Dictionary) -> PlayerData:
	var pcData : PitchCardData = PitchCardData.new()
	pcData.logo = Image.create_from_data(
		
	)
	return pcData
# Called when the node enters the scene tree for the first time.
