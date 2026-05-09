extends Camera2D
class_name Camera

@export var shake_scale:float = 1
var shake_strength:float = 0
var shake_tween:Tween

func _process(delta: float) -> void:
	if shake_strength >0:
		var max_offset := shake_scale*shake_strength
		offset = Vector2(randf_range(-max_offset,max_offset),randf_range(-max_offset,max_offset))
	if is_instance_valid(Global.player):
		global_position = Global.player.global_position

func shake(strength:float,duration:float = 0.2):
	shake_strength += strength
	if shake_tween:
		if shake_tween.is_running():
			shake_tween.kill()
	shake_tween = create_tween()
	shake_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	shake_tween.tween_property(self,"shake_strength",0,duration)
	
