# Buff System 设计文档（作用于 Unit）

## 1. 目标与范围
- Buff 只作用在 `Unit` 体系：`Player`、`Enemy`、`Summon`。
- Buff 系统负责：添加、叠层、持续时间、移除、生命周期回调。
- 本文档只定义系统设计与命名规范，不改代码实现。

## 2. 当前项目中的相关位置
- Unit 基类：`scenes/unit/unit.gd`
- 受击入口：`Unit._on_hurtbox_component_on_damaged(hitbox)`
- 血量与死亡：`scenes/components/health_component.gd`
- 受击框：`scenes/components/hurtbox_component.gd`
- 敌人死亡后逻辑：`scenes/unit/enemy/enemy.gd::_on_health_component_on_unit_died`
- 现有属性加减效果（可复用思路）：
  - `resources/item_effects/effects/add_status.gd`
  - `resources/item_effects/effects/remove_staus.gd`
- 速度乘数入口（减速/加速应改这里）：
  - `Unit.speed_multiplier`（默认 `1.0`）
  - `Unit.get_move_speed()`（统一返回 `stats.speed * speed_multiplier`）

## 3. 设计总览

### 3.1 BuffBase（资源基类）
建议新建：`resources/buffs/buff_base.gd`

字段建议：
- `buff_id: StringName`：全局唯一 ID（如 `split_on_death`）
- `display_name: String`
- `max_stacks: int = 1`
- `duration: float = 0.0`：`<=0` 代表永久 Buff（不自动过期）
- `refresh_mode`：叠加时的计时策略（`REFRESH`/`EXTEND`/`KEEP`）
- `tags: Array[StringName]`：如 `debuff`、`death_trigger`

回调接口建议：
- `on_apply(ctx)`：首次添加时
- `on_stack_changed(ctx, old_stacks, new_stacks)`：层数变化
- `on_before_take_damage(ctx)`：受击前
- `on_after_take_damage(ctx)`：受击后
- `on_before_die(ctx)`：确认死亡前
- `on_death(ctx)`：死亡确认后（但 queue_free 前）
- `on_tick(ctx, delta)`：持续效果（可选）
- `on_remove(ctx)`：移除时（用于还原属性等）

### 3.2 BuffRuntime（运行时实例）
建议新建：`scenes/unit/buff/buff_runtime.gd`

职责：
- 持有 `BuffBase` 资源与运行时状态。
- 记录 `stacks`、`remaining_time`、`source`、`applied_time`。
- 避免直接修改资源本体（资源是配置，Runtime 才是状态）。

### 3.3 BuffManager（Unit 子节点）
建议新建：`scenes/unit/buff/buff_manager.gd`

建议挂载位置：`Unit.tscn` 下新增节点 `BuffManager`。

职责：
- `add_buff(buff_def, stacks := 1, source := null)`
- `remove_buff(buff_id)`
- `has_buff(buff_id)`
- `get_buff_stacks(buff_id)`
- `_process(delta)` 自动计时与过期移除
- 在 Unit 生命周期关键点统一派发 Buff 回调

## 4. Buff 生命周期与回调时机

### 4.1 受击链路（现有代码对接）
当前入口在 `Unit._on_hurtbox_component_on_damaged`，建议流程：
1. BuffManager 调 `on_before_take_damage`
2. 走当前格挡、扣血、闪白逻辑
3. BuffManager 调 `on_after_take_damage`

### 4.2 死亡链路（现有代码对接）
当前死亡判定在 `HealthComponent.take_damage`，建议流程：
1. `current_health <= 0` 时先调 `on_before_die`
2. 继续现有 item 回调：`Global.callback_items(...)`
3. 若仍死亡，BuffManager 调 `on_death`
4. 发出 `on_unit_died`
5. `die()` -> `queue_free()`

说明：`on_death` 要发生在 `queue_free` 前，确保分裂、爆炸等还能拿到 owner 与坐标。

### 4.3 自动计时
- 每帧 `remaining_time -= delta`
- `remaining_time <= 0` 时：
  - 调 `on_remove`
  - 从 `active_buffs` 删除

## 5. 叠层与计时策略
- 同 `buff_id` 默认合并为一个 Runtime，通过 `stacks` 管理层数。
- 层数上限：`stacks <= max_stacks`
- 新增同类 Buff 时按 `refresh_mode`：
  - `REFRESH`：剩余时间重置为 `duration`
  - `EXTEND`：剩余时间增加 `duration`
  - `KEEP`：不改时间，仅加层
- `duration <= 0` 的 Buff 不参与自动过期。

## 6. 目前暂定 Buff 设计

### 6.1 分裂（Split On Death）
目标：死亡时生成 `n`（层数）个相同实体，血量 50%，大小 50%。

触发：
- 放在 `on_death(ctx)`。

行为定义：
- 生成数量：`n = stacks`
- 生成对象：与死亡单位同类型实体（同 `PackedScene`）
- 新生单位初始血量：`max_health * 0.5`（或当前项目定义的等价字段）
- 新生单位显示大小：`visuals.scale *= 0.5`

实现备注：
- 建议在运行时上下文里传入“原单位来源 scene 引用”或“可复用生成接口”，避免硬编码。
- 需要约束递归分裂（可选）：分裂体不再带分裂 Buff，或限制代数。

### 6.2 隐身（Invisible）
目标：持续时间内禁用受击框；死亡时爆炸。

触发与行为：
- `on_apply`：禁用 Hurtbox（如关闭 `monitoring` / `monitorable` 或禁用碰撞形状）
- `on_remove`：恢复 Hurtbox
- `on_death`：实例化爆炸 scene（当前 scene 尚未实现，先留接口）

