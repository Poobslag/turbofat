class_name StarSeed
extends Node2D
"""
Draws a shadowy star or seed inside a snack box or cake box.
"""

var food_type := 0 setget set_food_type

onready var _seed := $Seed
onready var _star := $Star

func _ready() -> void:
	_refresh_appearance()


func set_food_type(new_food_type: int) -> void:
	food_type = new_food_type
	_refresh_appearance()


"""
Updates the status and visibility of the child components.
"""
func _refresh_appearance() -> void:
	if not is_inside_tree():
		return
	
	var box_type: int = Foods.BOX_TYPE_BY_FOOD_TYPE[food_type]
	_seed.visible = Foods.is_snack_box(box_type)
	_star.visible = Foods.is_cake_box(box_type)
