extends Button
class_name DisplayCard

signal on_item_card_selected(card: DisplayCard)

@onready var display_icon: TextureRect = $Icon

	
func set_card(cicon:Texture2D,desciption:String,tier:Global.UpgradeTier):
	# Display cards only need icon+tier style in current UI.
	display_icon.texture = cicon
	var style := Global.get_tier_style(tier)
	add_theme_stylebox_override("normal", style)

func _on_pressed() -> void:
	on_item_card_selected.emit(self)
