extends BuffBase
class_name BuffExplodeOnDeath
enum SourceMode{PLAYER,SELF}
const DEATH_EXPLOSION = preload("uid://jwlbwk7kciaj")
## 爆炸碰撞掩码，默认为只打enemy
@export_flags_2d_physics var mask:int = 0b1000
## 爆炸伤害来源归属，PLAYER来源为player，SELF来源记为buff持有者
@export var source_mode:SourceMode = SourceMode.PLAYER
## 爆炸判定半径。
@export var radius := 80.0
## 基础伤害（叠层前）。
@export var base_damage := 8.0
## 爆炸击退强度。
@export var knockback_power := 0.0
## 是否伤害同阵营单位。
@export var friendly_fire := false
## 每层额外伤害系数：final = base * (1 + scale * (stacks - 1)).
@export var damage_scale_per_stack := 0.0

## 视觉总时长（秒）。
@export var visual_duration := 0.25
## 爆炸主色。
@export var ring_color: Color = Color(1.0, 0.55, 0.2, 0.95)
## 爆炸高光色。
@export var core_color: Color = Color(1.0, 0.9, 0.6, 1.0)

var stacks := 1




func on_death(ctx: BuffContext) -> void:
	if not is_instance_valid(ctx.unit):
		return
	# 参数契约先固定，后续可直接接入真实爆炸实现。
	var explosion:= DEATH_EXPLOSION.instantiate() as DeathExplosion
	
	explosion.radius = radius
	explosion.base_damage = base_damage
	explosion.knockback_power = knockback_power
	explosion.friendly_fire = friendly_fire
	explosion.damage_scale_per_stack = damage_scale_per_stack
	explosion.visual_duration = visual_duration
	explosion.ring_color = ring_color
	explosion.core_color = core_color
	explosion.stacks = stacks
	explosion.source = ctx.unit if source_mode == SourceMode.SELF else Global.player
	
	Game.add(explosion,ctx.unit.global_position)
	
