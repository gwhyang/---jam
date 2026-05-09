extends MoveBehavoir
class_name NearWonderMove
enum MoveState{WONDER,CHASE}
@export var fast := 1.7 ## 追赶速度倍率
@export var normal := 1.0 ## 闲逛速度倍率

@export var near_dist:= 150.0
@export var far_dist := 300.0
@export var wonder_time_range:Vector2 = Vector2(0.3,1.5)


var current_state:= MoveState.WONDER
var current_dir:Vector2
var change_dir_time:float

func move(delta:float):
	# This behavior keeps parent near player by switching between wandering and chasing.
	var player_posi:= Global.player.global_position
	change_dir_time -= delta
	match current_state:
		MoveState.WONDER:
			# Too far from player -> chase back.
			if parent.global_position.distance_to(player_posi) >= far_dist:
				current_state = MoveState.CHASE
				change_dir_time = 0
				return
			# Wander with periodic random direction changes.
			if change_dir_time <= 0:
				change_dir_time = randf_range(wonder_time_range.x,wonder_time_range.y)
				current_dir = Vector2.LEFT.rotated(randf()*TAU)
			velcity = current_dir * normal * parent.get_move_speed()
		MoveState.CHASE:
			# Close enough -> switch back to local wandering.
			if parent.global_position.distance_to(player_posi) <=near_dist:
				current_state = MoveState.WONDER
				return
			current_dir = parent.global_position.direction_to(player_posi)
			velcity = current_dir * fast * parent.get_move_speed()
	
	parent.position += velcity*delta
