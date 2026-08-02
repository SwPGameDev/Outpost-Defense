@icon("res://addons/at-icons/node/pouch.svg")
extends Node
class_name WorkerLogistics

@export var worker : Worker

func ProcessTick(_delta: float) -> void:
	if held_chunk == null :
		# If request exists, look for the closest chunk
		
		if outstanding_requests :
			target = ResourceManager.GetClosestResourceChunk(
				global_position,
				ResourceManager.ResourceType.values()[randi_range(0, ResourceManager.ResourceType.size() - 1)], #resource_to_find
				true,
				false)
			if target == null : ## Can't find chunks of type, need to grab something else
				pass
		else :
			target = ResourceManager.GetClosestResourceChunk(
				global_position,
				ResourceManager.ResourceType.values()[randi_range(0, ResourceManager.ResourceType.size() - 1)],
				true,
				true)
		
		if target != null :
			target.targeted = true
			find_new_target = false
		else :
			find_new_target = true
	else :
		# We are holding a chunk and need to decide where it goes
		if RequestManager.existing_requests.size() > 0 :
			var request : RequestManager.Resource_Request = RequestManager.GetClosestRequest(global_position, held_chunk.chunk_resource)
			if request != null :
				resource_request = request
				target = request.source_request
				RequestManager.UpdateMissingDict(request, held_chunk.chunk_resource, -1)
				RequestManager.UpdateMovingDict(request, held_chunk.chunk_resource, 1)
			else :
				resource_request = null
				target = ResourceManager.GetClosestResourceStorage(self.global_position)
		else :
			target = ResourceManager.GetClosestResourceStorage(self.global_position)





	if in_range and held_chunk == null :
		PickupChunk(target)
	elif in_range and resource_request != null and held_chunk != null :
		if target is Building :
			DeliverChunk(target, held_chunk, resource_request)
	elif in_range and held_chunk != null :
		if target is ResourceStorage :
			target.StoreChunk(held_chunk, held_chunk.chunk_resource)
			held_chunk = null
			target = null
			in_range = false
			find_new_target = true






### Finds closest request with something in missing
#func GetClosestRequest(origin : Vector3, select_resource : bool, max_range : float = INF, resource_type : ResourceManager.ResourceType = ResourceManager.ResourceType.Food) -> Resource_Request :
	#var shortest_distance : float = INF
	#var closest_request: Resource_Request = null
	#for i in existing_requests.size() :
		#var distance : float = origin.distance_to(existing_requests[i].source_request.global_position)
		#if distance > max_range :
			#continue
		#for resource_key : int in existing_requests[i].missing_resources.cost.keys() :
			#if existing_requests[i].missing_resources.cost[resource_key] <= 0 :
				#continue
			#if select_resource and not resource_type :
				#continue
			#if distance < shortest_distance :
				#shortest_distance = distance
				#closest_request = existing_requests[i]
				##print("Request source: " + str(closest_request.source_request.name) + " | Distance to request: " + str(distance))
	#if closest_request == null :
		#print("No matching request found")
		#pass
	#return closest_request
#
#
##### SOMETHING BROKEN HERE, returns something funny......
#
### Finds first resource type thats missing for a request 
#func GetClosestMissingResourceType(origin : Vector3, max_range : float = INF) -> ResourceManager.ResourceType :
	#var closest_request : RequestManager.Resource_Request = GetClosestRequest(origin, false, max_range)
	#var resource_to_find : ResourceManager.ResourceType
	#for resource_key : int in closest_request.missing_resources.cost.keys():
		#if closest_request.missing_resources.cost[resource_key] <= 0 :
			#continue
		#else :
			#resource_to_find = ResourceManager.ResourceType.values()[resource_key]
			#break
	#return resource_to_find





	# Do we need to check for an existing resource request?
	# Lets do it here for now, but not every frame
	#if RequestManager.existing_requests.size() > 0 :
		# 1. Figure out what resources are needed
		# 2. Check to see if we have a chunk stored in any of our buildings
		# 3. Look in increasingly larger ranges for an untargeted chunk we need
		# 4 FAIL. If we can't find keep looping? Complain that we don't have the resource
			# 4.5 FAIL??? Move on to next request??
		# 4 SUCCESS. Send worker to grab and deliver to building/construction site
		# 5. Update what we have to pending
		# 6. Move on to next needed in current request
		# 7. Update delivered when delivered
		# 8. When everything is delivered mark as fulfilled
		# 9. Build workers should start building
	# Wow this is complicated
	
	# Maybe just have worker with logi job proiritize delivering to requests
