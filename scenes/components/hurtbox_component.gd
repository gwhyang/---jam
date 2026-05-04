extends Area2D
class_name HurtboxComponent

signal on_damaged(hitbox: HitboxComponent)



func enable() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
func disable() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		on_damaged.emit(area)
