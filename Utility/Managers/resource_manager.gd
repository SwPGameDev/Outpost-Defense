extends Node

enum ResourceType {Food, Gold, Wood, Stone, Iron, Crystal}

func GetClosestResourceNode(origin : Vector3, resource : ResourceType) -> ResourceNode :
	var shortest_distance : float = INF
	var closest_node : ResourceNode = null
	
	for group_node : ResourceNode in get_tree().get_nodes_in_group("ResourceNodes") :
		if group_node.node_resource == resource :
			var distance : float = origin.distance_to(group_node.global_position)
			if distance < shortest_distance :
				shortest_distance = distance
				closest_node = group_node
	return closest_node

func GetClosestResourceChunk(origin : Vector3, resource : ResourceType, filter_targeted : bool, filter_stored : bool, max_distance : float = INF) -> ResourceChunk : ## Filter out
	var shortest_distance : float = INF # replace with max_range var?
	var closest_chunk : ResourceChunk = null
	
	for group_chunk : ResourceChunk in get_tree().get_nodes_in_group("ResourceChunk") :
		if group_chunk.chunk_resource == resource :
			
			if group_chunk.for_delivery :
				print("DELIVERY FILTER OUT")
				continue
			if not group_chunk.chunk_resource == resource :
				continue
			else :
				if filter_targeted and group_chunk.targeted :
					continue
				if filter_stored and group_chunk.stored:
					continue
				var distance : float = origin.distance_to(group_chunk.global_position)
				if distance < max_distance and distance < shortest_distance:
						shortest_distance = distance
						closest_chunk = group_chunk
	return closest_chunk

func GetClosestResourceStorage(origin : Vector3) -> ResourceStorage :
	var shortest_distance : float = INF
	var closest_storage : ResourceStorage = null
	
	for group_storage in get_tree().get_nodes_in_group("ResourceStorage") :
		var distance : float = origin.distance_to(group_storage.global_position)
		if distance < shortest_distance :
			shortest_distance = distance
			closest_storage = group_storage
	return closest_storage
