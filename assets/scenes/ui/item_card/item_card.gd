extends Button
class_name ItemCard

signal on_item_card_selected(card: ItemCard)

@export var item: ItemBase: set = _set_item
@onready var item_icon: TextureRect = $ItemIcon

func _set_item(value: ItemBase) -> void:
	item = value
	if not is_node_ready():
		await ready
	var style :StyleBoxFlat
	# Card visuals are fully data-driven by the bound item resource.
	if item:
		if item.item_icon:
			item_icon.texture = item.item_icon
		
		style = Global.get_tier_style(item.item_tier)
	else:
		item_icon.texture = null
		style = Global.get_tier_style(Global.UpgradeTier.COMMON)
		
		
	add_theme_stylebox_override("normal", style)
	

func _on_pressed() -> void:
	on_item_card_selected.emit(self)
		
