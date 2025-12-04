extends Node

var username : String = ""
var score : int = 0
var data : PitchCardData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func serialize() -> Dictionary:
	if data != null:
		return {"username": username, "score" : score, "data": data.serialize()}
	else:
		return {"username": username, "score": score, "data": null}
