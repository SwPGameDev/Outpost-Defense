extends RigidBody3D
class_name EnemyUnit

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_target : Node3D

var check_dest_cd : float = 0.25
var check_dest_timer : float = 0

@export_group("Refernces")
@export var nav_agent : NavigationAgent3D


@export_group("Combat")
@export var combat : Node


@export_group("Movement")
@export var movement : Node
@export var destination : Vector3
var distance_to_target : float
@export var stopping_distance : float = 1
@export var move_speed : float = 4
@export var mesh : Node3D
@export var look_target : Vector3
@export var rotation_speed : float = TAU


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
		#TryFindTarget()
	
	
	TryLook(delta)



func TryFindTarget() -> Node3D :
	var new_target : Node3D = null
	var sphere_results : Array[Dictionary] = Utility.TrySphereCast(self.global_position, target_range, 200, targeting_col_mask)
	
	
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

func TryLook(_delta : float) :
	look_target = nav_agent.get_next_path_position() - global_position
	look_target.y = global_position.y
	if target != null :
		
		if look_target != Vector3.ZERO :
			var rotation_target : Quaternion = Basis.looking_at(look_target, Vector3.UP, true).orthonormalized()
			# Only y axis rotation go here
			var new_rotation : Quaternion = mesh.basis.orthonormalized().slerp(rotation_target, _delta * rotation_speed)
			
			mesh.basis = new_rotation
		
	elif target == null and destination != Vector3.ZERO :
		if look_target != Vector3.ZERO :
			var rotation_target : Quaternion = Basis.looking_at(look_target, Vector3.UP, true).orthonormalized()
			# Only y axis rotation go here
			var new_rotation : Quaternion = mesh.basis.orthonormalized().slerp(rotation_target, _delta * rotation_speed)
			
			mesh.basis = new_rotation


func SetTarget(new_target : Node3D) :
	target = new_target


#
