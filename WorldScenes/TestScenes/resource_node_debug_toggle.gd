extends Button

var debug_on : bool

func _on_pressed() -> void:
	debug_on = !debug_on
	
	for resource_node : ResourceNode in get_tree().get_nodes_in_group("ResourceNodes") :
		resource_node.debug_enabled = debug_on
	for townhall : TownHall in get_tree().get_nodes_in_group("TownHall") :
		townhall.debug_enabled = debug_on
