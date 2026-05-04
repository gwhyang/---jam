extends BuffBase
class_name BuffStatModifier

## 属性改动生效目标。
enum TargetScope {
	## 作用于 Buff 持有者。
	SELF,
	## 始终作用于 `Global.player`。
	PLAYER
}

## 要修改的 `UnitStats` 字段名（如 damage/speed/health/extra_summon_damage）。
@export var stat_name: StringName
## 每层增加（或减少）的数值，可为负数。
@export var value_per_stack := 0.0
## 目标作用域：SELF=自己，PLAYER=玩家。
@export var target_scope: TargetScope = TargetScope.SELF

var _applied_total := 0.0

func on_apply(ctx: BuffContext) -> void:
	_reapply(ctx, 0, ctx.buff_runtime.stacks)

func on_stack_changed(ctx: BuffContext, old_stacks: int, new_stacks: int) -> void:
	_reapply(ctx, old_stacks, new_stacks)

func on_remove(ctx: BuffContext) -> void:
	if _applied_total == 0.0:
		return
	_apply_to_unit(ctx, -_applied_total)
	_applied_total = 0.0

func _reapply(ctx: BuffContext, _old_stacks: int, new_stacks: int) -> void:
	if _applied_total != 0.0:
		_apply_to_unit(ctx, -_applied_total)
	var total := value_per_stack * new_stacks
	_apply_to_unit(ctx, total)
	_applied_total = total

func _apply_to_unit(ctx: BuffContext, value: float) -> void:
	var target_unit := _resolve_target_unit(ctx)
	if not target_unit or not target_unit.stats:
		return
	var property_exists := false
	for p in target_unit.stats.get_property_list():
		if p.name == String(stat_name):
			property_exists = true
			break
	if not property_exists:
		push_warning("BuffStatModifier: stat '%s' not found on target unit stats." % stat_name)
		return
	target_unit.stats[stat_name] += value
	if stat_name == &"health":
		target_unit.health_component.max_health = target_unit.stats.health
		target_unit.health_component.current_health = clampf(
			target_unit.health_component.current_health,
			0.0,
			target_unit.health_component.max_health
		)
		target_unit.health_component.on_health_changed.emit(
			target_unit.health_component.current_health,
			target_unit.health_component.max_health
		)

func _resolve_target_unit(ctx: BuffContext) -> Unit:
	if target_scope == TargetScope.PLAYER:
		return Global.player
	return ctx.unit
