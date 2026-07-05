extends Building
class_name ResourceStorage

var held_chunks : Dictionary[ResourceChunk, ResourceManager.ResourceType]

func StoreChunk(chunk : ResourceChunk, chunk_type : ResourceManager.ResourceType) :
	held_chunks[chunk] = chunk_type
	chunk.held = false
	chunk.stored = true
	chunk.visible = false
	chunk.global_position = self.global_position
	chunk.reparent(self)
	chunk.process_mode = Node.PROCESS_MODE_DISABLED

func TakeChunk(chunk : ResourceChunk, _chunk_type : ResourceManager.ResourceType, Requester : Worker) :
	held_chunks.erase(chunk)
	chunk.held = true
	chunk.stored = false
	chunk.visible = true
	chunk.global_position = Requester.hold_pos.global_position
	chunk.reparent(Requester.hold_pos)
	chunk.process_mode = Node.PROCESS_MODE_INHERIT
	
