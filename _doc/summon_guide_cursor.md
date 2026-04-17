# 召唤物（Summon）功能说明

本文记录当前项目召唤物系统的结构、配置方式、测试方式与接入要点。

## 1. 相关文件

核心脚本与场景：

- `scenes/unit/Summon/summon.gd`
- `scenes/unit/Summon/summon_move_behavoir.gd`
- `scenes/unit/Summon/move_behavior/near_wondering.gd`
- `scenes/unit/Summon/summon_base.tscn`
- `scenes/unit/Summon/summon_defense.tscn`

系统联动：

- `scenes/arena/spawner.gd`（提供通用`spawn()`方法）
- `autoloads/global.gd`（`on_summon_died`信号）
- `fortest/try_spawn_summon.gd`（测试脚本）
- `scenes/arena/arena.tscn`（挂载测试节点）
- `project.godot`（新增测试输入与碰撞层）

## 2. 运行逻辑

`Summon`继承`Unit`，复用血量、受伤和死亡动画逻辑；召唤物自身主要负责：

- 每帧调用行为节点的`move(delta)`
- 根据行为速度方向翻转朝向
- 处理击退
- 死亡时发送`Global.on_summon_died`

行为通过`SummonMoveBehavoir`抽象，具体实现为`near_wondering.gd`：

- `WONDER`状态：在玩家附近随机游走
- `CHASE`状态：距离玩家过远时回追
- 到达近距离后切回`WONDER`

## 3. 场景配置要点

## 3.1 `summon_base.tscn`

基于`unit.tscn`实例化，绑定：

- 主脚本：`summon.gd`
- 默认行为脚本：`summon_move_behavoir.gd`
- 召唤物碰撞层/遮罩（与敌我层区分）

## 3.2 `summon_defense.tscn`

在`sumon_base`上替换具体配置：

- 行为脚本改为`near_wondering.gd`
- 贴图、碰撞体大小
- `stats`资源（当前为`UnitStats`子资源）

## 4. 测试方式

通过`fortest/try_spawn_summon.gd`：

- `test`键：切换测试模式
- 测试模式下按`atk`：在鼠标位置`Game.spawn(summon, mouse_pos)`

注意：`project.godot`里新增了`test`输入映射和召唤物碰撞层命名。

## 5. 扩展新召唤物步骤

1) 复制`summon_defense.tscn`为新召唤物场景
2) 调整`stats`、贴图与碰撞形状
3) 新增或替换行为脚本（继承`SummonMoveBehavoir`）
4) 在测试脚本或技能逻辑里调用`Game.spawn(你的场景, 位置)`
5) 验证死亡信号、碰撞层、移动状态切换

---

作者：cursor
