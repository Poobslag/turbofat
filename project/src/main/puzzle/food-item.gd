#@tool
class_name FoodItem
extends PackedSprite
## Food item which appears when the player clears a box in puzzle mode.

@warning_ignore("unused_signal")
## Emitted when the food item has floated for long enough and fly_to_target can be called. Emitted by food-items.gd
signal ready_to_fly

## Scale/rotation modifiers applied by our animation
@export var scale_modifier := Vector2.ONE
@export var rotation_modifier := 0.0

## Unmodified scale/rotation before pulsing/spinning
var base_scale := Vector2.ONE: set = set_base_scale
var base_rotation := 0.0: set = set_base_rotation

## Velocity applied to the food when in the 'floating' state
var velocity := Vector2(0, -25)

## Creature who this food will fly towards
var customer: Creature

## Incremented as the customer changes to track the intended recipient of each food item.
var customer_index: int

## Enum from FoodType corresponding to the food to show
var food_type: Foods.FoodType: set = set_food_type

## Food items pulse and rotate. This field is used to calculate the pulse/rotation amount
var _total_time := 0.0

## This func ref and array correspond to a callback which return the position of the customer's mouth.
var _get_target_pos: Callable
var _target_pos_arg_array: Array

## Position the food is flying from
var _source_pos: Vector2

## Position the food is flying toward
var _target_pos: Vector2

## Number in the range [0.0, 1.0] corresponding to where the food is positioned between its source and target
var _flight_percent := 0.0

## 'true' of the food item has been collected and should slowly float upward
var _floating_upward := false

## How far the sprite should rotate; 1.0 = one full circle forward and backward
@onready var _spin_amount := 0.08 * randf_range(0.8, 1.2)

## How many seconds the sprite should take to rotate back and forth once
@onready var _spin_period := 2.50 * randf_range(0.8, 1.2)

func _ready() -> void:
	# randomly increment the total time so items don't spin/pulse in sync
	_total_time += randf_range(0.0, _spin_period)
	
	if not Engine.is_editor_hint():
		# preserve default position/rotation/scale in the editor
		_refresh_scale()
		_refresh_rotation()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		# preserve default position/rotation/scale in the editor
		return
	
	_total_time += delta
	
	if _floating_upward:
		if not _get_target_pos.is_null() and _flight_percent > 0.0:
			_source_pos += velocity * delta
			_target_pos = _get_target_pos.callv(_target_pos_arg_array)
			
			if _target_pos == Vector2.INF:
				# get_target_pos returns Vector2.INF if the food should be removed
				queue_free()
			else:
				# The y coordinate changes at a constant rate while the x coordinate follows a parabolic path
				position.y = lerp(_source_pos.y, _target_pos.y, _flight_percent)
				position.x = lerp(_source_pos.x, _target_pos.x, 2.1 * pow(_flight_percent, 1.6) - 1.1 * _flight_percent)
		else:
			position += velocity * delta
	
	_refresh_scale()
	_refresh_rotation()


## Jiggles the food briefly.
func jiggle() -> void:
	# restart the jiggle animation if the item was already jiggling
	$AnimationPlayer.stop()
	# vary the jiggle animation so that items don't stay in sync when jiggling simultaneously
	$AnimationPlayer.play("jiggle", -1, randf_range(0.5, 1.5))


## Launches the 'food was collected' animation.
##
## This makes the food jiggle and float upward.
func collect() -> void:
	_floating_upward = true
	jiggle()


func set_food_type(new_food_type: Foods.FoodType) -> void:
	food_type = new_food_type
	set_frame(new_food_type)


func set_base_scale(new_base_scale: Vector2) -> void:
	base_scale = new_base_scale
	_refresh_scale()


func set_base_rotation(new_base_rotation: float) -> void:
	base_rotation = new_base_rotation
	_refresh_rotation()


## Sends the food item towards the customer's mouth.
##
## The object, method and arg_array parameters correspond to a callback which returns the position of the customer's
## mouth. The callback function can also return Vector2.INF if the customer is no longer present.
##
## Parameters:
## 	'new_get_target_pos': The callback function which returns the position of the customer's mouth.
##
## 	'target_pos_arg_array': The parameters of the callback function which returns the position of the customer's mouth.
func fly_to_target(new_get_target_pos: Callable, target_pos_arg_array: Array,
			duration: float) -> void:
	_get_target_pos = new_get_target_pos
	_target_pos_arg_array = target_pos_arg_array
	
	velocity = Vector2.ZERO
	
	# Tween the food's position to fly into the customer's mouth
	_source_pos = position
	var flying_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	flying_tween.tween_property(self, "_flight_percent", 1.0, duration)
	flying_tween.tween_callback(Callable(self, "queue_free")).set_delay(0.03)


func _refresh_scale() -> void:
	scale = base_scale * scale_modifier


func _refresh_rotation() -> void:
	rotation_modifier = _spin_amount * PI * sin(_total_time * TAU / _spin_period)
	rotation = base_rotation + rotation_modifier
