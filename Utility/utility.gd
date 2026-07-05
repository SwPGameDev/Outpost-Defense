extends Node3D

var physics_space : PhysicsDirectSpaceState3D # Needs to be updated when things are moved

func MouseViewPortRayCast(ray_length : float = 1000, collision_mask : int = 4294967295) -> Dictionary :
	physics_space = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = get_viewport().get_camera_3d().project_ray_origin(mousepos)
	var end = origin + get_viewport().get_camera_3d().project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, collision_mask)
	query.collide_with_areas = false
	
	var result = physics_space.intersect_ray(query)
	
	return result

func TrySphereCast(pos : Vector3, radius : float, max_results : int, collision_mask : int = 4294967295) -> Array[Dictionary] :
	physics_space = get_world_3d().direct_space_state
	var shape_rid = PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid, radius)
	
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape_rid = shape_rid
	params.transform.origin = pos
	params.collision_mask = collision_mask
	
	var result = physics_space.intersect_shape(params, max_results)
	
	PhysicsServer3D.free_rid(shape_rid)
	
	return result
