extends ItemBase
class_name BoneItem

const slot_name:Dictionary[Global.BoneSlot,String] = {
	Global.BoneSlot.head:"头骨",
	Global.BoneSlot.lhand:"左手",
	Global.BoneSlot.lrib:"左肋",
	Global.BoneSlot.spine:"脊骨",
	Global.BoneSlot.rrib:"右肋",
	Global.BoneSlot.rhand:"右手",
	Global.BoneSlot.lleg:"左腿",
	Global.BoneSlot.rleg:"右腿"
}

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
	
func get_description() -> String:
	var slot_text:String
	for slot in item_vaild_slot:
		if not item_vaild_slot[slot]:
			continue
		if slot_text:
			slot_text +=" "
		else:slot_text += "[color=#42975e]"
		slot_text += slot_name[slot]
	slot_text += "[/color] \n"
	return slot_text + decrption_override
	if decrption_override:
		return decrption_override
	return default_description()
