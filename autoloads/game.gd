extends Node
## 都主要是有明确指向性的命令

signal spawn_scene(scene:PackedScene,global_position:Vector2)

func spawn(scene:PackedScene,global_position:Vector2):
	spawn_scene.emit(scene,global_position)
