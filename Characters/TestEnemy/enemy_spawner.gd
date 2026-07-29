extends Node3D

@export var enemy_basic_soldier_scene : PackedScene
@export var spawn_point : Node3D
@export var enable_debug : bool
@export var debug_target : Node3D


func SpawnEnemyScene(scene_to_spawn : PackedScene = enemy_basic_soldier_scene) :
	var new_enemy : Node3D = load(scene_to_spawn.resource_path).instantiate()
	add_child(new_enemy)
	new_enemy.global_position = spawn_point.global_position
	
	if enable_debug :
		new_enemy.debug_enabled = true
		new_enemy.debug_target = debug_target
		new_enemy.SetTarget(debug_target)
	
