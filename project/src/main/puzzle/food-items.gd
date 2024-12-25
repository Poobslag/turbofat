extends Node2D
## Food items which appear when the player clears boxes in puzzle mode.

export (NodePath) var puzzle_path: NodePath
export (NodePath) var restaurant_view_path: NodePath
export (PackedScene) var FoodScene: PackedScene

## Array of floats corresponding to how fat the creature should become after eating each upcoming food item.
var _pending_food_fatness := []

## Increments as the customer changes to monitor the intended recipient of each food item.
var _customer_index := 0

## Queue of FoodItem objects which have floated awhile, and can now fly into a customer's mouth.
var _food_waiting_to_fly := []

## Minimum duration in seconds that food should float before flying into a customer's mouth.
var _food_float_duration := 1.0

## Duration in seconds that food should fly into a customer's mouth.
var _food_flight_duration := 1.0

## Maximum time in seconds between eaten food
var _max_food_repeat_delay := 1.0

## Caches the coordinate of the customer's mouth relative to the FoodItems viewport
var _target_pos_cache := {}

onready var _puzzle: Puzzle = get_node(puzzle_path)
onready var _puzzle_tile_map: PuzzleTileMap = _puzzle.get_playfield().tile_map

## relative position of the PuzzleTileMap, used for positioning food
onready var _puzzle_tile_map_position: Vector2 = _puzzle_tile_map.get_global_transform().origin \
		- get_global_transform().origin

onready var _restaurant_view: RestaurantView = get_node(restaurant_view_path)

## Food items are rendered in a Viewport and TextureRect so that they can use an outline shader.
onready var _viewport := $Viewport
onready var _texture_rect := $TextureRect

## Timer which causes food items to be repeatedly launched.
onready var _food_flight_timer := $FoodFlightTimer

## Timer which starts decrementing after a customer change.
onready var _customer_change_timer := $CustomerChangeTimer

func _ready() -> void:
	PuzzleState.connect("speed_index_changed", self, "_on_PuzzleState_speed_index_changed")


func _physics_process(_delta: float) -> void:
	if _target_pos_cache:
		# purge any cached target_pos values; creatures are constantly moving and bobbing their heads
		_target_pos_cache.clear()


## Adds a food item in the specified cell.
func add_food_item(cell: Vector2, food_type: int, remaining_food: int = 0) -> void:
	if not is_inside_tree():
		return
	# calculate and store 'food fatness' for customer; how fat the customer will be after eating each item
	var customer := _puzzle.get_customer()
	var old_fatness: float = _pending_food_fatness.back() if _pending_food_fatness else customer.fatness
	var base_score := customer.fatness_to_score(customer.base_fatness)
	var target_fatness := customer.score_to_fatness(base_score + PuzzleState.fatness_score)
	
	var fatness_pct: float = 1.0 / (remaining_food + 1)
	_pending_food_fatness.append(lerp(old_fatness, target_fatness, fatness_pct))
	
	var food_item: FoodItem = FoodScene.instance()
	food_item.collect()
	food_item.food_type = food_type
	food_item.position = Utils.map_to_world_centered(_puzzle_tile_map, cell)
	food_item.position *= _puzzle_tile_map.scale / _texture_rect.rect_scale
	food_item.position += _puzzle_tile_map_position / _texture_rect.rect_scale
	food_item.base_scale = 0.5 * _puzzle_tile_map.scale / _texture_rect.rect_scale
	food_item.customer = _puzzle.get_customer()
	food_item.customer_index = _customer_index
	food_item.connect("ready_to_fly", self, "_on_FoodItem_ready_to_fly", [food_item])
	_viewport.add_child(food_item)
	
	# float for a moment
	# we use a one-shot listener method instead of a yield statement to avoid 'class instance is gone' errors.
	if is_inside_tree():
		get_tree().create_timer(_food_float_duration).connect("timeout", self, "_on_FoodItem_float_done", [food_item])


## Callback function which returns the coordinate of the customer's mouth relative to the FoodItems viewport.
##
## Returns Vector2.INF if the customer is replaced, and food should no longer fly towards their mouth.
##
## This is an expensive calculation which is needed once per frame per food item, so we employ a cache.
func get_target_pos(target_customer: Creature, target_customer_index: int) -> Vector2:
	if not _target_pos_cache.has(target_customer):
		var target_pos: Vector2 = _restaurant_view.get_customer_mouth_position(target_customer)
		
		if target_customer == _puzzle.get_customer() and target_customer_index != _customer_index:
			# if the target customer leaves and a new customer replaces them, we return 'Vector2.INF' to notify
			# callers that the food should not fly to them anymore.
			target_pos = Vector2.INF
		else:
			# if the target customer goes offscreen the food targets a point on the
			# screen's edge, not a point far outside the boundaries of the screen.
			if target_customer != _puzzle.get_customer():
				if target_customer.position.x < _puzzle.get_customer().position.x:
					target_pos.x = lerp(0, target_pos.x,
							_customer_change_timer.time_left / _customer_change_timer.wait_time)
				else:
					target_pos.x = lerp(Global.window_size.x, target_pos.x,
							_customer_change_timer.time_left / _customer_change_timer.wait_time)
			
			# calculate the position within the global viewport
			target_pos = get_global_transform_with_canvas().xform_inv(target_pos)
			# calculate the position within the FoodItems viewport texture
			target_pos = target_pos / _texture_rect.rect_scale
		
		_target_pos_cache[target_customer] = target_pos
	
	return _target_pos_cache[target_customer]


