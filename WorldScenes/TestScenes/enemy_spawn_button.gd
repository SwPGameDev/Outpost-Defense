extends Button

@export var enemy_spawner : Node3D

func _on_pressed() -> void:
	enemy_spawner.SpawnEnemyScene()
