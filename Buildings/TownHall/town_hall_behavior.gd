extends Building
class_name TownHall

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_label_parent : Node3D
@export var debug_training_progress_label : Label3D

@export_group("Worker")
@export var worker_train_time : float = 2
var train_timer : float = 0
var currently_training : bool = false
@export var worker_cost : ResourceCost
var worker_scene : PackedScene = preload("res://Characters/Worker/worker.tscn")

var request_active : bool = false

@export_group("Spawning")
@export var spawn_point : Node3D
#@export var worker_parent : Node3D

@export_group("Storage")
@export var stored_chunks : Array[ResourceChunk]
@export var max_chunk_capacity : int = 20
var current_storage : int = 0

func _process(delta: float) -> void:
	if debug_enabled :
		if not debug_label_parent.is_visible_in_tree() :
			debug_label_parent.visible = true
		var info_string : String = \
		"Train Prog: " + \
		String.num(train_timer, 2) + "/" + \
		String.num(worker_train_time, 2)
		
		debug_training_progress_label.text = info_string
	else :
		if debug_label_parent.is_visible_in_tree() :
			debug_label_parent.visible = false
	
	if currently_training :
		train_timer += delta
		if train_timer > worker_train_time :
			train_timer = 0
			currently_training = false

func TryTrainWorker() :
	if not currently_training :
		currently_training = true

func SpawnWorker(pos : Vector3) :
	var new_worker : Worker = worker_scene.instantiate()
	add_child(new_worker)
	new_worker.name = "Worker" + str(get_tree().get_node_count_in_group("Worker"))
	new_worker.global_position = pos
	new_worker.reparent(get_tree().root)

func RequestRecieved():
	super()
	TryTrainWorker()
