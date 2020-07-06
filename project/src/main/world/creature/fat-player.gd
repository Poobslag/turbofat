extends AnimationPlayer
"""
Controls an animation for making a creature fatter or thinner. Stores a field for how fat the creature should be, and
plays an animation forward and backwards to adjust the creature's appearance.
"""

# how large the creature has grown; 5.0 = 5x normal size
var _fatness := 1.0 setget set_fatness, get_fatness

# we track where the creature is facing so we know which animation to play
var _creature_orientation := CreatureVisuals.SOUTHEAST

# we track whether the creature is moving to avoid interrupting their animation
var _movement_mode: bool

func _process(_delta: float) -> void:
	if is_playing():
		# stop animating once we've passed the desired fatness
		if get_playing_speed() > 0 and current_animation_position >= _fatness:
			stop()
		if get_playing_speed() < 0 and current_animation_position <= _fatness:
			stop()


"""
Increases/decreases the creature's fatness, playing an animation which gradually applies the change.

Parameters:
	'new_fatness': How fat the creature should be; 5.0 = 5x normal size
"""
func set_fatness(new_fatness: float) -> void:
	var old_fatness: float
	if is_playing():
		old_fatness = clamp(current_animation_position, 1, CreatureLoader.MAX_FATNESS)
	else:
		old_fatness = clamp(_fatness, 1, CreatureLoader.MAX_FATNESS)
	_fatness = new_fatness
	if new_fatness == old_fatness or _movement_mode:
		# don't animate; it's unnecessary or would interrupt another animation
		return
	
	var d_fatness := (new_fatness - old_fatness) / CreatureLoader.GROWTH_SECONDS
	stop()
	var new_anim_name := "fat-se" if _creature_orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST] else "fat-nw"
	play(new_anim_name, -1.0, d_fatness, old_fatness > new_fatness)
	if d_fatness < 0:
		# getting thinner, play the animation backwards. avoid calling advance(float) with zero, as this prevents the
		# animation from playing
		if old_fatness != CreatureLoader.MAX_FATNESS:
			advance((old_fatness - CreatureLoader.MAX_FATNESS) / d_fatness)
	else:
		# getting fatter, play the animation forwards
		advance(old_fatness / d_fatness)


func get_fatness() -> float:
	return _fatness


func _on_CreatureVisuals_orientation_changed(old_orientation: int, new_orientation: int) -> void:
	_creature_orientation = new_orientation
	if _movement_mode:
		# don't play animations during movement mode
		return
	
	var new_anim_name: String
	if new_orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST] \
		and not old_orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
			new_anim_name = "fat-se"
	if old_orientation in [Creature.NORTHWEST, Creature.NORTHEAST] \
		and not old_orientation in [Creature.NORTHWEST, Creature.NORTHEAST]:
			new_anim_name = "fat-nw"
	if new_anim_name:
		var old_fatness: float
		if is_playing():
			old_fatness = clamp(current_animation_position, 1, CreatureLoader.MAX_FATNESS)
		else:
			old_fatness = clamp(_fatness, 1, CreatureLoader.MAX_FATNESS)
		var d_fatness := 0.1
		play(new_anim_name, -1.0, d_fatness)
		advance(_fatness)


func _on_CreatureVisuals_movement_mode_changed(new_movement_mode: bool) -> void:
	_movement_mode = new_movement_mode
	if _movement_mode and is_playing():
		stop()
