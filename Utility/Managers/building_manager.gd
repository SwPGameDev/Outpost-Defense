extends Node

@export var debug_indicators : bool = true
var building_parent : Node3D

var in_build_mode : bool = false
var mouse_pos : Vector3
var build_pos : Vector3

@export_flags_3d_physics var ground_only_collision_mask

var build_node : Node3D
var rotation_amount : float = 90

var building_indicator_1x1 : PackedScene = preload("res://Buildings/TestBuildingIndicators/1x1Indicator.tscn")
var build_indicator : Node3D = null

var town_hall_scene : PackedScene = preload("res://Buildings/town_hall.tscn")
var resource_storage_scene : PackedScene = preload("res://Buildings/resource_storage.tscn")
var house_scene : PackedScene = preload("res://Buildings/house.tscn")
var wall_1x1_scene : PackedScene = preload("res://Buildings/wall_1x_1.tscn")
var wall_2x1_scene : PackedScene = preload("res://Buildings/wall_2x_1.tscn")
var arrow_tower_scene : PackedScene = preload("res://Buildings/arrow_tower.tscn")

var selector_index : int = 0
var building_scenes : Array[PackedScene] = [
	town_hall_scene,
	resource_storage_scene,
	house_scene,
	wall_1x1_scene,
	wall_2x1_scene,
	arrow_tower_scene
	]

var selected_building : PackedScene

var grid_size : float = 1


enum BuildingType {House, Farm, Townhall, Storage, Tower}

var BuildingDict : Dictionary[Building, BuildingType] = {}
var BuildingRequests : Dictionary[Building, ResourceCost]

func _ready() -> void:
	
	selector_index = 0
	selected_building = building_scenes[selector_index]
	
	build_node = Node3D.new()
	add_child(build_node)
	build_node.name = "Build Node"
	
	var test_indicator = building_indicator_1x1.instantiate()
	add_child(test_indicator)
	build_indicator = test_indicator
	build_indicator.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("build_mode") :
		in_build_mode = !in_build_mode
		build_indicator.visible = !build_indicator.visible
	
	if in_build_mode :
		if debug_indicators :
			DebugDraw.draw_line_relative_thick(mouse_pos, Vector3.UP, 2, Color.ORANGE)
			DebugDraw.draw_line_relative_thick(build_pos, Vector3.UP, 2, Color.GHOST_WHITE)
		
		if Input.is_action_just_pressed("build_sel_next") :
			selector_index += 1
			if selector_index >= building_scenes.size() :
				selector_index = 0
			selected_building = building_scenes[selector_index]
			
		if Input.is_action_just_pressed("build_sel_prev") :
			selector_index -= 1
			if selector_index < 0 :
				selector_index = building_scenes.size() - 1
			selected_building = building_scenes[selector_index]
		
		if Input.is_action_just_pressed("build_rot_left") :
			build_node.rotate_object_local(Vector3.UP, deg_to_rad(rotation_amount))
			build_indicator.rotation = build_node.rotation
		if Input.is_action_just_pressed("build_rot_right") :
			build_node.rotate_object_local(Vector3.UP, -deg_to_rad(rotation_amount))
			build_indicator.rotation = build_node.rotation
		
		var mouse_ray_results : Dictionary = Utility.MouseViewPortRayCast(1000, ground_only_collision_mask)
		if not mouse_ray_results.is_empty() :
			mouse_pos = mouse_ray_results.position
			
			build_pos = Vector3(
				RoundToNearestGrid(mouse_pos.x, grid_size),
				RoundToNearestGrid(mouse_pos.y, grid_size),
				RoundToNearestGrid(mouse_pos.z, grid_size)
			)
			
			build_indicator.global_position = build_pos
		
		if Input.is_action_just_pressed("left_click") :
			TryPlaceFoundation(selected_building, build_pos)
			

func TryPlaceFoundation(building_scene : PackedScene, position : Vector3) :
	var new_building : Building = load(building_scene.resource_path).instantiate()
	add_child(new_building)
	new_building.global_position = position
	new_building.rotation = build_node.rotation
	new_building.reparent(building_parent)

func TrackBuildingRequest(building : Building, cost : ResourceCost) :
	BuildingRequests[building] = cost

func TrackBuilding(building : Building, building_type : BuildingType) :
	BuildingDict[building] = building_type


func RoundToNearestGrid(pos : float, _grid_size : float) -> float :
	var xDiff : float = fmod(pos, _grid_size)
	var isPositive : bool = pos > 0
	pos -= xDiff
	if (abs(xDiff) > (_grid_size / 2)) :
		if isPositive :
			pos += _grid_size
		else :
			pos -= _grid_size
	return pos
