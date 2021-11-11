extends Node
## Defines the color and density of crumbs when different foods are eaten.

## Defines the color and density of crumbs when a specific food is eaten.
class CrumbDefinition:
	## The number of crumbs which appear when the food is eaten. Cakes produce more crumbs than snacks.
	var max_crumb_count: int
	
	## Up to three colors of crumbs which appear when the food is eaten.
	var crumb_colors: Array
	
	func _init(init_max_crumb_count: int, init_crumb_colors: Array):
		max_crumb_count = init_max_crumb_count
		crumb_colors = init_crumb_colors

## key: an enum from Foods.FoodType defining the food being eaten
## value: CrumbDefinition defining the color and density of crumbs
var crumb_definitions := {
}

func _ready() -> void:
	# initialize crumb definitions
	for food_type in Foods.COLORS_BY_FOOD_TYPE:
		var max_crumb_count := 9 if Foods.is_cake_food(food_type) else 6
		var colors: Array = Foods.COLORS_BY_FOOD_TYPE[food_type]
		crumb_definitions[food_type] = CrumbDefinition.new(max_crumb_count, colors)


## Returns a crumb definition for the specified food type.
##
## Parameters:
## 	'food_type': An enum from Foods.FoodType defining the food being eaten
##
## Returns:
## 	A CrumbDefinition instance defining the color and density of crumbs when the specified food is eaten.
func get_definition(food_type: int) -> CrumbDefinition:
	return crumb_definitions[food_type]
