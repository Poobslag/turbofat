extends Node2D
"""
Food items which appear when the player clears boxes in puzzle mode.
"""

export (NodePath) var puzzle_path: NodePath
export (NodePath) var restaurant_view_path: NodePath
export (PackedScene) var FoodScene: PackedScene

# Array of floats corresponding to how fat the creature should become after eating each upcoming food item.
var _pending_food_fatness := []

# Increments as the customer changes to track the intended recipient of each food item.
var _customer_index := 0

# Queue of FoodItem objects which have floated awhile, and can now fly into a customer's mouth.
var _food_waiting_to_fly := []

var _window_width: float = ProjectSettings.get_setting("display/window/size/width")

# Minimum duration in seconds that food should float before flying into a customer's mouth.
var _food_float_duration := 1.0

# Duration in seconds that food should fly into a customer's mouth.
var _food_flight_duration := 1.0

# Maximum time in seconds between eaten food
var _max_food_repeat_delay := 1.0

onready var _puzzle: Puzzle = get_node(puzzle_path)
onready var _puzzle_tile_map: PuzzleTileMap = _puzzle.get_playfield().tile_map

# relative position of the PuzzleTileMap, used for positioning food
onready var _puzzle_tile_map_position: Vector2 = _puzzle_tile_map.get_global_transform().origin \
		- get_global_transform().origin

onready var _restaurant_view: RestaurantView = get_node(restaurant_view_path)

# Food items are rendered in a Viewport and TextureRect so that they can use an outline shader.
onready var _viewport := $Viewport
onready var _texture_rect := $TextureRect

# Timer which causes food items to be repeatedly launched.
onready var _food_flight_timer := $FoodFlightTimer

# Timer which starts decrementing after a customer change.
onready var _customer_change_timer := $CustomerChangeTimer

func _ready() -> void:
	PuzzleScore.connect("speed_index_changed", self, "_on_PuzzleScore_speed_index_changed")


"""
Adds a food item in the specified cell.
"""
func add_food_item(cell: Vector2, food_type: int) -> void:
	if cell.y < PuzzleTileMap.FIRST_VISIBLE_ROW:
		return
	
	var food_item: FoodItem = FoodScene.instance()
	food_item.frame = food_type
	food_item.position = _puzzle_tile_map.map_to_world(cell)
	food_item.position += _puzzle_tile_map.cell_size * Vector2(0.5, 0.5)
	food_item.position *= _puzzle_tile_map.scale / _texture_rect.rect_scale
	food_item.position += _puzzle_tile_map_position / _texture_rect.rect_scale
	food_item.base_scale = _puzzle_tile_map.scale / _texture_rect.rect_scale
	_viewport.add_child(food_item)
	
	var customer := _puzzle.get_customer()
	var original_customer_index := _customer_index
	
	# float for a moment
	yield(get_tree().create_timer(_food_float_duration), "timeout")
	_food_waiting_to_fly.append(food_item)
	
	# wait for our turn to fly to the creature's mouth
	yield(food_item, "ready_to_fly")
	food_item.fly_to_target(self, "get_target_pos", [customer], _food_flight_duration)
	
	# wait until we arrive at the creature's mouth
	yield(get_tree().create_timer(_food_flight_duration - customer.get_eating_delay()), "timeout")
	
	if _customer_index == original_customer_index:
		# ensure the customer hasn't been replaced before fattening them
		_puzzle.feed_creature(customer, food_type)
		
		if customer.creature_id == CreatureLibrary.SENSEI_ID:
			# tutorial sensei doesn't gain weight
			pass
		else:
			var new_fatness: float = _pending_food_fatness.pop_front()
			customer.set_fatness(new_fatness)


"""
Callback function which returns the coordinate of the customer's mouth relative to the FoodItems viewport.
"""
func get_target_pos(customer: Creature) -> Vector2:
	var target_pos: Vector2 = _restaurant_view.get_customer_mouth_position(customer)
	
	# if the target customer goes offscreen the food targets a point on the screen's edge, not a point far outside the
	# boundaries of the screen.
	if customer != _puzzle.get_customer():
		if customer.position.x < _puzzle.get_customer().position.x:
			target_pos.x = lerp(0, target_pos.x,
					_customer_change_timer.time_left / _customer_change_timer.wait_time)
		else:
			target_pos.x = lerp(_window_width, target_pos.x,
					_customer_change_timer.time_left / _customer_change_timer.wait_time)
	
	# calculate the position within the global viewport
	target_pos = get_global_transform_with_canvas().xform_inv(target_pos)
	# calculate the position within the FoodItems viewport texture
	target_pos = target_pos / _texture_rect.rect_scale
	
	return target_pos


"""
Recalculates the food speed fields based on the speed of the current level.

Faster levels cause the foods to fly around faster.
"""
func _update_food_speed() -> void:
	# calculate the 'speed factor': a number from 0.0 to 1.0 corresponding to
	# how quickly the player can drop pieces
	var min_frames_per_line := RankCalculator.min_frames_per_line(PieceSpeeds.current_speed)
	var speed_factor := clamp(inverse_lerp(40, 120, min_frames_per_line), 0.0, 1.0)
	
	# update the food timings based on the speed factor
	_food_float_duration = lerp(0.2, 1.3, speed_factor)
	_food_flight_duration = lerp(0.4, 1.0, speed_factor)
	_max_food_repeat_delay = lerp(0.16, 0.48, speed_factor)
	_food_flight_timer.wait_time = _max_food_repeat_delay * randf()


"""
When new food spawns, we create a food item and calculate how fat it should make the customer.
"""
func _on_StarSeeds_food_spawned(cell: Vector2, remaining_food: int, food_type: int) -> void:
	# calculate and store 'food fatness' for customer; how fat the customer will be after eating each item
	var customer := _puzzle.get_customer()
	var old_fatness: float = _pending_food_fatness.back() if _pending_food_fatness else customer.get_fatness()
	var base_score := customer.fatness_to_score(customer.base_fatness)
	var target_fatness := customer.score_to_fatness(base_score + PuzzleScore.get_bonus_score())
	
	var fatness_pct: float = 1.0 / (remaining_food + 1)
	_pending_food_fatness.append(lerp(old_fatness, target_fatness, fatness_pct))
	
	add_food_item(cell, food_type)


"""
When the FoodFlightTimer times out, we check the queue for the next food item which should fly into the customer's
mouth.
"""
func _on_FoodFlightTimer_timeout() -> void:
	if not _food_waiting_to_fly:
		return
	
	_food_flight_timer.start(_max_food_repeat_delay * randf())
	var food_item: FoodItem = _food_waiting_to_fly.pop_front()
	food_item.emit_signal("ready_to_fly")


"""
We track when the customer changes to ensure food goes to the proper place, and that it doesn't get eaten by the wrong
customer.
"""
func _on_RestaurantView_customer_changed() -> void:
	_customer_change_timer.start()
	# increment the customer index; wrap it to avoid an overflow error
	_customer_index = (_customer_index + 1) % 1000000000
	_pending_food_fatness.clear()


func _on_PuzzleScore_speed_index_changed(_value: int) -> void:
	_update_food_speed()
