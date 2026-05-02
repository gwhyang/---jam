# 怪物配置与功能整理

本文整理当前项目中怪物系统的配置方式、运行链路，以及所有相关场景和脚本，便于后续扩展新怪物。

## 1. 怪物系统总览

当前怪物系统由 4 层组成：

1) `Unit`基类层（通用受伤/血量/闪白）
2) `Enemy`基类层（追击移动、击退、死亡事件）
3) 怪物变体场景层（慢速/中速/快速追击、冲锋、射手）
4) 波次与生成层（`WaveData` + `Spawner`按权重刷怪）

简化流程：

- `Arena`开局调用`Spawner.start_wave()`
- `Spawner`按`WaveData`定时生成怪物场景
- 怪物实例读取自己的`stats_enemy_*.tres`
- 怪物行为脚本（如`shooting_behavior.gd`、`charge_behavior.gd`）驱动特殊攻击
- 怪物死亡时发出`Global.on_enemy_died`，Arena负责掉金币

## 2. 怪物如何配置（实操步骤）

## 2.1 新增一个怪物 Stats（数值资源）

在目录：

- `resources/units/enemies/`

创建或复制一个`stats_enemy_xxx.tres`，关键字段来自`UnitStats`：

- `health` / `health_increase_per_wave`
- `damage` / `damage_increase_per_wave`
- `speed`
- `block_chance`
- `gold_drop`
- `type`（敌人应为`ENEMY`）

字段定义脚本：

- `resources/units/unit_stats.gd`

## 2.2 新增一个怪物场景

推荐做法：（通常以`enemy_chaser_slow.tscn`为模板），在文件系统中右键，新建继承场景

怪物场景目录：

- `scenes/unit/enemy/`

每个怪物场景最关键是绑定：

- `script = res://scenes/unit/enemy/enemy.gd`
- `stats = res://resources/units/enemies/stats_enemy_xxx.tres`
- `Visuals/Sprite.texture = 对应敌人贴图`

如果是特殊行为怪物，再挂行为节点：

- 射手：挂`ShootingBehavior`（脚本`shooting_behavior.gd`）
- 冲锋：挂`ChargeBehavior`（脚本`charge_behavior.gd`）

## 2.3 让新怪物进入波次刷新

波次数据在：

- `resources/waves/data/wave_1_to_5.tres`

每个`WaveData`里有`units: Array[WaveUnitData]`，你需要新增一个`WaveUnitData`子资源并设置：

- `unit_scene = 你的怪物场景`
- `weight = 刷新权重`

`Spawner`每次刷怪通过`WaveData.get_random_unit_scene()`按权重随机。

相关脚本：

- `resources/waves/wave_data.gd`
- `resources/waves/wave_unit_data.gd`
- `scenes/arena/spawner.gd`

## 3. 怪物功能拆解

## 3.1 基础战斗与生存

`Unit`层（`scenes/unit/unit.gd`）：

- 初始化血量组件：`health_component.setup(stats)`
- 处理受伤、格挡判定、闪白表现
- 更新伤害飘字事件

`Enemy`层（`scenes/unit/enemy/enemy.gd`）：

- 朝玩家移动（`get_move_direction()`）
- 群体分离（VisionArea内互相推开，避免重叠）
- 距离过近时停靠（`can_move_towards_player()`）
- 处理击退（`apply_knockback` + `KnockbackTimer`）
- 死亡动画与销毁（`destroy_enemy()`）
- 死亡事件：`Global.on_enemy_died.emit(self)`

## 3.2 生成与回收

`scenes/arena/spawner.gd`：

- `spawn_enemy()`：播放出生特效后实例化敌人
- `spawned_enemies`：记录本波怪物
- `clear_enemies()`：波次结束时清场
- `update_enemies_new_wave()`：每波给`enemy_collection`里的stats做成长（血量/伤害）

出生特效资源：

- 场景：`scenes/effects/enemy_spawn_effect.tscn`
- 脚本：`scenes/effects/enemy_spawn_effect.gd`

## 3.3 特殊行为

### 射手（Shooter）

相关：

- 场景：`scenes/unit/enemy/enemy_shooter.tscn`
- 行为脚本：`scenes/unit/enemy/shooting_behavior.gd`
- 子弹场景：`scenes/projectiles/projectile_enemy.tscn`

逻辑：

- 到冷却后停止移动
- 朝玩家方向按扇形角度发射多弹丸（`projectile_count` + `arc_angle`）
- 等待 1 秒后恢复移动

### 冲锋怪（Charger）

相关：

- 场景：`scenes/unit/enemy/enemy_charger.tscn`
- 行为脚本：`scenes/unit/enemy/charge_behavior.gd`

逻辑：

- 冷却结束后锁定玩家当前位置
- 先播`charge`预备动画
- 以高倍速度冲向锁定点
- 接近目标点后结束冲锋并恢复常规移动

## 4. 当前项目怪物相关文件全清单

## 4.1 场景（PackedScene）

- `scenes/unit/enemy/enemy_chaser_slow.tscn`
- `scenes/unit/enemy/enemy_chaser_mid.tscn`
- `scenes/unit/enemy/enemy_chaser_fast.tscn`
- `scenes/unit/enemy/enemy_charger.tscn`
- `scenes/unit/enemy/enemy_shooter.tscn`
- `scenes/projectiles/projectile_enemy.tscn`
- `scenes/effects/enemy_spawn_effect.tscn`
- `scenes/unit/unit.tscn`（怪物继承的通用单位场景）

## 4.2 脚本（GDScript）

- `scenes/unit/enemy/enemy.gd`
- `scenes/unit/enemy/shooting_behavior.gd`
- `scenes/unit/enemy/charge_behavior.gd`
- `scenes/arena/spawner.gd`
- `scenes/arena/arena.gd`
- `scenes/effects/enemy_spawn_effect.gd`
- `resources/waves/wave_data.gd`
- `resources/waves/wave_unit_data.gd`
- `resources/units/unit_stats.gd`
- `scenes/unit/unit.gd`
- `autoloads/global.gd`（怪物死亡信号与生成特效常量）

## 4.3 敌人数值资源（tres）

- `resources/units/enemies/stats_enemy_chaser_slow.tres`
- `resources/units/enemies/stats_enemy_chaser_mid.tres`
- `resources/units/enemies/stats_enemy_chaser_fast.tres`
- `resources/units/enemies/stats_enemy_charger.tres`
- `resources/units/enemies/stats_enemy_shooter.tres`

## 4.4 波次资源（tres）

- `resources/waves/data/wave_1_to_5.tres`

## 5. 可直接复用的“新怪物接入模板”

1) 复制`enemy_chaser_slow.tscn`为`enemy_xxx.tscn`
2) 复制`stats_enemy_chaser_slow.tres`为`stats_enemy_xxx.tres`并改数值
3) 在`enemy_xxx.tscn`把`stats`指向`stats_enemy_xxx.tres`
4) 需要特殊攻击时挂行为节点和行为脚本
5) 在`wave_1_to_5.tres`新增`WaveUnitData`并配置`unit_scene + weight`
6) 运行验证刷新概率、移动/攻击、死亡掉落是否正常

## 6. 备注（当前数据观察）

- 部分`stats_enemy_*.tres`中的`name/icon`与文件名存在不一致现象（例如文件名与显示名不同），不会阻止运行，但建议后续统一命名，便于策划调参和排查。

---

作者：cursor
