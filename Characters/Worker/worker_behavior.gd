extends RigidBody3D
class_name Worker

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_target : Node3D

@export_group("Nav")
@export var move_speed : float = 4
@export var nav_agent : NavigationAgent3D
@export var target : Node3D
var distance_to_target : float
@export var stopping_dist : float = 1
@export var worker_range : float = 1.5
var in_range : bool
var find_new_target : bool = false

var check_dest_cd : float = 0.25
var check_dest_timer : float = 0


@export_group("Chunk")
@export var hold_pos : Node3D
var held_chunk : ResourceChunk
@export var root_level_node : Node3D



@export_group("Work Work")
@export var work_cooldown : float = 1
var work_timer : float = 0
@export var work_amount : float = 1
var can_do_work : bool = false


func _ready() -> void:
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	

### TODO self righting forces
# NOTE to self disable axis lock
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#pass

func _process(delta: float) -> void:
	if debug_enabled : # Change to if target != null
		#target = debug_target
		if target != null :
			DebugDraw.draw_line_relative_pointy(target.global_position, global_position - target.global_position, 1, Color.BLUE_VIOLET)
			# Destination
			DebugDraw.draw_line_relative_thick(nav_agent.target_position,Vector3.UP,5,Color.LIGHT_GREEN)
	
	# Find a target now that a new job has been set
	if find_new_target :
		find_new_target = false
		match current_job :

			
			JobType.Gather :
				# ask what resources are needed
				#resource_priority = ResourceManager.GetResourcePriority() ## Array? start top prio to last bottom prio?
				# TEMP ### At some point need to prioritize resource type instead of random
				target = ResourceManager.GetClosestResourceNode(self.global_position, ResourceManager.ResourceType.values()[randi_range(0, ResourceManager.ResourceType.size() - 1)])
			
			JobType.Repair :
				# Find closest (or maybe lowest hp?) damaged building
				pass
	
	### Do this while we have a target
	if target != null :
		distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target > worker_range :
			in_range = false
		else :
			in_range = true
		
		if check_dest_timer < check_dest_cd :
			check_dest_timer += delta
		else :
			check_dest_timer = 0
			if distance_to_target > stopping_dist :
				SetDestination(GetDestFromTarget(target.global_position, stopping_dist))
		
		match current_job :
			JobType.Idle :
				# We shouldn't have a target if we're idle...
				push_error("We are Idle but have a target... | " + str(self.name))
				print_debug("")
				pass
			
			JobType.Gather :
				if in_range :
					if work_timer < work_cooldown :
						work_timer += delta
					else :
						work_timer = 0
						can_do_work = true
				if can_do_work :
					target.TakeWork(work_amount)
					can_do_work = false
			
			# Build and repair together? Prioritize repair
			JobType.Repair :
				#TODO
				pass
	else :
		in_range = false
		

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

func _on_velocity_computed(safe_velocity : Vector3) :
	linear_velocity = safe_velocity

func TakeHit(_damage : float) :
	combat.TryTakeHit(_damage)

func GetDestFromTarget(target_pos : Vector3, stopping_distance : float) -> Vector3 :
	var current_pos = global_position
	current_pos.y = 0
	target_pos.y = 0 # NEED TO CHANGE IF ADDING VERTICALITY
	var dir : Vector3 = current_pos - target_pos
	var dest = target_pos + (dir.normalized() * stopping_distance)
	return dest

func SetDestination(new_destination : Vector3) :
	nav_agent.target_position = new_destination

func SetJob(job : JobType) :
	if target != null and target is ResourceChunk :
		target.targeted = false
	if held_chunk != null :
		DropChunk(held_chunk)
	in_range = false
	target = null
	current_job = job
	
	find_new_target = true

func PickupChunk(chunk : ResourceChunk) :
	target = null
	in_range = false
	chunk.held = true
	chunk.worker_holding = self
	chunk.global_position = hold_pos.global_position
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	chunk.reparent(hold_pos)
	held_chunk = chunk
	
	find_new_target = true

func DropChunk(chunk : ResourceChunk) :
	target = null
	in_range = false
	chunk.held = false
	chunk.worker_holding = null
	chunk.process_mode = Node.PROCESS_MODE_INHERIT
	chunk.targeted = false
	chunk.reparent(root_level_node)
	held_chunk = null
	
	find_new_target = true

func DeliverChunk(building : Building, chunk : ResourceChunk) :
	building.TryTakeDelivery(held_chunk)
	
	target = null
	in_range = false
	chunk.worker_holding = null
	held_chunk = null
	
	find_new_target = true
