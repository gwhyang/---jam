extends Node2D

@export var summon:PackedScene

var is_testing:bool = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		is_testing = !is_testing
	if event.is_action_pressed("atk") and is_testing:
		if summon:
			Game.spawn(summon,get_global_mouse_position())
