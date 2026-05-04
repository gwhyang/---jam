extends Resource
class_name BuffBase

## 同一 `buff_id` 再次添加时，持续时间如何处理。
enum RefreshMode {
	## 剩余时间重置为 `duration`。
	REFRESH,
	## 剩余时间额外增加一个 `duration`。
	EXTEND,
	## 保持原剩余时间不变。
	KEEP
}

## Buff 的唯一运行时 ID，建议全局唯一且稳定。
@export var buff_id: StringName
## 展示名称，用于 UI/调试。
@export var display_name := ""
## 单个单位上该 Buff 的最大层数。
@export var max_stacks := 1
## 持续时间（秒），`<= 0` 代表永久 Buff（不会自动过期）。
@export var duration := 0.0
## 同类 Buff 叠加时的计时刷新策略。
@export var refresh_mode: RefreshMode = RefreshMode.REFRESH
## 可选标签，便于分类筛选（例如 debuff/control/death_trigger）。
@export var tags: Array[StringName] = []

func on_apply(_ctx: BuffContext) -> void:
	pass

func on_stack_changed(_ctx: BuffContext, _old_stacks: int, _new_stacks: int) -> void:
	pass

func on_before_take_damage(_ctx: BuffContext) -> void:
	pass

func on_after_take_damage(_ctx: BuffContext) -> void:
	pass

func on_before_die(_ctx: BuffContext) -> void:
	pass

func on_death(_ctx: BuffContext) -> void:
	pass

func on_tick(_ctx: BuffContext, _delta: float) -> void:
	pass

func on_remove(_ctx: BuffContext) -> void:
	pass
