class_name Pickup
extends Node2D
## Pickup which spawns a food item when collected by the player.

## duration in seconds between star color changes
const STAR_COLOR_CHANGE_DURATION := 0.8

var food_type := 0: set = set_food_type

## 'true' if the food item should be shown, 'false' if the star or seed should be shown
var food_shown: bool = false: set = set_food_shown

## array of Colors the star should cycle between
var _star_colors: Array = []
var _star_color_index := 0

@onready var _seed := $Seed
@onready var _star := $Star
@onready var _food_item := $FoodItem

## tween used to update the star's color
@onready var _star_color_tween: Tween

func _ready() -> void:
	_seed.visible = true
	_star.visible = false
	_food_item.visible = false
	_refresh_appearance()


func set_food_shown(new_food_shown: bool) -> void:
	food_shown = new_food_shown
	_refresh_appearance()


func set_food_type(new_food_type: int) -> void:
	food_type = new_food_type
	_refresh_appearance()


## Returns 'true' if this pickup will spawn a cake when collected.
func is_cake() -> bool:
	var box_type: int = Foods.BOX_TYPE_BY_FOOD_TYPE[food_type]
	return Foods.is_cake_box(box_type)


## Updates the status and visibility of the child components.
func _refresh_appearance() -> void:
	if not (is_inside_tree() and _food_item):
		return
	
	var box_type: int = Foods.BOX_TYPE_BY_FOOD_TYPE[food_type]
	
	# refresh seed appearance
	_seed.visible = not food_shown and Foods.is_snack_box(box_type)
	if _seed.visible:
		_seed.modulate = Foods.COLORS_ALL[box_type]
	
	# refresh star appearance
	_star.visible = not food_shown and Foods.is_cake_box(box_type)
	if _star.visible:
		_star_colors = Foods.COLORS_BY_FOOD_TYPE.get(food_type, []).duplicate()
		_star_colors.shuffle()
		
		_star_color_index = 0
		_star.modulate = _star_colors[_star_color_index]
		_launch_star_color_tween(true)
	
	# refresh food item appearance
	if food_shown and not _food_item.visible:
		_food_item.jiggle()
	_food_item.visible = food_shown
	if _food_item.visible:
		_food_item.food_type = food_type


## Gradually changes the star to a new color.
func _launch_star_color_tween(initial_launch := false) -> void:
	var new_star_color_index := (_star_color_index + 1) % _star_colors.size()
	
	_star_color_tween = Utils.recreate_tween(self, _star_color_tween).set_trans(Tween.TRANS_SINE)
	# for the initial launch, the duration has more variance so that different stars will start out of sync
	var duration_min := STAR_COLOR_CHANGE_DURATION * (0.0 if initial_launch else 0.8)
	var duration_max := STAR_COLOR_CHANGE_DURATION * 1.2
	_star_color_tween.tween_property(_star, "modulate", \
			_star_colors[new_star_color_index], randf_range(duration_min, duration_max))
	_star_color_tween.tween_callback(Callable(self, "_launch_star_color_tween"))
	_star_color_index = new_star_color_index
