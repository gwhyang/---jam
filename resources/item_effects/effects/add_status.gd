extends ItemEffect
class_name AddStatsEffect
@export var add_stats:String
@export var add_value:float

func effect(context:EffectContext)->bool:
	# Apply a flat bonus to the target stat.
	Global.player.stats[add_stats] += add_value
	return true
