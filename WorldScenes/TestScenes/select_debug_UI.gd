@icon("res://addons/phantom_camera/icons/viewfinder/Select.svg")
extends Node3D

enum SelectionStates {Disabled, Listening, Selected}
var current_state : SelectionStates

@export_group("Debug Visuals")
@export var debug_enabled : bool = false
@export var spherecast_indicator : CSGSphere3D

@export_group("References")
@export var ui_offset : Vector2 = Vector2(50,-50)

@export var worker_info_ui : Control
@export var worker_info_label : Label
@export var option_button : OptionButton

@export var building_info_ui : Control
@export var building_info_label : Label

@export var resource_info_ui : Control
@export var resource_info_label : Label

@export var ground : Node3D

enum Selectables {worker, resourcenode, resourcechunk, building} ## worker, resourcenode, resourcechunk, building
var cur_select : Selectables
var selected_thing : Variant = null
var _worker : Worker

var cam : Camera3D

@export_group("Check Size")
@export var ray_length : float = 1000
@export var check_radius : float = 2

var check_pos : Vector3

func _ready() -> void:
	cam = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	if selected_thing != null :
		if selected_thing is Worker :
			UpdateSelectWorkerUI()
		elif selected_thing is Building :
			pass
		elif selected_thing is ResourceNode or selected_thing is ResourceChunk :
			UpdateResourceUI(resource_info_label, selected_thing)
		
	else :
		pass
	
	
	if debug_enabled :
		if spherecast_indicator.visible == false :
			spherecast_indicator.visible = true
		
		var vect1 : Vector3 = Vector3(cam.position.x, cam.position.y - 1, cam.position.z)
		var vect2 : Vector3 = Vector3(check_pos.x, check_pos.y - cam.position.y + 1, check_pos.z)
		DebugDraw.draw_line_relative_pointy(vect1, vect2, 1, Color.SKY_BLUE)
		
		DebugDraw.draw_line_relative_thick(check_pos, Vector3.UP, 2, Color.CYAN)
		
		if spherecast_indicator.radius != check_radius :
			spherecast_indicator.radius = check_radius
		spherecast_indicator.position = check_pos
	else :
		if spherecast_indicator.visible :
			spherecast_indicator.visible = false


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("right_click") :
		var ray_results : Dictionary = Utility.MouseViewPortRayCast()
		var sphere_results : Array[Dictionary]
		
		
		
		if ray_results.size() > 0 :
			check_pos = ray_results.position
			
			selected_thing = CheckResults(ray_results)
			if selected_thing == null :
				sphere_results = Utility.TrySphereCast(check_pos, check_radius, 50)
				if sphere_results.size() > 0 :
					selected_thing = GetClosestColObj(sphere_results, check_pos)
				
		
		if selected_thing is Worker :
			_worker = selected_thing
		else :
			_worker = null
		
		if selected_thing != null :
			print("SELECTED THING: " + str(selected_thing.name))
		
		if _worker != null :
			MoveSelectUI(option_button, worker_info_ui, _worker, ui_offset)
		else :
			pass
			#HideSelectUI(worker_info_ui)


func CheckResults(result : Dictionary) -> Variant :
	var thing : Variant = null
	if result.collider is Worker :
		cur_select = Selectables.worker
		thing = result.collider
	elif result.collider is ResourceNode :
		cur_select = Selectables.resourcenode
		thing = result.collider
	elif result.collider is ResourceChunk :
		cur_select = Selectables.resourcechunk
		thing = result.collider
	elif result.collider is Building :
		cur_select = Selectables.building
		thing = result.collider
	else :
		# couldn't find
		thing = null
	return thing


func GetClosestColObj(results_array : Array[Dictionary], pos : Vector3) -> Node3D :
	var shortest_distance : float = INF
	var closest : Variant = null
	
	for res in results_array :
		print(res.collider.name)
		if res.collider != ground :
			var distance : float = pos.distance_to(res.collider.global_position)
			if  distance < shortest_distance :
				shortest_distance = distance
				closest = CheckResults(res)
				
	return closest


func UpdateSelectWorkerUI() :
	var name_string : String = "Name: " + str(_worker.name)
	var job_string : String = str("\n") + "Job: " + str(WorkerManager.JobType.keys()[_worker.current_job])
	var target_string : String = str("\n") + "Target: NULL"
	if _worker.target != null :
		target_string = str("\n") + "Target: " + str(_worker.target.name)
	var request_string : String = str("\n") + "Request Source: NULL"
	if _worker.resource_request != null :
		request_string = str("\n") + "Request Source: " + str(_worker.resource_request.source_request.name)
	var resource_prio_string : String = str("\n") + "Resource Priority: NULL"
	if _worker.resource_priority != null :
		resource_prio_string = str("\n") + "Resource Priority: " + str(ResourceManager.ResourceType.keys()[_worker.resource_priority])
	
	worker_info_label.text = name_string + job_string + target_string + request_string + resource_prio_string


#Name: --
#Building Type: --
#Resource Request: --
#Missing : {-,-,-,-,-}
#Moving: {-,-,-,-,-}
#Delivered: {-,-,-,-,-}
func UpdateBuildingUI(label : Label, selected : Variant) :
	var name_string : String = "Name: " + str(selected.name)
	
	if selected is TownHall :
		pass
	elif selected_thing is ResourceStorage :
		pass
	
	pass


func UpdateResourceUI(label : Label, selected : Variant) :
	var name_string : String = "Name: " + str(selected.name)
	var resource_type_string : String
	
	var target_string : String
	var held_string : String
	var stored_string : String
	var for_delivery_string : String
	
	var work_needed_string : String
	
	if selected is ResourceChunk :
		resource_type_string = "\n" + "Resource Type: "  + str(ResourceManager.ResourceType.keys()[selected.chunk_resource])
		held_string = "\n" + "Held: " + str(selected.held)
		stored_string = "\n" + "Stored: " + str(selected.stored)
		for_delivery_string = "\n" + "For Delivery: " + str(selected.for_delivery)
		
		label.text = name_string + resource_type_string + target_string + held_string + stored_string + for_delivery_string
	elif selected is ResourceNode :
		resource_type_string = "\n" + "Resource Type: "  + str(ResourceManager.ResourceType.keys()[selected.node_resource])
		work_needed_string = "\n" + "Chunk Work: " + String.num(selected.current_work_done, 2) + " / " + String.num(selected.work_needed_per_chunk, 2)
		
		label.text = name_string + resource_type_string + work_needed_string

func MoveSelectUI(opt_button : OptionButton, sel_ui : Control, worker : Worker, offset : Vector2) :
	opt_button.selected = worker.current_job
	option_button.get_popup().get_window().visible = false
	sel_ui.visible = not get_viewport().get_camera_3d().is_position_behind(worker.global_transform.origin)
	sel_ui.position = get_viewport().get_camera_3d().unproject_position(worker.global_transform.origin)
	sel_ui.position += offset

func ShowSelectUI(sel_ui : Control) :
	sel_ui.visible = true

func HideSelectUI(sel_ui : Control) :
	sel_ui.visible = false
	selected_thing = null

func _on_option_button_item_selected(index: int) -> void  :
	if selected_thing is Worker :
		WorkerManager.AssignWorker(selected_thing, index)
	#HideSelectUI(select_ui)












# ._.