注意：
- 与玩家冲刺无敌（`collision disabled`）机制并存时，避免互相覆盖状态。
- 建议由 BuffManager 维护“引用计数式禁用”以支持多个来源共同禁用。

### 6.2.1 死亡时爆炸（On Death Explosion）详细规范
目标：单位死亡时在原地生成爆炸效果，并对范围内目标造成伤害。

触发时机：
- 固定在 `on_death(ctx)`，且在 `queue_free` 前执行。

建议配置字段（放在爆炸类 Buff 或专用爆炸 Buff 中）：
- `explosion_scene: PackedScene`：爆炸场景引用（例如未来的 `scenes/effects/explosion.tscn`）
- `explosion_radius: float`
- `explosion_damage: float`
- `explosion_knockback: float = 0.0`
- `affect_self: bool = false`：是否会炸到自己（通常死亡时无意义，默认 false）
- `friendly_fire: bool = false`：是否伤害同阵营单位
- `damage_scale_per_stack: float = 0.0`：每层额外伤害系数（可选）

伤害归属建议：
- 爆炸伤害 `source` 指向死亡单位本身，便于后续统计击杀来源/特效来源。

层数联动建议：
- 若该 Buff 可叠层：`final_damage = explosion_damage * (1.0 + damage_scale_per_stack * (stacks - 1))`
- 不叠层时保持单次固定值即可。

与“隐身”关系：
- 可以做成“隐身 Buff 的死亡子效果”，也可以拆成独立 Buff（如 `death_explosion`）再由隐身附带添加。
- 推荐拆分：机制更干净，后续其他单位也可复用死亡爆炸而不必绑定隐身。

当前状态：
- 你项目里爆炸 scene 还没写，先在 Buff 文档层定义接口与参数，待场景完成后直接接入。

### 6.3 改动属性（Stat Modifier）
目标：添加时增加对应属性（可正可负），移除时还原。

建议数据结构：
- `modifiers: Array`，元素形如：
  - `stat_name: StringName`
  - `value_per_stack: float`

行为：
- `on_apply` / `on_stack_changed`：按新层数计算总增量并应用
- `on_remove`：撤销该 Buff 贡献的总增量

关键约束：
- 必须按“本 Buff 自己贡献了多少”来回滚，不能直接依赖当前面板值。
- 涉及 `health` 上限变化时，要同步处理 `current_health`（至少 clamp）。

### 6.4 减速（Slow）
目标：在持续时间内降低单位移速，公式为 `1 - slow_per_stack * n`，`n` 为层数。

实现文件：
- `resources/buffs/buff_slow.gd`
- `resources/buffs/defs/buff_slow.tres`

导出属性：
- `slow_per_stack: float`：每层减速比例，默认 `0.02`（每层 -2%）
- `max_stacks: int`：最大层数（继承自 `BuffBase`）
- `min_speed_multiplier: float`：速度乘数下限，防止速度变为 0 或负数
- `duration: float`：持续时间（继承自 `BuffBase`）

生效规则：
- `on_apply/on_stack_changed` 时重算速度乘数：
  - `new_multiplier = max(min_speed_multiplier, 1.0 - slow_per_stack * stacks)`
- `on_remove` 时恢复该 Buff 对乘数的影响。

重要约束：
- Slow Buff 只改 `Unit.speed_multiplier`，不直接改 `Unit.stats.speed`。
- 项目内移动逻辑统一通过 `get_move_speed()` 读取速度，这样玩家、敌人、召唤物都会吃到减速。

## 7. 用到的场景与文件建议

建议新增：
- `scenes/unit/buff/buff_manager.gd`
- `scenes/unit/buff/buff_runtime.gd`
- `resources/buffs/buff_base.gd`
- `resources/buffs/defs/*.tres`（具体 Buff 配置）

建议改动接入点：
- `scenes/unit/unit.tscn`：挂 `BuffManager`
- `scenes/unit/unit.gd`：受击前后回调入口
- `scenes/components/health_component.gd`：死亡前后回调入口
- （未来）爆炸场景：如 `scenes/effects/explosion.tscn`

## 8. 命名规范

### 8.1 文件命名
- 脚本：`snake_case.gd`
- Buff 资源：`buff_<effect>[_variant].tres`

示例：
- `buff_split_on_death.gd`
- `buff_invisible.gd`
- `buff_stat_modifier.gd`

### 8.2 类命名
- `PascalCase`
- 示例：`BuffBase`、`BuffManager`、`BuffSplitOnDeath`

### 8.3 Buff ID 命名
- 全小写 `snake_case`
- 只表达机制，不写数值
- 示例：
  - `split_on_death`
  - `invisible`
  - `stat_modifier`

### 8.4 回调命名
- 统一 `on_xxx`
- 建议固定集合，避免同义词并存（如 `on_die`/`on_death` 二选一）

## 9. 与现有 Item Effect 系统的边界
- Buff 是“持续状态层”。
- ItemEffect / `Global.callback_items` 是“触发执行层”。
- 推荐关系：
  - ItemEffect 负责添加/移除 Buff
  - Buff 负责持续效果与生命周期回调

这样可以减少把长期状态逻辑散落在 ItemEffect 里的情况。

## 10. 最小落地顺序（开发顺序建议）
1. 建 `BuffBase + BuffRuntime + BuffManager`
2. 把 `Unit` 受击与 `HealthComponent` 死亡节点接上回调
3. 先实现 `Stat Modifier`（最容易验证）
4. 再实现 `Invisible`
5. 实现独立 `Death Explosion`（可先不做美术，只验证伤害与范围）
6. 最后实现 `Split On Death`
