extends StaticBody3D
class_name ResourceNode

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_label : Label3D
@export_group("")

@export var node_resource : ResourceManager.ResourceType
@export var chunk_to_spawn : PackedScene
@export var spawn_offset : Vector3 = Vector3(0, 2, 0)

@export var chunks_left : int
@export var workers_assigned : int = 0

@export var work_needed_per_chunk : float = 3
var current_work_done : float = 0


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_pressed("jump") :
		SpawnChunk()
	
	if debug_enabled :
		if not debug_label.is_visible_in_tree() :
			debug_label.visible = true
		
		var info_string : String = \
		str(ResourceManager.ResourceType.keys()[node_resource]) + \
		str("\n") + \
		str(current_work_done) + "/" + str(work_needed_per_chunk)
		debug_label.text = info_string
	else :
		if debug_label.is_visible_in_tree() :
			debug_label.visible = false

func SpawnChunk() :
	var new_chunk : ResourceChunk = load(chunk_to_spawn.resource_path).instantiate()
	add_child(new_chunk)
	new_chunk.global_position += spawn_offset
	new_chunk.reparent(get_parent())
	
	#chunks_left -= 1

func DepleteNode() :
	# need to decide if nodes are finite
	pass

func TakeWork(work_amount : float) :
	current_work_done += work_amount
	if current_work_done >= work_needed_per_chunk :
		current_work_done = 0
		SpawnChunk()






















# weh
