extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if multiplayer.is_server():
		var time_left = MultiplayerManager.get_time_left() 
		if (time_left > 10):
			text = str("Time remaining: ",int(round(time_left))) #if more than 10 seconds, round to the nearest second w/o decimal
		else:
			text = str("Time remaining: %.1f" % time_left) #if less than 10 seconds, show the decimals
	
