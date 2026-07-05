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
var worker_cost : RequestManager.Resource_Cost = RequestManager.CreateResourceCost(5, 5, 0, 0, 0, 0)
#@export var worker_cost : RequestManager.Resource_Cost ### TODO make ResourceCost a Resource

var request_active : bool = false

@export_group("Spawning")
@export var spawn_point : Node3D
@export var level_root : Node3D
@export var worker_parent : Node3D

@export_group("Storage")
@export var stored_chunks : Array[ResourceChunk]
@export var max_chunk_capacity : int = 20
var current_storage : int = 0

func _ready() -> void:
	TryRequestWorkerResources()

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
			WorkerManager.SpawnWorker(spawn_point.global_position, worker_parent, level_root)

func TryRequestWorkerResources() :
	RequestManager.CreateRequest(self, worker_cost)

func TryTrainWorker() :
	if not currently_training :
		currently_training = true

func RequestRecieved():
	super()
	TryTrainWorker()
