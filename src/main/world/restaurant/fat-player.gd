extends AnimationPlayer
"""
Controls an animation for making a customer fatter or thinner. Stores a field for how fat the customer should be, and
plays an animation forward and backwards to adjust the customer's appearance.
"""

# how large the creature has grown; 5.0 = 5x normal size
var _fatness := 1.0 setget set_fatness, get_fatness

func _process(_delta: float) -> void:
	if is_playing():
		# stop animating once we've passed the desired fatness
		if get_playing_speed() > 0 and current_animation_position >= _fatness:
			stop()
		if get_playing_speed() < 0 and current_animation_position <= _fatness:
			stop()


"""
Increases/decreases the customer's fatness, playing an animation which gradually applies the change.

Parameters:
	'fatness': How fat the customer should be; 5.0 = 5x normal size
"""
func set_fatness(fatness: float) -> void:
	var old_fatness: float
	if is_playing():
		old_fatness = clamp(current_animation_position, 1, CustomerLoader.MAX_FATNESS)
	else:
		old_fatness = clamp(_fatness, 1, CustomerLoader.MAX_FATNESS)
	_fatness = fatness
	if fatness == old_fatness:
		# no change; animation is unnecessary
		return
	var d_fatness := (fatness - old_fatness) / CustomerLoader.GROWTH_SECONDS
	stop()
	play("fat", -1.0, d_fatness, old_fatness > fatness)
	if d_fatness < 0:
		# getting thinner, play the animation backwards. avoid calling advance(float) with zero, as this prevents the
		# animation from playing
		if old_fatness != CustomerLoader.MAX_FATNESS:
			advance((old_fatness - CustomerLoader.MAX_FATNESS) / d_fatness)
	else:
		# getting fatter, play the animation forwards
		advance(old_fatness / d_fatness)


func get_fatness() -> float:
	return _fatness
