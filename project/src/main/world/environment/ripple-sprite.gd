class_name RippleSprite
extends AnimatedSprite2D
## Renders an animated goop ripple.
##
## Each ripple is only one tile in size. A goop wave is made up of many ripples in a line.

## duration for goop ripples to fade in and out when they hit the edge of the map
const FADE_DURATION := 0.3

@export (Ripples.RippleState) var ripple_state := Ripples.RippleState.OFF: set = set_ripple_state

@onready var _fade_tween: Tween

func _ready() -> void:
	modulate = Color.TRANSPARENT
	_refresh_ripple_state()


## Sets the ripple state and updates the ripple's appearance.
func set_ripple_state(new_ripple_state: int) -> void:
	if ripple_state == new_ripple_state:
		return
	
	ripple_state = new_ripple_state
	_refresh_ripple_state()


## Updates the ripple appearance based on the ripple state.
##
## If the ripple state is 'left', 'right', 'both' or 'none', this makes the sprite visible and plays an animation.
##
## If the ripple state is 'off', this makes the sprite invisible.
func _refresh_ripple_state() -> void:
	# fade the sprite in or out
	var new_modulate := Color.TRANSPARENT if ripple_state == Ripples.RippleState.OFF else Color.WHITE
	if modulate != new_modulate:
		_fade_tween = Utils.recreate_tween(self, _fade_tween)
		_fade_tween.tween_property(self, "modulate", new_modulate, FADE_DURATION)
	
	# determine the animation to play. we change the animation if the sprite is flipped
	var new_anim := ""
	match ripple_state:
		Ripples.RippleState.CONNECTED_NONE: new_anim = "connected_none"
		Ripples.RippleState.CONNECTED_LEFT: new_anim = "connected_left" if flip_h == flip_v else "connected_right"
		Ripples.RippleState.CONNECTED_RIGHT: new_anim = "connected_right" if flip_h == flip_v else "connected_left"
		Ripples.RippleState.CONNECTED_BOTH: new_anim = "connected_both"
	
	# play the new animation
	if new_anim:
		play(new_anim)
		if frames.get_frame_count(new_anim):
			frame = randi() % frames.get_frame_count(new_anim)
		
		# Assign a random speed scale. The animations can't be perfectly in sync because we swap animations at sporadic
		# times. It's better to be perfectly out of sync than mostly in sync.
		speed_scale = randf_range(0.9, 1.1)
