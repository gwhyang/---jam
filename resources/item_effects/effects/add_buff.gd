extends ItemEffect
class_name AddBuffEffect

@export var buff: BuffBase
@export var stacks := 1

func effect(context: EffectContext) -> bool:
	var target := context.unit
	if not target:
		target = Global.player
	if not target or not target is Unit:
		return false
	if not target.buff_manager:
		return false
	target.buff_manager.add_buff(buff, stacks, Global.player)
	print("added buff"+buff.buff_id)
	return true
