extends Area2D
class_name Body

@export var summon_scene:PackedScene
@onready var sprite: Sprite2D = %Sprite

func on_touch_summon_skill():
	Game.summon(summon_scene,global_position)
	queue_free()
