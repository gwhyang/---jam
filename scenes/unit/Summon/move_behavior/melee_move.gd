extends NearWonderMove


@export var target_getter:TargetGetter
@onready var hitbox_component: HitboxComponent = $"../HitboxComponent"
@export var cool_down:float = 0.3
@export var chase_duration:float = 0.2
@export var chase_length:float = 130

var cool_down_timer:float = 0
var chase_tween:Tween

func move(delta:float):
	if chase_tween:
		if chase_tween.is_running():
			return
	
	var player_posi := Global.player.global_position
	
	if not target_getter.target:
		target_getter.get_target()
		return
	if parent.global_position.distance_to(player_posi) >= far_dist:
		super(delta)
		return
	var target_posi := target_getter.target.global_position
	current_dir = parent.global_position.direction_to(target_posi)
	
	cool_down -= delta
	if cool_down > 0:
		velcity = current_dir*normal*parent.stats.speed
		parent.position += velcity*delta
		return
		
	hitbox_component.enable()
	var stats:=parent.stats
	var player_ststs := Global.player.stats
	var dmg := stats.damage+(player_ststs.damage)/3
	
	hitbox_component.setup(dmg,false,1,parent)#TODO
	chase_tween  = create_tween()
	chase_tween.tween_property(parent,"global_position",global_position+current_dir*chase_length,chase_duration)
	chase_tween.finished.connect(reset_cooldown)
	chase_tween.set_ease(Tween.EASE_OUT)
	chase_tween.set_trans(Tween.TRANS_SINE)

func reset_cooldown():
	cool_down_timer = cool_down
	hitbox_component.disable()
