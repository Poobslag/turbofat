class_name PinupScrollers
extends Control
## Creates and manages PinupScrollers, pinups which scroll vertically during the credits.
##
## These scrollers are pooled for performance because the Creature scene is slow to initialize.

## Number of creatures stored in the pinup pool. Higher values require more resources, but ensure we won't recycle a
## pinup which is still visible.
const PINUP_POOL_SIZE := 5

export (PackedScene) var PinupScrollerScene: PackedScene

var velocity := Vector2(0, -60)

## Queue of PinupScroller instances to reuse.
var _pinup_scroller_pool := []

onready var _pinup_holder := $PinupHolder

func _ready() -> void:
	for _i in range(PINUP_POOL_SIZE):
		var pinup_scroller: PinupScroller = PinupScrollerScene.instance()
		pinup_scroller.stop()
		_pinup_holder.add_child(pinup_scroller)
		_pinup_scroller_pool.append(pinup_scroller)


## Initializes a PinupScroller for the specified creature.
##
## This does not create a new PinupScroller because the Creature scene is slow to initialize. It reuses a pooled
## scroller and initializes it to the bottom of the screen.
##
## Parameters:
## 	'creature_id': The creature to show
##
## 	'pinup_side': An enum from PinupScroller.Side for the side of the screen the pinup appears on
func add_pinup(creature_id: String, pinup_side: int, bg_color: Color) -> void:
	# grab the oldest pinup out of the pool
	var scroller: PinupScroller = _pinup_scroller_pool.pop_front()
	_pinup_scroller_pool.push_back(scroller)
	
	scroller.start()
	
	# initialize it to the correct side
	scroller.position = Vector2(-128, 750)
	if pinup_side == PinupScroller.SIDE_RIGHT:
		 scroller.position.x = 512 - scroller.position.x
	
	# initialize it to the correct creature ID
	scroller.pinup.creature_id = creature_id
	scroller.pinup.orientation = \
			Creatures.SOUTHEAST if pinup_side == PinupScroller.SIDE_LEFT else Creatures.SOUTHWEST
	scroller.pinup.bg_color = bg_color
	
	# initialize velocity
	scroller.velocity = velocity


## Replaces the pinup with a stylish transformed image.
func transform_pinup(creature_id: String, flip_h: bool = false) -> void:
	var scroller: PinupScroller = _find_scroller_for_creature_id(creature_id)
	if not scroller:
		push_warning("Unrecognized creature id: %s" % [creature_id])
		return
	
	scroller.pinup.transform(flip_h)


## Animates the creature's appearance according to the specified mood: happy, angry, etc...
##
## Parameters:
## 	'creature_id': The creature to animate
##
## 	'mood_name': A snake-case enum from Creatures.Mood such as 'think0'
func play_pinup_mood(creature_id: String, mood_name: String) -> void:
	var scroller: PinupScroller = _find_scroller_for_creature_id(creature_id)
	if not scroller:
		push_warning("Unrecognized creature id: %s" % [creature_id])
		return
	
	var mood_int: int = Utils.enum_from_snake_case(Creatures.Mood, mood_name, 0)
	if mood_int == 0:
		push_warning("Unrecognized mood: %s" % [mood_name])
		return
	
	scroller.pinup.play_mood(mood_int)


func _find_scroller_for_creature_id(creature_id: String) -> PinupScroller:
	var result: PinupScroller
	for pinup_scroller_obj in _pinup_holder.get_children():
		var pinup_scroller: PinupScroller = pinup_scroller_obj
		if pinup_scroller.pinup.creature_id == creature_id:
			result = pinup_scroller
	return result
