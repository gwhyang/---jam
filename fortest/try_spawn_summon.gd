extends Node2D

@export var summon:PackedScene
@onready var spawner: Spawner = $"../Spawner"

var is_testing:bool = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		is_testing = !is_testing
		Game.spawn(summon,get_global_mouse_position())
