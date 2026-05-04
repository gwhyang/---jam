extends BuffBase
class_name BuffSlow

## 每层减速比例。
## 例如 0.02 表示每层降低 2% 移速。
@export_range(0.0, 1.0, 0.001) var slow_per_stack := 0.02
## 速度乘数下限，避免速度降到 0 或负数。
@export_range(0.01, 1.0, 0.01) var min_speed_multiplier := 0.1

var _applied_delta := 0.0

func on_apply(ctx: BuffContext) -> void:
	_reapply(ctx, ctx.buff_runtime.stacks)

func on_stack_changed(ctx: BuffContext, _old_stacks: int, new_stacks: int) -> void:
	_reapply(ctx, new_stacks)

func on_remove(ctx: BuffContext) -> void:
	if not is_instance_valid(ctx.unit):
		return
	ctx.unit.speed_multiplier += _applied_delta
	_applied_delta = 0.0

func _reapply(ctx: BuffContext, stacks: int) -> void:
	if not is_instance_valid(ctx.unit):
		return
	# 先回滚该 Buff 的旧贡献，再按新层数重算。
	ctx.unit.speed_multiplier += _applied_delta
	var new_multiplier := maxf(min_speed_multiplier, 1.0 - slow_per_stack * float(stacks))
	_applied_delta = 1.0 - new_multiplier
	ctx.unit.speed_multiplier = new_multiplier
	print(ctx.unit.speed_multiplier)
