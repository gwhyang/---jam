extends Area2D
class_name DeathExplosion

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
var source: Unit

var _ring_t := 0.0
var _core_t := 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# 只做一次判定，关闭监测并使用物理查询命中目标。
	monitoring = false
	monitorable = false
	
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision_shape.shape = shape
	
	await get_tree().physics_frame
	_explode_once()
	_play_visuals()

func _explode_once() -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = global_transform
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask
	
	var results := space_state.intersect_shape(query, 256)
	var final_damage := base_damage * (1.0 + damage_scale_per_stack * float(stacks - 1))
	for result: Dictionary in results:
		var collider = result.get("collider")
		if not (collider is HurtboxComponent):
			continue
		var hurtbox := collider as HurtboxComponent
		var unit := hurtbox.owner as Unit
		if not unit or unit == source:
			continue
		if source and source.stats and unit.stats and not friendly_fire:
			if source.stats.type == unit.stats.type:
				continue
		
		# 复用现有受击链路，构造一次临时 hitbox。
		var hitbox := HitboxComponent.new()
		hitbox.setup(final_damage, false, knockback_power, source)
		hurtbox.on_damaged.emit(hitbox)

func _play_visuals() -> void:
	# 双通道视觉：核心快速闪烁 + 外环扩散淡出。
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_method(func(v: float):
		_ring_t = v
		queue_redraw(), 0.0, 1.0, visual_duration)
	tween.tween_method(func(v: float):
		_core_t = v
		queue_redraw(), 0.0, 1.0, visual_duration * 0.7)
	await tween.finished
	queue_free()

func _draw() -> void:
	# 外环
	var ring_r := lerpf(radius * 0.15, radius, _ring_t)
	var ring_w := lerpf(radius * 0.35, 2.0, _ring_t)
	var ring_a := lerpf(0.95, 0.0, _ring_t)
	var rc := ring_color
	rc.a = ring_a
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 64, rc, ring_w, true)
	
	# 核心闪光
	var core_r := lerpf(radius * 0.45, radius * 0.12, _core_t)
	var core_a := lerpf(0.85, 0.0, _core_t)
	var cc := core_color
	cc.a = core_a
	draw_circle(Vector2.ZERO, core_r, cc)
