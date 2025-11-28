extends Node2D

class Result:
	var username: String
	var user_id: int
	var value: int


func _ready() -> void:
	GDSync.expose_func(show_scores)
	#initially hide all of the places
	%FirstPlace.visible = false
	%SecondPlace.visible = false
	%ThirdPlace.visible = false


func show_scores(voting_results: Dictionary) -> bool:
	var result_list: Array[Result] = _calculate_scores(voting_results)
	_show_first_second_and_third_place(result_list) #show results for first, second, and third place
	#show results for 4th place and beyond
	for i in range(result_list.size()):
		if i > 2:
			var display_box: PanelContainer = $DisplayBoxTemplate.duplicate()
			display_box.get_node("MarginContainer/HBoxContainer/Placement").text = str(i+1) + "th"
			display_box.get_node("MarginContainer/HBoxContainer/PlayerName").text = result_list[i].username #update the player name
			display_box.get_node("MarginContainer/HBoxContainer/Money").text = "($" + format_with_commas(MultiplayerManager.score_card[result_list[i].user_id]) + ")"
			display_box.visible = true
			%EveryoneElse.add_child(display_box)
	
	#if the current first place player has reached the win threshold
	if result_list[0].value >= GameManager.win_threshold: 
		var winner = Label.new()
		winner.text = str(result_list[0].username, " wins with a total investment of ", MultiplayerManager.score_card[result_list[0].user_id])
		winner.set_global_position(Vector2(200,200))
		$List.add_child(winner)
		return true
	else:
		return false


func _calculate_scores(voting_results: Dictionary) -> Array[Result]:
	var result_list: Array[Result] #an arry of Result objects
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
	return result_list


func _show_first_second_and_third_place(result_list: Array) -> void:
	var size = result_list.size()
	var first_place = result_list[0] if size > 0 else null
	var second_place = result_list[1] if size > 1 else null
	var third_place = result_list[2] if size > 2 else null
	
	if first_place: #if it exists
		%FirstPlace.find_child("PlayerName").text = first_place.username #update the player name
		%FirstPlace.find_child("Money").text = "$" + format_with_commas(MultiplayerManager.score_card[first_place.user_id]) #update the money they got
		%FirstPlace.visible = true
	if second_place:
		%SecondPlace.find_child("PlayerName").text = second_place.username
		%SecondPlace.find_child("Money").text = "$" + format_with_commas(MultiplayerManager.score_card[second_place.user_id])
		%SecondPlace.visible = true
	if third_place:
		%ThirdPlace.find_child("PlayerName").text = third_place.username
		%ThirdPlace.find_child("Money").text = "$" + format_with_commas(MultiplayerManager.score_card[third_place.user_id])
		%ThirdPlace.visible = true


#formats the provided number to be a String with commas
func format_with_commas(num: int) -> String:
	var num_str: String = str(abs(num))
	var formatted_string: String = ""
	var length: int = num_str.length()
	var count: int = 0
	
	#iterate backward through the digits
	for i in range(length - 1, -1, -1):
		formatted_string = num_str[i] + formatted_string #insert the current digit at the beginning of the formatted string
		count += 1 #increment the digit counter
		if count % 3 == 0 and i != 0: #insert a comma every three digits, but not before the very first digit
			formatted_string = "," + formatted_string
	
	return formatted_string


func comp_score(r1: Result, r2: Result):
	return r1.value > r2.value
