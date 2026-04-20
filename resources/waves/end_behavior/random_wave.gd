extends WaveEndBehavior
class_name RandomWave

@export var units: Array[WaveUnitData]
@export var enemy_count:int = 5

func get_enemy_list()->Array[PackedScene]:
	if units.is_empty():
		printerr("No Units.")
		return []
	
	var enemies: Array[PackedScene]
	var weights: Array[float]
	var list:Array[PackedScene] = []
	
	for unit in units:
		enemies.append(unit.unit_scene)
		weights.append(unit.weight)
		
	var rng := RandomNumberGenerator.new()
	for i in range(enemy_count):
		list.append(enemies[rng.rand_weighted(weights)])
	return list
