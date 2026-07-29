extends Resource
class_name ResourceCost

@export var gold_cost : int
@export var wood_cost : int
@export var stone_cost : int
@export var iron_cost : int
@export var crystal_cost : int


func _init(p_gold_cost : int = 0, p_wood_cost : int = 0, p_stone_cost : int = 0, p_iron_cost : int = 0, p_crystal_cost : int = 0) :
	gold_cost = p_gold_cost
	wood_cost = p_wood_cost
	stone_cost = p_stone_cost
	iron_cost = p_iron_cost
	crystal_cost = p_crystal_cost
