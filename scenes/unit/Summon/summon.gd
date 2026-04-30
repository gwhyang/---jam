extends Unit
class_name Summon

@onready var vision_area: Area2D = $VisionArea
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var summon_move_behavoir: MoveBehavoir = $SummonMoveBehavoir
@onready var target_getter: TargetGetter = %TargetGetter

var can_move := true

var knockback_dir: Vector2
var knockback_power: float

func _process(delta: float) -> void:
	if Global.game_paused: return
	
	if not can_move:
		return
	
	if not summon_move_behavoir:
		return
	
	# Movement is delegated to behavior nodes to support different summon AI types.
	summon_move_behavoir.move(delta)
	update_rotation()


func update_rotation() -> void:
	if not summon_move_behavoir:
		return
	if not summon_move_behavoir.velcity:
		return
	# Flip sprite by current move direction for quick left/right facing.
	var moving_right := summon_move_behavoir.velcity.x > 0
	visuals.scale = Vector2(-0.5, 0.5) if moving_right else Vector2(0.5, 0.5)

func apply_knockback(knock_dir: Vector2, knock_power: float) -> void:
	# Same knockback contract as Enemy, so existing hitboxes can reuse logic.
	knockback_dir = knock_dir
	knockback_power = knock_power
	if knockback_timer.time_left > 0:
		knockback_timer.stop()
		reset_knockback()
	
	knockback_timer.start()

func reset_knockback()-> void:
	knockback_dir = Vector2.ZERO
	knockback_power = 0.0

func destroy_enemy() -> void:
	can_move = false
	anim_player.play("die")
	await anim_player.animation_finished
	queue_free()


func _on_knockback_timer_timeout() -> void:
	reset_knockback()
	
func _on_hurtbox_component_on_damaged(hitbox: HitboxComponent) -> void:
	super._on_hurtbox_component_on_damaged(hitbox)
	
	if hitbox.knockback_power > 0:
		var dir := hitbox.source.global_position.direction_to(global_position)
		apply_knockback(dir, hitbox.knockback_power)


func _on_health_component_on_unit_died() -> void:
	# Used by arena/spawner systems to remove summon references safely.
	Global.on_summon_died.emit(self)
