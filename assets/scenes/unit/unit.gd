extends Node2D
class_name Unit

@export var stats: UnitStats

@onready var visuals: Node2D = %Visuals
@onready var sprite: Sprite2D = %Sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var flash_timer: Timer = $FlashTimer
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var buff_manager: BuffManager = %BuffManager

## Runtime movement speed multiplier. Buffs should modify this instead of stats.speed.
var speed_multiplier := 1.0

func _ready() -> void:
	health_component.setup(stats)
	buff_manager.setup(self)
	

func set_flash_material() -> void:
	sprite.material = Global.FLASH_MATERIAL
	flash_timer.start()


func _on_hurtbox_component_on_damaged(hitbox: HitboxComponent) -> void:
	if health_component.current_health <= 0:
		return
	
	var blocked := Global.get_chance_sucess(stats.block_chance / 100)
	# Buffs can react before built-in block/damage logic executes.
	buff_manager.on_before_take_damage(hitbox, blocked, hitbox.damage)
	if blocked:
		Global.on_create_block_text.emit(self)
		buff_manager.on_after_take_damage(hitbox, blocked, 0.0)
		return
	
	set_flash_material()
	health_component.take_damage(hitbox.damage)
	Global.on_create_damage_text.emit(self, hitbox)
	# Notify buffs after final damage application.
	buff_manager.on_after_take_damage(hitbox, false, hitbox.damage)
	
	
	

func _on_flash_timer_timeout() -> void:
	sprite.material = null

func set_hurtbox_enabled(enabled: bool) -> void:
	if not hurtbox_component:
		return
	hurtbox_component.set_deferred("monitoring", enabled)
	hurtbox_component.set_deferred("monitorable", enabled)

func get_move_speed() -> float:
	return stats.speed * speed_multiplier
