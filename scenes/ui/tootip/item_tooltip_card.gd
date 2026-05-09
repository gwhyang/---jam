extends Panel
class_name TooltipCard

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

@export var item: ItemBase: set = _set_item

@onready var item_name: Label = %ItemName
@onready var item_slot: Label = %ItemSlot
@onready var item_description: RichTextLabel = %ItemDescription
@onready var coins_label: Label = %CoinsLabel



func _set_item(value: ItemBase) -> void:
	var bone_item := value as BoneItem
	item = value
	for node:Node in [item_name,item_slot,item_description,coins_label]:
		if not node.is_node_ready:
			await node.ready
	item_name.text = bone_item.item_name
	item_slot.text=""
	for slot in bone_item.item_vaild_slot:
		if not bone_item.item_vaild_slot[slot]:
			continue
		if item_slot.text:
			item_slot.text +=" "
		item_slot.text += slot_name[slot]
	item_description.text = value.get_description()
	coins_label.text = str(value.item_cost)
	
	var style := Global.get_tier_style(value.item_tier)
	add_theme_stylebox_override("panel", style)
