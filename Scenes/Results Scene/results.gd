extends Node2D

class Result:
	var username: String
	var user_id: int
	var value: int

@rpc("any_peer","call_local","reliable")
func show_scores(voting_results: Dictionary) -> bool:
	var result_list : Array[Result]
	for record in voting_results.keys():
		var result = Result.new()
		result.username = MultiplayerManager.players[record].username
		result.value = voting_results[record]
		result.user_id = record
		if !MultiplayerManager.score_card.has(record):
			MultiplayerManager.score_card[record] = 0
		MultiplayerManager.score_card[record] += result.value * 100000
		result_list.append(result)
	result_list.sort_custom(comp_score)
	
	for i in range(result_list.size()):
		var entry = Label.new()
		entry.text = str(i+1,
		". ",
		result_list[result_list.size()-i-1].username,
		" $",
		MultiplayerManager.score_card[result_list[result_list.size()-i-1].user_id])
		entry.set_global_position(Vector2(20,40+i*50))
		$List.add_child(entry)
	if result_list[0].value >= GameManager.win_threshold: 
		var winner = Label.new()
		winner.text = str(result_list[0].username, " wins with a total investment of ", MultiplayerManager.score_card[result_list[0].user_id])
		winner.set_global_position(Vector2(200,200))
		$List.add_child(winner)
		return true
	else:
		return false
	pass
	
func show_final():
	var result_list : Array[Result]
	for record in MultiplayerManager.players.keys():
		var result = Result.new()
		result.username = MultiplayerManager.players[record.user_id].username
		result.value = MultiplayerManager.players[record.user_id].score

func comp_score(r1: Result, r2: Result):
	return r1.value < r2.value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
