extends RigidBody3D
class_name Worker

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_target : Node3D

@export_group("References")
@export var worker_controller : WorkerController

@export_group("Nav")
@export var move_speed : float = 4
@export var nav_agent : NavigationAgent3D

@export_group("Rotation")
@export var mesh : Node3D
@export var look_target : Vector3
@export var rotation_speed : float = TAU

@export_group("Targeting")
@export var target : Node3D
@export var destination : Vector3
var distance_to_target : float
@export var stopping_dist : float = 1

var check_dest_cd : float = 0.25
var check_dest_timer : float = 0

var find_new_target : bool = false


func _ready() -> void:
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	

### TODO self righting forces
# NOTE to self disable axis lock
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#pass



func _process(delta: float) -> void:
	if debug_enabled :
		if target != null :
			DebugDraw.draw_line_relative_pointy(target.global_position, global_position - target.global_position, 1, Color.BLUE_VIOLET)
			# Destination
			DebugDraw.draw_line_relative_thick(nav_agent.target_position,Vector3.UP,5,Color.LIGHT_GREEN)
	
	if target != null :
		if check_dest_timer < check_dest_cd :
			check_dest_timer += delta
		else :
			check_dest_timer = 0
			
			distance_to_target = global_position.distance_to(target.global_position)
			
			if distance_to_target > stopping_dist :
				SetDestination(GetDestFromTarget(target.global_position, stopping_dist))
		
	
	TryLook(delta)

### Movement and self righting
func _physics_process(_delta: float) -> void:
	if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0 :
		return
	if nav_agent.is_navigation_finished() :
		return
	
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	
	var no_y_dir : Vector3 = global_position.direction_to(next_path_pos)
	no_y_dir.y = 0
	
	var new_velocity : Vector3 = no_y_dir.normalized() * move_speed
	if nav_agent.avoidance_enabled :
		nav_agent.velocity = new_velocity
	else :
		_on_velocity_computed(new_velocity)


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



func _on_velocity_computed(safe_velocity : Vector3) :
	linear_velocity = safe_velocity

func TakeHit(_damage : float) :
	worker_controller.combat.TryTakeHit(_damage)

func GetDestFromTarget(target_pos : Vector3, stopping_distance : float) -> Vector3 :
	var current_pos = global_position
	current_pos.y = 0
	target_pos.y = 0 # NEED TO CHANGE IF ADDING VERTICALITY
	var dir : Vector3 = current_pos - target_pos
	var dest = target_pos + (dir.normalized() * stopping_distance)
	return dest

func SetDestination(new_destination : Vector3) :
	destination = new_destination
	nav_agent.target_position = new_destination

func SetWorkerState(state : WorkerController.BehaviorState) :
	target = null
	destination = Vector3.ZERO
	
	worker_controller.current_state = state
	find_new_target = true
