extends ItemEffect
class_name StatusChange


@export var chaged_stats:String
@export var changed_value:float
func effect(context:EffectContext)->bool:
	# One resource can define both apply and rollback on equip lifecycle.
	match context.trigger_type:
		Global.ItemCallBack.ONEQUIP:
			Global.player.stats[chaged_stats] += changed_value
			return true
		Global.ItemCallBack.ONEQUIP:
			Global.player.stats[chaged_stats] -= changed_value
			return true
	return false
