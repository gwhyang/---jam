extends ItemEffect
class_name RemoveBuffEffect

@export var buff_id: StringName

func effect(context: EffectContext) -> bool:
	var target := context.unit
	if not target:
		target = Global.player
	if not target or not target is Unit:
		return false
	if not target.buff_manager:
		return false
	target.buff_manager.remove_buff(buff_id)
	return true
