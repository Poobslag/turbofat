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
func add_pinup(creature_id: String, pinup_side: int) -> void:
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
	
	# initialize velocity
	scroller.velocity = velocity
