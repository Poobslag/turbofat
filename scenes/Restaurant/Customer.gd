"""
Handles animations and audio/visual effects for a customer.
"""
extends Node2D

# food colors for the food which gets hurled into the customer's mouth
const FOOD_COLORS: Array = [
	Color("a4470b"), # brown
	Color("ff5d68"), # pink
	Color("ffa357"), # bread
	Color("fff6eb") # white
]

# signal emitted on the frame when the food is launched into the customer's mouth
signal food_eaten

# sounds which get played when the customer eats
onready var _munch_sounds:Array = [
	$Munch0,
	$Munch1,
	$Munch2,
	$Munch3,
	$Munch4
]

# the food object which should be animated and recolored when we eat
onready var Food = get_node("../KludgeCustomer/KludgeNeck/KludgeHead/Food")
onready var FoodLaser = get_node("../KludgeCustomer/KludgeNeck/KludgeHead/FoodLaser")

# the total number of seconds which have elapsed since the object was created
var _total_seconds := 0.0

# the creature's head bobs up and down slowly, these fields control how much it bobs
var _head_bob_seconds := 6.5
var _head_bob_pixels := 2

# the index of the previously launched food color. stored to avoid showing the same color twice consecutively
var _food_color_index := 0

func _process(delta: float) -> void:
	_total_seconds += delta
	
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("Blink")
	
	$Neck/Head.position.y = -100 + _head_bob_pixels * sin((_total_seconds * 2 * PI) / _head_bob_seconds)

"""
Launches the 'feed' animation, hurling a piece of food at the customer and having them catch it.
"""
func feed() -> void:
	if $AnimationPlayer.current_animation == "Eat" || $AnimationPlayer.current_animation == "EatAgain":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("EatAgain")
		show_food_effects()
	else:
		$AnimationPlayer.play("Eat")
		show_food_effects(0.066)

"""
The 'feed' animation causes a few side-effects. The customer's head recoils and some sounds play. This method controls
all of those secondary visual effects of the customer being fed.

Parameters: The 'delay' parameter causes the food effects to appear after the specified delay, in seconds.
"""
func show_food_effects(delay := 0.0) -> void:
	var munch_sound: AudioStreamPlayer = _munch_sounds[randi() % _munch_sounds.size()]
	munch_sound.pitch_scale = rand_range(0.96, 1.04)

	# avoid using the same color twice consecutively
	_food_color_index = (_food_color_index + 1 + randi() % (FOOD_COLORS.size() - 1)) % FOOD_COLORS.size()
	var food_color: Color = FOOD_COLORS[_food_color_index]
	Food.modulate = food_color
	FoodLaser.modulate = food_color

	yield(get_tree().create_timer(delay), "timeout")
	munch_sound.play()
	$Tween.interpolate_property($Neck/Head, "position:x", clamp($Neck/Head.position.x - 6, -20, 0), 0, 0.5,
			Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	$Tween.start()
	emit_signal("food_eaten")
