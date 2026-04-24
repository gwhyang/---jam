extends RefCounted
class_name EffectContext
## 从触发器到作用器传的上下文
# ## 应该是自动设置的
#@export_flags("varibles") var _varible_mask
# Unit that produced this effect (player/summon/etc.).
var unit:Unit
# Global position where the effect is triggered.
var global_posi:Vector2
var add_value: float
var add_stats: String
var remove_value: float
var remove_stats: String
# Runtime callback stage that invokes this effect.
var trigger_type:Global.ItemCallBack = -1

## 判断自己的变量能否涵盖效果需要的
#func included(effect_required_flags:int)->bool:
#	return _varible_mask == (_varible_mask & effect_required_flags)
