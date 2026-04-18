extends Node

var is_testing:bool = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		is_testing = !is_testing


func test_logic():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_testing:
		test_logic()
		is_testing = false
