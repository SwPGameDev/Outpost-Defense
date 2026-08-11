extends Area3D

@export var mesh : MeshInstance3D
@export var build_mat : StandardMaterial3D
@export var build_fail_mat : StandardMaterial3D
@export var build_success_mat : StandardMaterial3D


func CheckCollision() -> Array[Node3D] :
	return get_overlapping_bodies()
