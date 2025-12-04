extends Control

const VOTE_VALUE: int = 1000000 #each vote is worth $1,000,000

class Result:
	var username: String
	var user_id: int
	var value: int


func _ready() -> void:
	GDSync.expose_func(show_scores)
	GDSync.expose_func(show_winner)
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
	if result_list[0].value >= GameManager.WIN_THRESHOLD: 
		var winner = Label.new()
		winner.text = str(result_list[0].username, " wins with a total investment of ", MultiplayerManager.score_card[result_list[0].user_id])
		winner.set_global_position(Vector2(200,200))
		$List.add_child(winner)
		return true
	else:
		return false


func _simplified_calculating_scores() -> void:
	var counting_votes: Dictionary
	#for every player in the game, give them a default starting value of 0
	for user_id: int in MultiplayerManager.players:
		counting_votes[user_id] = 0
	#then, count up each vote. For each vote that a person got, add one to them (found by their user_id)
	for vote: int in MultiplayerManager.votes.values():
		counting_votes[vote] += 1
	#finally, set the value in MultiplayerManager.score_card of the ACTUAL amount that each player earned
	for user_id in MultiplayerManager.score_card:
		MultiplayerManager.score_card[user_id] = counting_votes[user_id] * VOTE_VALUE


func _calculate_scores(voting_results: Dictionary) -> Array[Result]:
	var result_list: Array[Result] #an arry of Result objects
	for user_id in voting_results.keys(): #for every key in the provided dictionary
		var result = Result.new() #new Result object
		result.username = MultiplayerManager.players[user_id].username #set its username
		result.value = voting_results[user_id] #set its value
		result.user_id = user_id #set its user id
		if !MultiplayerManager.score_card.has(user_id):
			MultiplayerManager.score_card[user_id] = 0
		MultiplayerManager.score_card[user_id] += result.value * VOTE_VALUE
		result_list.append(result) #adds the Result object to the end of the array
	result_list.sort_custom(comp_score) #sorts the array using the provided function
	return result_list


func _show_first_second_and_third_place(result_list: Array) -> void:
	var list_size = result_list.size()
	var first_place = result_list[0] if list_size > 0 else null #first place = the value if that value spot exists in the array, otherwise its null
	var second_place = result_list[1] if list_size > 1 else null
	var third_place = result_list[2] if list_size > 2 else null
	
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


func show_winner() -> void:
	%ResultsContainer.visible = false
	var first_place: PanelContainer = %FirstPlace.duplicate()
	first_place.name = "FirstPlaceDisplay"
	%WinnerContainer/WinnerVBox.add_child(first_place)
	%WinnerContainer.visible = true


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
