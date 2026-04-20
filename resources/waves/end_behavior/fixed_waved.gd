extends WaveEndBehavior
class_name FixedWave
@export var scene_count_dict:Dictionary[PackedScene,int]


func get_enemy_list()->Array[PackedScene]:
	var list:Array[PackedScene] = []
	for scene in scene_count_dict:
		for i in scene_count_dict[scene]:
			list.append(scene)
	return list
