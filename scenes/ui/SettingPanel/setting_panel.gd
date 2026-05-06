extends Panel
signal exit_setting

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	hide()
	exit_setting.emit()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			hide()
		else:
			show()
