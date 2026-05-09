extends RefCounted
class_name BuffRuntime

var buff_def: BuffBase
var stacks := 0
var remaining_time := 0.0
var source: Node
var applied_at_msec := 0

func _init(definition: BuffBase, initial_stacks: int, from_source: Node = null) -> void:
	buff_def = definition
	stacks = max(1, initial_stacks)
	remaining_time = buff_def.duration
	source = from_source
	applied_at_msec = Time.get_ticks_msec()

func is_permanent() -> bool:
	return buff_def.duration <= 0.0
