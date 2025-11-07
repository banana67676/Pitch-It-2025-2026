extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


#when the LineEdit for the username is changed (text is entered)
func _on_text_changed() -> void:
	if text.length() > 32:
		text = text.substr(0, 32)
		#set_caret_column(32)
