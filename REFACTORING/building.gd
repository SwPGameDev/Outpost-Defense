extends StaticBody3D
class_name Building

@export var resource_cost : ResourceCost

@export var needed_cost : ResourceCost = ResourceCost.new() ## What's still needed
@export var pending_cost : ResourceCost = ResourceCost.new() ## What's with a logi worker on the way
@export var delivered_cost : ResourceCost = ResourceCost.new() ## What's temp held at building

@export var max_hp : float
var current_hp : float
var held_delivery_chunks : Dictionary[ResourceChunk, ResourceManager.ResourceType] = {}

@export var total_work_needed : float = 5
var current_work : float = 0
var building_complete : bool = false

@export var foundation_collider : CollisionShape3D
@export var foundation_mesh : Node3D
@export var building_collider : CollisionShape3D
@export var building_mesh : Node3D

func _ready() -> void:
	current_hp = max_hp
	
	needed_cost = resource_cost.duplicate()

func ResetCosts() :
	needed_cost = ResourceCost.new()
	pending_cost = ResourceCost.new()
	delivered_cost = ResourceCost.new()

func UpdatePending(chunk : ResourceChunk) :
	needed_cost.UpdateResourceCost(chunk.chunk_resource, -1)
	pending_cost.UpdateResourceCost(chunk.chunk_resource, 1)
	


func TryTakeDelivery(chunk : ResourceChunk) :
	pending_cost.UpdateResourceCost(chunk.chunk_resource, -1)
	delivered_cost.UpdateResourceCost(chunk.chunk_resource, 1)
	
	held_delivery_chunks[chunk] = chunk.chunk_resource
	
	chunk.held = false
	chunk.stored = true
	chunk.for_delivery = true
	chunk.visible = false
	chunk.global_position = self.global_position
	chunk.reparent(self)
	chunk.process_mode = Node.PROCESS_MODE_DISABLED


func RequestRecieved() :
	print("RECIEVED")

func TakeWork(work_value : float) :
	current_work += work_value
	if current_work >= total_work_needed :
		building_complete = true
		CompleteBuilding()

func CompleteBuilding() :
	SwapToBuilt()
	print("Finished")

func TakeHit(damage_value : float) :
	current_hp -= damage_value
	
	# Incremental points that display damage?
	
	if current_hp <= 0 :
		BuildingDie()

func SwapToBuilt() :
	foundation_mesh.visible = false
	foundation_collider.set_deferred("disabled", true)
	
	building_mesh.visible = true
	building_collider.set_differed("disabled", false)

func BuildingDie() :
	pass
	# Need to figure out what needs to happen when a building dies
	# Just goes into damaged state? Do destroyed walls disapear completly? Leave behind ruins?




#
