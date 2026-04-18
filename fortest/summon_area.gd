extends "res://fortest/test.gd"

@export var test_scene :PackedScene=preload("res://scenes/skill_effects/summon_area.tscn")

func test_logic():
	Game.spawn(test_scene,Global.player.global_position)
