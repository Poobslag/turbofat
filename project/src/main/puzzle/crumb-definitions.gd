extends Node
"""
Defines the color and density of crumbs when different foods are eaten.
"""

"""
Defines the color and density of crumbs when a specific food is eaten.
"""
class CrumbDefinition:
	# The number of crumbs which appear when the food is eaten. Cakes produce more crumbs than snacks.
	var max_crumb_count: int
	
	# Up to three colors of crumbs which appear when the food is eaten.
	var crumb_colors: Array
	
	func _init(init_max_crumb_count: int, init_crumb_colors: Array):
		max_crumb_count = init_max_crumb_count
		crumb_colors = init_crumb_colors

# key: an enum from FoodItem.FoodType defining the food being eaten
# value: CrumbDefinition defining the color and density of crumbs
var crumb_definitions := {
	FoodItem.FoodType.BROWN_0: CrumbDefinition.new(6, [FoodColors.BROWN]),
	FoodItem.FoodType.BROWN_1: CrumbDefinition.new(6, [FoodColors.BROWN]),
	FoodItem.FoodType.PINK_0: CrumbDefinition.new(6, [FoodColors.PINK]),
	FoodItem.FoodType.PINK_1: CrumbDefinition.new(6, [FoodColors.PINK]),
	FoodItem.FoodType.BREAD_0: CrumbDefinition.new(6, [FoodColors.BREAD]),
	FoodItem.FoodType.BREAD_1: CrumbDefinition.new(6, [FoodColors.BREAD]),
	FoodItem.FoodType.WHITE_0: CrumbDefinition.new(6, [FoodColors.WHITE]),
	FoodItem.FoodType.WHITE_1: CrumbDefinition.new(6, [FoodColors.WHITE]),
	
	FoodItem.FoodType.CAKE_JJO: CrumbDefinition.new(9, [FoodColors.PINK, FoodColors.PINK, FoodColors.WHITE]),
	FoodItem.FoodType.CAKE_JLO: CrumbDefinition.new(9, [FoodColors.PINK, FoodColors.BROWN, FoodColors.WHITE]),
	FoodItem.FoodType.CAKE_JTT: CrumbDefinition.new(9, [FoodColors.PINK, FoodColors.BREAD, FoodColors.BREAD]),
	FoodItem.FoodType.CAKE_LLO: CrumbDefinition.new(9, [FoodColors.BROWN, FoodColors.BROWN, FoodColors.WHITE]),
	FoodItem.FoodType.CAKE_LTT: CrumbDefinition.new(9, [FoodColors.BROWN, FoodColors.BREAD, FoodColors.BREAD]),
	FoodItem.FoodType.CAKE_PQV: CrumbDefinition.new(9, [FoodColors.PINK, FoodColors.BROWN, FoodColors.WHITE]),
	FoodItem.FoodType.CAKE_PUV: CrumbDefinition.new(9, [FoodColors.PINK, FoodColors.BREAD, FoodColors.WHITE]),
	FoodItem.FoodType.CAKE_QUV: CrumbDefinition.new(9, [FoodColors.BROWN, FoodColors.BREAD, FoodColors.WHITE]),
}

"""
Returns a crumb definition for the specified food type.

Parameters:
	'food_type': An enum from FoodItem.FoodType defining the food being eaten

Returns:
	A CrumbDefinition instance defining the color and density of crumbs when the specified food is eaten.
"""
func get_definition(food_type: int) -> CrumbDefinition:
	return crumb_definitions[food_type]
