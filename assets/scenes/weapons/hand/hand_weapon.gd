extends Weapon
class_name HandWeapon
@export var atk_buffer:float = 0.15 #输入缓冲

var atk_buffer_timer:float = 0
var target_global_posi:Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.game_paused: return
	
	if not is_attacking:
		if targets.size() > 0:
			update_closest_target()
		else:
			closest_target = null

	rotate_to_target()
	update_visuals()


	if can_use_weapon():
		print(atk_buffer_timer)
		atk_buffer_timer = 0
		use_weapon()
		
	timers(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("atk"):
		atk_input()

func timers(delta:float):
	atk_buffer_timer -=atk_buffer

func atk_input():
	if Global.game_paused: return
	atk_buffer_timer = atk_buffer

func can_use_weapon() -> bool:
	return cooldown_timer.is_stopped() and atk_buffer_timer >= 0

func get_custom_rotation_to_target() -> float:
	if not target_global_posi:
		return rotation

	var rot := global_position.direction_to(target_global_posi).angle()
	return rot + weapon_spread


func get_rotation_to_target() -> float:
	target_global_posi=get_global_mouse_position()
	#if targets.size() ==0:
	#	return get_idle_rotation()

	var rot := global_position.direction_to(target_global_posi).angle()
	return rot
