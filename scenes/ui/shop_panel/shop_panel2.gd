extends ShopPanel

signal inventory_pressed

@export var equip_panel:EquipPanel

var card_to_equip:Dictionary[ItemCard,ItemCard]

func _on_item_purchased(item: ItemBase) -> void:
	var item_card := create_item_card()
	passives_container.add_child(item_card)
	item_card.item = item
	
	card_to_equip[item_card] = equip_panel.add_equipment_item_card(item)
	


func _on_inventory_pressed() -> void:
	inventory_pressed.emit()
	equip_panel.show()
	
func _on_sell_button_pressed() -> void:
	if not context_card:
		return
	#TODO
	# 检查是否在装备上
	# 删除equip panel里面的
	# 引用super逻辑
