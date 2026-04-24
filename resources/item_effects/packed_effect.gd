extends Resource
class_name PackedItemEffect
# Trigger type that decides when this effect should be evaluated.
@export var trigger:Global.ItemCallBack
# Concrete effect payload executed under the trigger.
@export var _effect:ItemEffect

func effect(context:EffectContext) -> bool:
	# Safe guard: packed entry can be configured without payload in editor.
	if not _effect:return false
	return _effect.effect(context)
