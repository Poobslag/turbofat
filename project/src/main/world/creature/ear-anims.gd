#tool #uncomment to view creature in editor
extends AnimationPlayer
"""
An AnimationPlayer which animates ears.
"""

onready var _creature_visuals: CreatureVisuals = get_parent()

func _ready() -> void:
	_creature_visuals.connect("before_creature_arrived", self, "_on_CreatureVisuals_before_creature_arrived")
	_creature_visuals.connect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
	set_process(false)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# don't trigger animations in editor
		return
	
	if _creature_visuals.orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST] \
		and not is_playing():
			play("ambient")
			advance(randf() * current_animation_length)


"""
Randomly advances the current animation up to 1.0 seconds. Used to ensure all creatures don't wiggle their ears
synchronously.
"""
func advance_animation_randomly() -> void:
	advance(min(randf(), randf()))


func _on_IdleTimer_start_idle_animation(anim_name) -> void:
	if is_processing() and anim_name in get_animation_list():
		play(anim_name)


func _on_CreatureVisuals_before_creature_arrived() -> void:
	if is_processing():
		stop()


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, _new_orientation: int) -> void:
	if is_processing() and not _new_orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]:
		stop()
