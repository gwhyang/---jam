extends ItemEffect
class_name StatusChange
## 会加上属性，如果上下文为卸下装备时，则会减去相同属性

@export var chaged_stats:String
@export var changed_value:float
func effect(context:EffectContext)->bool:
	# One resource can define both apply and rollback on equip lifecycle.
	match context.trigger_type:
		Global.ItemCallBack.ONUNLOAD:
			Global.player.stats[chaged_stats] -= changed_value
			return true
	Global.player.stats[chaged_stats] += changed_value
	return true
	return false
