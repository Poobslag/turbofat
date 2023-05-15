class_name NightPickup
extends Node2D
## Pickup which spawns a food item when collected by the player during night mode.
##
## This code is identical to the daytime pickup, but without the logic for cycling between different colors. Onion
## pickups are always light blue.

var food_type := 0: set = set_food_type

## 'true' if the food item should be shown, 'false' if the star or seed should be shown
var food_shown: bool = false: set = set_food_shown

## array of Colors the star should cycle between
var _star_colors: Array = []
var _star_color_index := 0

@onready var _seed := $Seed
@onready var _star := $Star
@onready var _food_item := $FoodItem

func _ready() -> void:
	_seed.visible = true
	_star.visible = false
	_food_item.visible = false
	_refresh_appearance()


func set_food_shown(new_food_shown: bool) -> void:
	if food_shown == new_food_shown:
		return
	
	food_shown = new_food_shown
	_refresh_appearance()


func set_food_type(new_food_type: int) -> void:
	if food_type == new_food_type:
		return
	
	food_type = new_food_type
	_refresh_appearance()


## Updates the status and visibility of the child components.
func _refresh_appearance() -> void:
	if not is_inside_tree():
		return
	
	var box_type: int = Foods.BOX_TYPE_BY_FOOD_TYPE[food_type]
	
	# refresh seed appearance
	_seed.visible = not food_shown and Foods.is_snack_box(box_type)
	
	# refresh star appearance
	_star.visible = not food_shown and Foods.is_cake_box(box_type)
	
	# refresh food item appearance
	if food_shown and not _food_item.visible:
		_food_item.jiggle()
	_food_item.visible = food_shown
	if _food_item.visible:
		_food_item.food_type = food_type
