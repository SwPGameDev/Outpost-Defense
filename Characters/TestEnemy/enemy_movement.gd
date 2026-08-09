extends Node

@export var enemy : EnemyUnit

func _physics_process(_delta: float) -> void:
	
	if NavigationServer3D.map_get_iteration_id(enemy.nav_agent.get_navigation_map()) == 0 :
		return
	if enemy.nav_agent.is_navigation_finished() :
		return
	
	var next_path_pos : Vector3 = enemy.nav_agent.get_next_path_position()
	
	var no_y_dir : Vector3 = enemy.global_position.direction_to(next_path_pos)
	no_y_dir.y = 0
	
	var new_velocity : Vector3 = no_y_dir.normalized() * enemy.move_speed
	if enemy.nav_agent.avoidance_enabled :
		enemy.nav_agent.velocity = new_velocity
	else :
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity : Vector3) :
	enemy.linear_velocity = safe_velocity


func SetDestination(new_destination : Vector3) :
	enemy.nav_agent.target_position = new_destination


func GetDestFromTarget(target_pos : Vector3, stopping_distance : float) -> Vector3 :
	var current_pos = enemy.global_position
	current_pos.y = 0
	target_pos.y = 0 # NEED TO CHANGE IF ADDING VERTICALITY
	var dir : Vector3 = current_pos - target_pos
	var dest = target_pos + (dir.normalized() * stopping_distance)
	return dest
