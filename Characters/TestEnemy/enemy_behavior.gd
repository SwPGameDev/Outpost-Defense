extends RigidBody3D
class_name EnemyUnit

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_target : Node3D
@export_group("")

@export var movement : Node
@export var combat : Node

var check_dest_cd : float = 0.25
var check_dest_timer : float = 0

func _ready() -> void:
	if debug_enabled :
		target = debug_target

func _process(delta: float) -> void:
	if target != null :
	
		if check_dest_timer < check_dest_cd :
			check_dest_timer += delta
		else :
			check_dest_timer = 0
			if distance_to_target > stopping_dist :
				movement.SetDestination(GetDestFromTarget(target.global_position, stopping_dist))
