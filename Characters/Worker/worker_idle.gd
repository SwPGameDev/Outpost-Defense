@icon("res://addons/at-icons/node/eye_closed.svg")
extends Node
class_name WorkerIdle


@export var worker : Worker


var find_new_target : bool = false

@export var idle_wait_max : float = 3
@export var idle_wait_min : float = 0.5
var idle_wait_cooldown : float
var idle_wait_timer : float
@export var idle_wander_distance_max : float = 3
@export var idle_wander_distance_min : float = -3
var wander_distance : float
var idle_waiting : bool = false
var idle_wandering : bool = false


func ProcessTick(_delta: float) -> void:
	if find_new_target :
		find_new_target = false
		idle_wait_cooldown = randf_range(idle_wait_min, idle_wait_max)
		idle_wait_timer = 0
		wander_distance = randf_range(idle_wander_distance_min, idle_wander_distance_max)
		
		idle_waiting = true
		idle_wandering = false
		
		var rand_dir : Vector3 = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		var random_pos : Vector3 = worker.global_position + (rand_dir * wander_distance)
		worker.SetDestination(worker.GetDestFromTarget(random_pos, 0))
	
	
	
	if idle_waiting :
		idle_wait_timer += _delta
		if idle_wait_timer > idle_wait_cooldown :
			idle_wait_timer = 0
			idle_waiting = false
			idle_wandering = true
	elif idle_wandering :
		if worker.nav_agent.is_navigation_finished() :
			idle_wandering = false
			find_new_target = true
