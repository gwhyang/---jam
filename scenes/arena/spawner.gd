extends Node2D
class_name Spawner

signal on_wave_completed

@export var spawn_area_size := Vector2(1000, 500)
@export var summon_range:= Vector2(200, 200)
@export var waves_data: Array[WaveData]
@export var enemy_collection: Array[UnitStats]

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer


var wave_index := 1
var current_wave_data: WaveData
var spawned_enemies: Array[Enemy] = []
var spawned_summons: Array[Summon] = []


func find_wave_data() -> WaveData:
	for wave in waves_data:
		if wave and wave.is_valid_index(wave_index):
			return wave
	return null

func start_wave() -> void:
	current_wave_data = find_wave_data()
	if not current_wave_data:
		printerr("No valid wave.")
		spawn_timer.stop()
		wave_timer.stop()
		return
	
	wave_timer.wait_time = current_wave_data.wave_time
	wave_timer.start()
	
	set_spawn_timer()

func set_spawn_timer() -> void:
	match current_wave_data.spawn_type:
		WaveData.SpawnType.FIXED:
			spawn_timer.wait_time = current_wave_data.fixed_spawn_time
		WaveData.SpawnType.RANDOM:
			var min_t := current_wave_data.min_spawn_time
			var max_t := current_wave_data.max_spawn_time
			spawn_timer.wait_time = randf_range(min_t, max_t)
			
	if spawn_timer.is_stopped():
		spawn_timer.start()
		

func get_random_spawn_position() -> Vector2:
	var random_x := randf_range(-spawn_area_size.x, spawn_area_size.x)
	var random_y := randf_range(-spawn_area_size.y, spawn_area_size.y)
	return Vector2(random_x, random_y)

## 生成敌人的，如果要生成己方的应该跟着这个学着写出来
func spawn_enemy() -> void:
	var enemy_scene := current_wave_data.get_random_unit_scene() as PackedScene
	if enemy_scene:
		var spawn_pos := get_random_spawn_position()
		
		#生成动画逻辑
		#var spawn_anim := Global.SPAWN_EFFECT_SCENE.instantiate()
		#get_parent().add_child(spawn_anim)
		#spawn_anim.global_position = spawn_pos
		#await spawn_anim.anim_player.animation_finished
		#spawn_anim.queue_free()
		#
		#var enemy_instance := enemy_scene.instantiate() as Enemy
		#enemy_instance.global_position = spawn_pos
		#get_parent().add_child(enemy_instance)
		#spawned_enemies.append(enemy_instance)
		
		var spawn_anim := spawn(Global.SPAWN_EFFECT_SCENE,spawn_pos)
		if not spawn_anim:
			push_error(0000)
			return
		await spawn_anim.anim_player.animation_finished
		spawn_anim.queue_free()
		
		var enemy_instance := spawn(enemy_scene,spawn_pos) as Enemy
		spawned_enemies.append(enemy_instance)
	
	set_spawn_timer()

func spawn_summon(summon_scene:PackedScene)->void:
	var summon_posi := get_random_summon_position()
	var summon_anim := spawn(Global.SUMMON_EFFECT_SCENE,summon_posi)
	if not summon_anim:
		push_error(0000)
		return
	await summon_anim.anim_player.animation_finished
	summon_anim.queue_free()
		
	var summon_instance := spawn(summon_scene,summon_posi) as Summon
	spawned_summons.append(summon_instance)

func get_random_summon_position() -> Vector2:
	if not Global.player:
		push_error('Try summon when player not initialized.')
		return Vector2.INF
	var range:Array[float] = [0,0,0,0]
	var player_posi = Global.player.global_position
	range[0] = maxf(-spawn_area_size.x,player_posi.x-summon_range.x)
	range[1] = minf(spawn_area_size.x,player_posi.x+summon_range.x)
	range[2] = maxf(-spawn_area_size.y,player_posi.y-summon_range.y)
	range[3] = minf(spawn_area_size.y,player_posi.y+summon_range.y)
	return Vector2(randf_range(range[0],range[1]),randf_range(range[2],range[3]))
	
	
func update_enemies_new_wave() -> void:
	for stat: UnitStats in enemy_collection:
		stat.health += stat.health_increase_per_wave
		stat.damage += stat.damage_increase_per_wave

func clear_enemies() -> void:
	if spawned_enemies.size() > 0:
		for enemy: Enemy in spawned_enemies:
			if is_instance_valid(enemy):
				enemy.destroy_enemy()
	
	spawned_enemies.clear()


func get_wave_text() -> String:
	return "Wave %s" % wave_index


func get_wave_timer_text() -> String:
	return str(max(0, int(wave_timer.time_left)))

## 返回null代表生成失败
func spawn(spawned:PackedScene,global_posi:Vector2 = Vector2(0,0))->Node2D:
	if not spawned:
		return null
	var spawned_instance := spawned.instantiate()
	if not spawned_instance is Node2D:
		return null
		
	spawned_instance =spawned_instance as Node2D
	spawned_instance.global_position = global_posi
	get_parent().add_child(spawned_instance)
	return spawned_instance

func _on_spawn_timer_timeout() -> void:
	if not current_wave_data or wave_timer.is_stopped():
		spawn_timer.stop()
		return
	
	spawn_enemy()


func _on_wave_timer_timeout() -> void:
	Global.game_paused = true
	Global.get_harvesting_coins()
	on_wave_completed.emit()
	spawn_timer.stop()
	clear_enemies()
	update_enemies_new_wave()
