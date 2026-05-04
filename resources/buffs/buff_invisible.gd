extends BuffBase
class_name BuffInvisible


func on_apply(ctx: BuffContext) -> void:
	# 隐身期间关闭受击框。
	ctx.buff_manager.set_hurtbox_enabled(false)

func on_remove(ctx: BuffContext) -> void:
	ctx.buff_manager.set_hurtbox_enabled(true)
