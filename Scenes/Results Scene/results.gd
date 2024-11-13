extends Node2D

class Result:
	var username: String
	var value: int

func show_scores(voting_results: Dictionary):
	var result_list : Array[Result]
	for record in voting_results.keys():
		var result = Result.new()
		result.username = record
		result.value = voting_results[record]
		result_list.append(result)
	result_list.sort_custom(comp_score)
	pass

func comp_score(r1: Result, r2: Result):
	return r1.value < r2.value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
