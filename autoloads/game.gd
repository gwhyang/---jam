extends Node
## 都主要是有明确指向性的命令

signal spawn_scene(scene:PackedScene,global_position:Vector2)
signal summon_scene(scene:PackedScene,global_position:Vector2)
signal add_node(node:Node2D,global_position:Vector2)
signal game_win
signal game_lose

signal show_item_tooltip(item_card:ItemCard)
signal hide_item_tooltip(item_card:ItemCard)

func spawn(scene:PackedScene,global_position:Vector2):
	spawn_scene.emit(scene,global_position)

func summon(scene:PackedScene,global_position:Vector2):
	summon_scene.emit(scene,global_position)

func add(node:Node2D,global_position:Vector2):
	add_node.emit(node,global_position)

func show_tooltip(item_card:ItemCard):
	print(111)
	show_item_tooltip.emit(item_card)
func hide_tooltip(item_card:ItemCard):
	hide_item_tooltip.emit(item_card)
