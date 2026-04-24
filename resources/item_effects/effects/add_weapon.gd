extends ItemEffect
class_name AddWeapon

@export var weapon:ItemWeapon

func effect(context:EffectContext)->bool:
	if not (context.trigger_type): return false
	# Equip-time: instantiate and register weapon into global equipped list.
	if context.trigger_type == Global.ItemCallBack.ONEQUIP:
		Global.player.add_weapon(weapon)
		Global.equipped_weapons.append(weapon)
	# Unequip-time: remove the instance and global reference.
	if context.trigger_type == Global.ItemCallBack.ONUNLOAD:
		Global.player.current_weapons.erase(weapon)
		Global.equipped_weapons.erase(weapon.data)
		weapon.queue_free()
	return true
