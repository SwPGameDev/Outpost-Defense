extends RigidBody3D
class_name EnemyUnit

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_target : Node3D

var check_dest_cd : float = 0.25
var check_dest_timer : float = 0

@export_group("Combat")
@export var combat : Node

@export_group("Movement")
@export var movement : Node
@export var target : Node3D
var distance_to_target : float
@export var stopping_distance : float = 1

func _ready() -> void:
	if debug_enabled :
		target = debug_target

func _process(delta: float) -> void:
	if target != null :
		distance_to_target = global_position.distance_to(target.global_position)
		
		if check_dest_timer < check_dest_cd :
			check_dest_timer += delta
		else :
			check_dest_timer = 0
			if distance_to_target > stopping_distance :
				movement.SetDestination(movement.GetDestFromTarget(target.global_position, stopping_distance))
	else :
		distance_to_target = 0







#
