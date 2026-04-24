extends Arena
@onready var equip_panel: Panel = %EquipPanel

func _on_spawner_on_wave_completed() -> void:
	if not Global.player: return
	clean_arena()
	#await get_tree().create_timer(1.0).timeout
	# Custom flow: open equip panel directly instead of shop panel.
	equip_panel.show()
	clean_arena()
