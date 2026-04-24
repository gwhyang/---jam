extends ItemBase
class_name BoneItem

# Each slot flag indicates whether this bone item can be equipped there.
@export var item_vaild_slot: Dictionary[Global.BoneSlot,bool] = {
	Global.BoneSlot.head : false,
	Global.BoneSlot.lhand : false,
	Global.BoneSlot.lrib : false,
	Global.BoneSlot.spine : false,
	Global.BoneSlot.rrib : false,
	Global.BoneSlot.rhand : false,
	Global.BoneSlot.lleg : false,
	Global.BoneSlot.rleg : false
}

@export var add_value: float
@export var add_stats: String
@export var remove_value: float
@export var remove_stats: String
@export_group("item effects")


func default_description() -> String:
	var description := "[code]"
	
	if add_value != 0:
		description += "[color=green]+%s %s[/color]\n" % [add_value, add_stats]
	
	if remove_value != 0:
		description += "[color]-%s %s[/color]" % [remove_value, remove_stats]
	
	
	description += "[/code]"
	return description
	
func apply_passive() -> void:
	# Keep same apply model as passive items for easy balancing.
	if add_value != 0:
		Global.player.stats[add_stats] += add_value
	
	if remove_value != 0:
		Global.player.stats[remove_stats] -= remove_value
