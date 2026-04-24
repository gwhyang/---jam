extends ItemEffect
class_name RemoveStatsEffect
@export var remove_stats:String
@export var remove_value:float

func effect(context:EffectContext)->bool:
	# Negative values can be authored in resources for stat reduction.
	Global.player.stats[remove_stats] += remove_value
	return true