## Recalculates the food speed fields based on the speed of the current level.
##
## Faster levels cause the foods to fly around faster.
func _update_food_speed() -> void:
	# calculate the 'speed factor': a number from 0.0 to 1.0 corresponding to
	# how quickly the player can drop pieces
	var min_frames_per_line := Ranks.min_frames_per_line(PieceSpeeds.current_speed)
	var speed_factor := clamp(inverse_lerp(40, 120, min_frames_per_line), 0.0, 1.0)
	
	# update the food timings based on the speed factor
	_food_float_duration = lerp(0.2, 1.3, speed_factor)
	_food_flight_duration = lerp(0.4, 1.0, speed_factor)
	_max_food_repeat_delay = lerp(0.16, 0.48, speed_factor)
	
	# update the food timings based on the current level's food speed setting
	var flight_speed_factor := 1.0 / clamp(CurrentLevel.settings.other.food_speed, 0.1, 100)
	var float_speed_factor := 1.0 / clamp(CurrentLevel.settings.other.food_speed, 0.1, 100)
	if float_speed_factor < 1.0:
		# for food_speed values greater than 1.0, the food does not float
		float_speed_factor = 0.0
	_food_float_duration = clamp(_food_float_duration * float_speed_factor, 0.01, 2.6)
	_food_flight_duration = clamp(_food_flight_duration * flight_speed_factor, 0.01, 2.0)
	_max_food_repeat_delay *= clamp(_max_food_repeat_delay * float_speed_factor, 0.01, 0.96)
	
	_food_flight_timer.wait_time = _max_food_repeat_delay * randf()


func _on_FoodItem_float_done(food_item: FoodItem) -> void:
	_food_waiting_to_fly.append(food_item)


func _on_FoodItem_ready_to_fly(food_item: FoodItem) -> void:
	if not is_inside_tree():
		return
	food_item.fly_to_target(funcref(self, "get_target_pos"), \
			[food_item.customer, food_item.customer_index], _food_flight_duration)
	
	# trigger the eating animation just before we arrive at the creature's mouth
	var adjusted_flight_duration := _food_flight_duration - food_item.customer.get_eating_delay()
	if is_inside_tree():
		get_tree().create_timer(adjusted_flight_duration).connect("timeout", self, "_on_FoodItem_flight_done", [food_item])


func _on_FoodItem_flight_done(food_item: FoodItem) -> void:
	if not food_item:
		# food items might be garbage collected before this function is called
		return
	
	if _customer_index == food_item.customer_index:
		# ensure the customer hasn't been replaced before fattening them
		_puzzle.feed_customer(food_item.customer, food_item.food_type)
		
		var new_fatness: float = _pending_food_fatness.pop_front()
		food_item.customer.fatness = new_fatness


func _on_StarSeeds_food_spawned(cell: Vector2, remaining_food: int, food_type: int) -> void:
	add_food_item(cell, food_type, remaining_food)


func _on_Playfield_food_spawned(cell: Vector2, remaining_food: int, food_type: int) -> void:
	add_food_item(cell, food_type, remaining_food)


## When the FoodFlightTimer times out, we check the queue for the next food item which should fly into the customer's
## mouth.
func _on_FoodFlightTimer_timeout() -> void:
	if not _food_waiting_to_fly:
		return
	
	_food_flight_timer.start(_max_food_repeat_delay * randf())
	var food_item: FoodItem = _food_waiting_to_fly.pop_front()
	food_item.emit_signal("ready_to_fly")


## We monitor when the customer changes to ensure food goes to the proper place, and that it doesn't get eaten by the
## wrong customer.
func _on_RestaurantView_customer_changed() -> void:
	_customer_change_timer.start()
	# increment the customer index; wrap it to avoid an overflow error
	_customer_index = (_customer_index + 1) % 1000000000
	_pending_food_fatness.clear()


func _on_PuzzleState_speed_index_changed(_value: int) -> void:
	_update_food_speed()
