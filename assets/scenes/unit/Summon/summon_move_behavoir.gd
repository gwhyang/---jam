extends Node2D
class_name MoveBehavoir


@onready var parent:Unit = get_parent()
# Current frame velocity calculated by concrete movement behaviors.
var velcity:Vector2

func move(delta:float):
	# Base hook: child behaviors must override and update summon position.
	pass
