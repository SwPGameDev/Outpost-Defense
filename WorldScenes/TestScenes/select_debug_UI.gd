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

@export_group("Selected")
enum Selectables {worker, resource_node, resource_chunk, building, enemy}
@export var cur_select : Selectables
@export var selected_thing : Variant = null
var _worker : Worker

var cam : Camera3D

@export_group("Check Size")
@export var ray_length : float = 1000
@export var check_radius : float = 2

var check_pos : Vector3

func _ready() -> void:
	cam = get_viewport().get_camera_3d()
	
	HideUI(worker_info_ui)
	HideUI(building_info_ui)
	HideUI(resource_info_ui)

func _process(_delta: float) -> void:
	if selected_thing != null :
		if selected_thing is Worker :
			UpdateSelectWorkerUI()
		elif selected_thing is Building :
			UpdateBuildingUI(building_info_label, selected_thing)
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
		
		
		
		if selected_thing != null :
			print("SELECTED THING: " + str(selected_thing.name))
			
			HideUI(worker_info_ui)
			HideUI(building_info_ui)
			HideUI(resource_info_ui)
			
			print(selected_thing)
			match cur_select :
				Selectables.worker :
					_worker = selected_thing
					ShowUI(worker_info_ui)
					MoveWorkerSelectUI(worker_info_ui, _worker, ui_offset)
				Selectables.resource_node :
					ShowUI(resource_info_ui)
					MoveUI(resource_info_ui, selected_thing, ui_offset)
				Selectables.resource_chunk :
					ShowUI(resource_info_ui)
					MoveUI(resource_info_ui, selected_thing, ui_offset)
				Selectables.building :
					ShowUI(building_info_ui)
					MoveUI(building_info_ui, selected_thing, ui_offset)
		else :
			HideUI(worker_info_ui)
			HideUI(building_info_ui)
			HideUI(resource_info_ui)

func CheckResults(result : Dictionary) -> Variant :
	var thing : Variant = null
	if result.collider is Worker :
		cur_select = Selectables.worker
		thing = result.collider
	elif result.collider is ResourceNode :
		cur_select = Selectables.resource_node
		thing = result.collider
	elif result.collider is ResourceChunk :
		cur_select = Selectables.resource_chunk
		thing = result.collider
	elif result.collider is Building :
		cur_select = Selectables.building
		thing = result.collider
	elif result.collider is EnemyUnit :
		cur_select = Selectables.enemy
		thing = result.collider
	else :
		# couldn't find
		thing = null
	print("!!!THING!!!: " + str(thing))
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
	var job_string : String = str("\n") + "State: " + str(WorkerController.BehaviorState.keys()[_worker.worker_controller.current_state])
	var target_string : String = str("\n") + "Target: NULL"
	if _worker.target != null :
		target_string = str("\n") + "Target: " + str(_worker.target.name)
	#var request_string : String = str("\n") + "Request Source: NULL"
	#if _worker.resource_request != null :
		#request_string = str("\n") + "Request Source: " + str(_worker.resource_request.source_request.name)
	#var resource_prio_string : String = str("\n") + "Resource Priority: NULL"
	#if _worker.resource_priority != null :
		#resource_prio_string = str("\n") + "Resource Priority: " + str(ResourceManager.ResourceType.keys()[_worker.resource_priority])
	
	#worker_info_label.text = name_string + job_string + target_string + request_string + resource_prio_string
	worker_info_label.text = name_string + job_string + target_string

#Name: --
#Type: --
#Resource Request: --
#Missing : {-,-,-,-,-}
#Moving: {-,-,-,-,-}
#Delivered: {-,-,-,-,-}
func UpdateBuildingUI(label : Label, selected : Variant) :
	var name_string : String = "Name: " + str(selected.name)
	var building_type_string : String = ""
	
	###TODO finish this :)
	if selected is TownHall :
		building_type_string = "\n" + "Type: Townhall"
		
	elif selected is House :
		building_type_string = "\n" + "Type: House"
		
	elif selected is ResourceStorage :
		building_type_string = "\n" + "Type: Storage"
		
	elif selected is ArrowTower :
		building_type_string = "\n" + "Type: Arrow Tower"
		
	elif selected is Wall :
		building_type_string = "\n" + "Type: Wall"
	
	label.text = name_string + building_type_string

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

func MoveWorkerSelectUI(con : Control, worker : Worker, offset : Vector2) :
	print("CON: " + str(con) + " | Worker: " + str(worker) + " | Offset: " + str(offset))
	option_button.selected = worker.worker_controller.current_state
	option_button.get_popup().get_window().visible = false
	MoveUI(con, worker, offset)


### Unit UI



func ShowUI(con : Control) :
	con.visible = true

func HideUI(con : Control) :
	con.visible = false

func MoveUI(con : Control, target : Node3D, offset : Vector2) :
	con.visible = not get_viewport().get_camera_3d().is_position_behind(target.global_transform.origin)
	con.position = get_viewport().get_camera_3d().unproject_position(target.global_transform.origin)
	con.position += offset

func _on_option_button_item_selected(index: int) -> void  :
	if selected_thing is Worker :
		var worker : Worker = selected_thing 
		worker.SetWorkerState(index)
	#HideSelectUI(select_ui)















func _on_take_work_button_pressed() -> void:
	if selected_thing is Building :
		var building : Building = selected_thing
		building.TakeWork(1)


func _on_take_hit_button_pressed() -> void:
	if selected_thing is Building :
		var building : Building = selected_thing
		building.TakeHit(1)


func _on_take_repair_button_pressed() -> void:
	if selected_thing is Building :
		var building : Building = selected_thing
		building.TakeRepair(1)


func _on_finish_button_pressed() -> void:
	if selected_thing is Building :
		var building : Building = selected_thing
		building.CompleteBuilding()


func _on_destroy_button_pressed() -> void:
	if selected_thing is Building :
		var building : Building = selected_thing
		building.BuildingDie()
		selected_thing = null
		HideUI(building_info_ui)


# ._.
