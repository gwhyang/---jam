extends ItemEffect
class_name SummonEffect

@export var summon_scene:PackedScene
@export var summon_radius:float = 50

func effect(context:EffectContext)->bool:
	if not context.global_posi:
		return false
	if not context.summon_amount:
		return false
	
	var summon_posi:= context.global_posi + Vector2(randf_range(-summon_radius,summon_radius),randf_range(-summon_radius,summon_radius))
	for i in context.summon_amount:
		if Global.get_tree().get_nodes_in_group("summon_unit").size() >= Global.player.stats.max_summons:
			return true
		Game.summon(summon_scene,summon_posi)
	return true
