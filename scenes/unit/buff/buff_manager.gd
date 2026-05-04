extends Node
class_name BuffManager

var owner_unit: Unit
# Active buffs are keyed by buff_id and merged by stack.
var active_buffs: Dictionary = {}
# Reference-counted hurtbox lock to avoid state conflicts across buffs.
var hurtbox_disable_count := 0

func setup(unit: Unit) -> void:
	owner_unit = unit
	set_process(true)

func _process(delta: float) -> void:
	if not owner_unit:
		return
	
	var expired_ids: Array[StringName] = []
	for buff_id: StringName in active_buffs.keys():
		var runtime: BuffRuntime = active_buffs[buff_id]
		var ctx := _make_context(runtime)
		ctx.delta = delta
		runtime.buff_def.on_tick(ctx, delta)
		if runtime.is_permanent():
			continue
		# Countdown only runtime instances, resource config is immutable.
		runtime.remaining_time -= delta
		if runtime.remaining_time <= 0.0:
			expired_ids.append(buff_id)
	
	for buff_id in expired_ids:
		remove_buff(buff_id)
#FIXME 问题应该是这个buff上到玩家上面了
func add_buff(buff_def: BuffBase, stacks := 1, source: Node = null) -> void:
	if not buff_def or buff_def.buff_id.is_empty():
		return
	print(111)
	var incoming := maxi(1, stacks)
	var existing: BuffRuntime = active_buffs.get(buff_def.buff_id)
	if not existing:
		# First time this buff_id appears on this unit.
		var runtime := BuffRuntime.new(buff_def, incoming, source)
		runtime.stacks = min(runtime.stacks, max(1, buff_def.max_stacks))
		active_buffs[buff_def.buff_id] = runtime
		var apply_ctx := _make_context(runtime)
		buff_def.on_apply(apply_ctx)
		if runtime.stacks > 1:
			buff_def.on_stack_changed(apply_ctx, 1, runtime.stacks)
		return
	print(owner_unit)
	print("existing stack: %d" %existing.stacks)
	var old_stacks := existing.stacks
	existing.stacks = min(existing.stacks + incoming, max(1, existing.buff_def.max_stacks))
	existing.source = source
	# Stack behavior is data-driven per buff definition.
	match existing.buff_def.refresh_mode:
		BuffBase.RefreshMode.REFRESH:
			existing.remaining_time = existing.buff_def.duration
		BuffBase.RefreshMode.EXTEND:
			existing.remaining_time += existing.buff_def.duration
		BuffBase.RefreshMode.KEEP:
			pass
	var stack_ctx := _make_context(existing)
	existing.buff_def.on_stack_changed(stack_ctx, old_stacks, existing.stacks)
func remove_buff(buff_id: StringName) -> void:
	var runtime: BuffRuntime = active_buffs.get(buff_id)
	if not runtime:
		return
	var remove_ctx := _make_context(runtime)
	runtime.buff_def.on_remove(remove_ctx)
	active_buffs.erase(buff_id)

func has_buff(buff_id: StringName) -> bool:
	return active_buffs.has(buff_id)

func get_buff_stacks(buff_id: StringName) -> int:
	var runtime: BuffRuntime = active_buffs.get(buff_id)
	if not runtime:
		return 0
	return runtime.stacks

func on_before_take_damage(hitbox: HitboxComponent, blocked: bool, damage: float) -> void:
	# We only pass read context today; future buffs can mutate by conventions.
	for runtime: BuffRuntime in active_buffs.values():
		var ctx := _make_context(runtime)
		ctx.hitbox = hitbox
		ctx.blocked = blocked
		ctx.damage = damage
		runtime.buff_def.on_before_take_damage(ctx)

func on_after_take_damage(hitbox: HitboxComponent, blocked: bool, damage: float) -> void:
	for runtime: BuffRuntime in active_buffs.values():
		var ctx := _make_context(runtime)
		ctx.hitbox = hitbox
		ctx.blocked = blocked
		ctx.damage = damage
		runtime.buff_def.on_after_take_damage(ctx)

func on_before_die() -> void:
	for runtime: BuffRuntime in active_buffs.values():
		var ctx := _make_context(runtime)
		runtime.buff_def.on_before_die(ctx)

func on_death() -> void:
	for runtime: BuffRuntime in active_buffs.values():
		var ctx := _make_context(runtime)
		runtime.buff_def.on_death(ctx)

func set_hurtbox_enabled(enabled: bool) -> void:
	# Multiple buffs may request disable simultaneously, so we use ref counting.
	if enabled:
		hurtbox_disable_count = max(0, hurtbox_disable_count - 1)
	else:
		hurtbox_disable_count += 1
	owner_unit.set_hurtbox_enabled(hurtbox_disable_count == 0)

func _make_context(runtime: BuffRuntime) -> BuffContext:
	var ctx := BuffContext.new()
	ctx.unit = owner_unit
	ctx.buff_manager = self
	ctx.buff_runtime = runtime
	ctx.source = runtime.source
	return ctx
