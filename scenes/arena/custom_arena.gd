extends Arena
@export var wave_count:int = 10
@onready var equip_panel: EquipPanel = %EquipPanel
@onready var end_panel: EndPanel = $GameUI/EndPanel

func _ready() -> void:
	super()
	Game.add_node.connect(spawner.add_node)

func _on_spawner_on_wave_completed() -> void:
	if spawner.wave_index>= wave_count:
		game_win()
		return
	if not Global.player: return
	clean_arena()
	#await get_tree().create_timer(1.0).timeout
	# Custom flow: open equip panel directly instead of shop panel.
	#equip_panel.show()
	shop_panel.load_shop(spawner.wave_index)
	shop_panel.show()
	clean_arena()


func next_wave() -> void:
	Global.game_statistic["gained turn"] = spawner.wave_index
	equip_panel.hide()
	shop_panel.hide()
	start_new_wave()

func initialize_run()->void:
	equip_panel.clear_slots()
	shop_panel.reset()
	clean_arena()
	spawner.wave_index = 1

func _on_selection_panel_on_selection_completed() -> void:
	var initial_item_card = equip_panel.add_equipment_item_card(Global.main_skull_item_selected)
	
	initial_item_card.hide()
	equip_panel.equip_item(Global.BoneSlot.head,Global.main_skull_item_selected)
	equip_panel.slot_card[Global.BoneSlot.head] = initial_item_card
	super()

func game_win():
	Global.game_paused = true
	Game.game_win.emit()
	print("win")
