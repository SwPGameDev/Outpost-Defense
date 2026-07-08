extends MenuButton

func _ready() -> void:
	get_popup().connect("id_pressed", OnPressed)

func OnPressed(id : int) :
	for worker : Worker in get_tree().get_nodes_in_group("Worker") :
		worker.SetJob(Worker.JobType.values()[id])
