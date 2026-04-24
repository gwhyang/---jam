extends Resource
class_name PackedItemEffect
# Trigger type that decides when this effect should be evaluated.
@export var trigger:Global.ItemCallBack
# Concrete effect payload executed under the trigger.
@export var effect:ItemEffect

