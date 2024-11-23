extends Node2D

class Result:
	var user_id : int
	var value: int

func show_scores(voting_results: Dictionary):
	var result_list : Array[Result]
	for record in voting_results.keys():
		var result = Result.new()
		result.username = MultiplayerManager.players[record.user_id].username
		result.value = voting_results[record]
		MultiplayerManager.score_card[record.user_id] += result.value * 100000
		result_list.append(result)
	result_list.sort_custom(comp_score)
	for i in range(result_list.size()):
		var entry = Label.new()
		entry.text = str(result_list.size()-i-1,
		". ",
		result_list[result_list.size()-i-1].username,
		" $",
		result_list[result_list.size()-i-1].value)
		$List.add_child(entry)
		
	pass
	
func show_final():
	var result_list : Array[Result]
	for record in MultiplayerManager.players.keys():
		var result = Result.new()
		result.username = MultiplayerManager.players[record.user_id].username
		result.value = MultiplayerManager.players[record.user_id].score

func comp_score(r1: Result, r2: Result):
	return r1.value > r2.value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
