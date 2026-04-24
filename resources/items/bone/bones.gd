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
# Effect list is executed by EquipPanel on equip/unequip callbacks.
@export var effects:Array[PackedItemEffect]

func default_description() -> String:
	var description := "[code]"
	description += "[/code]"
	return description
	
