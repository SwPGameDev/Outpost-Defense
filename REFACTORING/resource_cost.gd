extends Resource
class_name ResourceCost

@export var food_cost : int
@export var gold_cost : int
@export var wood_cost : int
@export var stone_cost : int
@export var iron_cost : int
@export var crystal_cost : int

var dict : Dictionary[ResourceManager.ResourceType, int] :
	get : 
		var blarg : Dictionary[ResourceManager.ResourceType, int] = {
			ResourceManager.ResourceType.Food : food_cost,
			ResourceManager.ResourceType.Gold : gold_cost,
			ResourceManager.ResourceType.Wood : wood_cost,
			ResourceManager.ResourceType.Stone : stone_cost,
			ResourceManager.ResourceType.Iron : iron_cost,
			ResourceManager.ResourceType.Crystal : crystal_cost
			}
		return blarg

func _init(p_food_cost : int = 0, p_gold_cost : int = 0, p_wood_cost : int = 0, p_stone_cost : int = 0, p_iron_cost : int = 0, p_crystal_cost : int = 0) :
	food_cost = p_food_cost
	gold_cost = p_gold_cost
	wood_cost = p_wood_cost
	stone_cost = p_stone_cost
	iron_cost = p_iron_cost
	crystal_cost = p_crystal_cost


func UpdateResourceCost(resource_selection : ResourceManager.ResourceType, amount : int) : ## type_cost += amount
	match resource_selection :
		ResourceManager.ResourceType.Food :
			food_cost += amount
		ResourceManager.ResourceType.Gold :
			gold_cost += amount
		ResourceManager.ResourceType.Wood :
			wood_cost += amount
		ResourceManager.ResourceType.Stone :
			stone_cost += amount
		ResourceManager.ResourceType.Iron :
			iron_cost += amount
		ResourceManager.ResourceType.Crystal :
			crystal_cost += amount
