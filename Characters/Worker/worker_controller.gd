@icon("res://addons/at-icons/node/brain.svg")
extends Node
class_name WorkerController

enum BehaviorState {Idle, Gather, Logistics, Build, Repair, Combat}
var current_state : BehaviorState = BehaviorState.Idle

@export var worker : Worker
@export var idle : WorkerIdle
@export var gather : WorkerGather
@export var logistics : WorkerLogistics
@export var build : WorkerBuild
@export var repair : WorkerRepair
@export var combat : WorkerCombat

func _process(delta: float) -> void:
	match current_state :
		BehaviorState.Idle :
			idle.ProcessTick(delta)
			
		BehaviorState.Gather :
			gather.ProcessTick(delta)
			
		BehaviorState.Logistics :
			logistics.ProcessTick(delta)
			
		BehaviorState.Build :
			build.ProcessTick(delta)
			
		BehaviorState.Repair :
			repair.ProcessTick(delta)
			
		BehaviorState.Combat :
			combat.ProcessTick(delta)





# Enter state
## Try to find target

# Exit state
## Clear target
