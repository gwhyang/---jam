extends Control
@export var item_tooltip_scene:PackedScene

var ui2tooltip:Dictionary[Control,TooltipCard]

func _ready() -> void:
	Game.show_item_tooltip.connect(show_tooltip)
	Game.hide_item_tooltip.connect(hide_tooltip)

func show_tooltip(card:ItemCard):
	var tooltip= ui2tooltip.get(card)
	if not tooltip:
		tooltip = item_tooltip_scene.instantiate() as TooltipCard
		add_child(tooltip)
		set_tooltip_posi(card,tooltip)
		tooltip.item = card.item
		ui2tooltip[card] = tooltip
	tooltip.show()

func set_tooltip_posi(card:ItemCard,tooltip:TooltipCard):
	var card_center:Vector2 = card.global_position + card.size/2
	var half_screen_size:=get_viewport_rect().size /2
	if card_center.x <= half_screen_size.x:
		tooltip.global_position.x = card.global_position.x + card.size.x
	else:
		tooltip.global_position.x = card.global_position.x - tooltip.size.x
	
	
	if card_center.y <= half_screen_size.y:
		tooltip.global_position.y = card.global_position.y
	else:
		tooltip.global_position.y = card.global_position.y + card.size.y - tooltip.size.y
	

func hide_tooltip(card:ItemCard):
	var tooltip= ui2tooltip.get(card)
	print("hhid")
	print(tooltip)
	if not tooltip: 
		push_error("Tool tip not found.")
		return
	tooltip.hide()
