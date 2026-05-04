extends BuffBase
class_name BuffSplitOnDeath

## 新生单位的当前血量比例（相对于其最大血量）。
@export var hp_ratio := 0.5
## 新生单位的显示缩放倍率。
@export var scale_ratio := 0.5
## 是否保留子单位自身启动时携带的 Buff。
@export var inherit_buffs := false

func on_death(ctx: BuffContext) -> void:
	if not ctx.unit:
		return
	var path := ctx.unit.scene_file_path
	if path.is_empty():
		return
	var scene := load(path) as PackedScene
	if not scene:
		return
	var amount := ctx.buff_runtime.stacks
	for i in range(amount):
		var child := scene.instantiate() as Unit
		if not child:
			continue
		# 让子单位在死亡点周围散开，避免完全重叠。
		child.global_position = ctx.unit.global_position + Vector2.RIGHT.rotated(TAU * float(i) / max(1, amount)) * 16.0
		ctx.unit.get_parent().add_child(child)
		if child.stats:
			# 新生血量按比例缩放。
			child.health_component.max_health = child.stats.health
			child.health_component.current_health = child.health_component.max_health * hp_ratio
			child.health_component.on_health_changed.emit(child.health_component.current_health, child.health_component.max_health)
		child.visuals.scale *= scale_ratio
		if not inherit_buffs and child.buff_manager:
			child.buff_manager.remove_buff(buff_id)
