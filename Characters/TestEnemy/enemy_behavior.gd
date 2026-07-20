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
@export var destination : Vector3
var distance_to_target : float
@export var stopping_distance : float = 1

@export_group("Targeting")
@export var target_range : float = 50
var target : Node3D
@export_flags_3d_physics var targeting_col_mask
@export var ground : CollisionObject3D

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
		#FindTarget()



func FindTarget() -> Node3D :
	var new_target : Node3D = null
	var sphere_results : Array[Dictionary] = Utility.TrySphereCast(self.global_position, 50, 200, targeting_col_mask)
	
	
	if sphere_results.size() > 0 :
		new_target = GetClosestColObj(sphere_results, self.global_position)
	
	return new_target


func GetClosestColObj(results_array : Array[Dictionary], pos : Vector3) -> Node3D :
	var shortest_distance : float = INF
	var closest : Variant = null
	
	for res in results_array :
		print(res.collider.name)
		if res.collider != ground :
			var distance : float = pos.distance_to(res.collider.global_position)
			if  distance < shortest_distance :
				shortest_distance = distance
				closest = CheckResults(res)
				
	return closest


func CheckResults(result : Dictionary) -> Variant :
	var thing : Variant = null
	if result.collider is Worker :
		thing = result.collider
	elif result.collider is Building :
		thing = result.collider
	#elif result.collider is Soldier
	else :
		# couldn't find
		thing = null
	print("!!!THING!!!: " + str(thing))
	return thing


func SetTarget(new_target : Node3D) :
	target = new_target


#
