extends Node2D
class_name TargetGetter
enum Team{PLAYER,SUMMON,ENEMY}

const grid_size:float = 64
@export var team_type:Team
@export_range(0,1) var stay_chance_ratio:float = 0.6
@export var dist_weight_per_grid:float = 50
@export_range(0,1) var dist_weight_ratio:float = 0.6

var target:Unit

func _process(_delta: float) -> void:
	if Global.game_paused:
		return
	if not target:
		target = get_target()

func get_target()->Unit:
	
	var units:Array[Unit]
	match team_type:
		Team.ENEMY:
			var player:= Global.player
			var summons:= get_tree().get_nodes_in_group("summon_unit")
			units = [player]
			units.append_array(summons)
		Team.SUMMON:
			var enemys = get_tree().get_nodes_in_group("enemy")
			units.append_array(enemys)
	
	var weights:Array[float]
	for unit in units:
		weights.append(float(unit.stats.weight)+dist_weight_per_grid/(global_position-unit.global_position).length_squared())
	
	var rng := RandomNumberGenerator.new()
	var index:=rng.rand_weighted(weights)
	
	if index<0:
		return null
	
	var random_unit = units[index]
	target = random_unit
	return random_unit
	
func on_hurt(hurt_owner:Unit):
	var stay_value:float = stay_chance_ratio*target.stats.weight
	var change_value:float = 1-stay_chance_ratio
	change_value*=hurt_owner.stats.weight
	
	if randf_range(0,stay_value+change_value) > stay_value:
		target = hurt_owner


func _on_hurtbox_component_on_damaged(hitbox: HitboxComponent) -> void:
	var ownerr := hitbox.source
	if ownerr is Unit:
		on_hurt(ownerr)
