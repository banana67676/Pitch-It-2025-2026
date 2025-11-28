extends Node2D

class Result:
	var username: String
	var user_id: int
	var value: int

@rpc("any_peer","call_local","reliable")
func show_scores(voting_results: Dictionary) -> bool:
	var result_list : Array[Result] #an arry of Result objects
	for user_id in voting_results.keys(): #for every key in the provided dictionary
		var result = Result.new() #new Result object
		result.username = MultiplayerManager.players[user_id].username #set its username
		result.value = voting_results[user_id] #set its value
		result.user_id = user_id #set its user id
		if !MultiplayerManager.score_card.has(user_id):
			MultiplayerManager.score_card[user_id] = 0
		MultiplayerManager.score_card[user_id] += result.value * 100000
		result_list.append(result) #adds the Result object to the end of the array
	result_list.sort_custom(comp_score) #sorts the array using the provided function
	
	#repeat this for 2nd and 3rd place
	if result_list[0]: #if it exists
		%"1stPlace".find_child("PlayerName").text = result_list[0].username
		%"1stPlace".find_child("Money").text = str(MultiplayerManager.score_card[result_list[0].user_id])
	
	#actually finish the stuff for 4th place and beyond
	for i in range(result_list.size()):
		var display_box = $DisplayBoxTemplate.duplicate()
		display_box.find_child("Placement").text = str(i+1) #likely do +4
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
	
func show_final():
	#var result_list : Array[Result]
	for record in MultiplayerManager.players.keys():
		var result = Result.new()
		result.username = MultiplayerManager.players[record.user_id].username
		result.value = MultiplayerManager.players[record.user_id].score

func comp_score(r1: Result, r2: Result):
	return r1.value < r2.value
