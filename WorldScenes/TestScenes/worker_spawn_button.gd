extends Button

@export var spawn_pos : Node3D
@export var spawn_offset : Vector3
@export var worker_parent : Node3D

func _on_pressed() -> void:
	var _town_hall : TownHall = get_tree().get_first_node_in_group("TownHall")
	if _town_hall != null :
		_town_hall.SpawnWorker(spawn_pos.global_position + spawn_offset)
