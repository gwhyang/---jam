extends Arena
@onready var equip_panel: Panel = %EquipPanel
@onready var end_panel: EndPanel = $GameUI/EndPanel

func _on_spawner_on_wave_completed() -> void:
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
