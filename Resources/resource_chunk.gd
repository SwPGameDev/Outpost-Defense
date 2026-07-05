extends RigidBody3D
class_name ResourceChunk

@export var chunk_resource : ResourceManager.ResourceType
@export var chunk_value : float

var held : bool = false
var stored : bool = false
var targeted : bool = false
var part_of_a_request : bool = false
var for_delivery : bool = false
