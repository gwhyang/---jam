extends Area2D
class_name Body

@export var summon_scene:PackedScene
@onready var sprite: Sprite2D = %Sprite
@onready var body_ani: AnimationPlayer = %body_ani

func on_touch_summon_skill():
	Game.summon(summon_scene,global_position)
	queue_free()

func destory():
	body_ani.play("disappear")
	await body_ani.animation_finished
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	on_touch_summon_skill()
