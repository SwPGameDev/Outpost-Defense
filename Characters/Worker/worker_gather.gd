@icon("res://addons/at-icons/node/pickaxe.svg")
extends Node
class_name WorkerGather

@export var worker : Worker

@export var work_cooldown : float = 1
var work_timer : float = 0
@export var work_amount : float = 1
var can_do_work : bool = false

@export var work_range : float = 2
var work_in_range : bool = false

func ProcessTick(_delta: float) -> void:
	# TEMP ### At some point need to prioritize resource type instead of random
	if worker.target == null :
		worker.target = ResourceManager.GetClosestResourceNode(
			worker.global_position,
			ResourceManager.ResourceType.values()[randi_range(0, ResourceManager.ResourceType.size() - 1)])
		
	else :
		var distance : float = worker.global_position.distance_to(worker.target.global_position)
		if distance <= work_range :
			work_in_range = true
		else :
			work_in_range = false
		
		
		
		if work_in_range :
			if work_timer < work_cooldown :
				work_timer += _delta
			else :
				work_timer = 0
				can_do_work = true
			
			if can_do_work :
				worker.target.TakeWork(work_amount)
				can_do_work = false
