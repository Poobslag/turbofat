extends AnimationPlayer
"""
An AnimationPlayer which animates mouths.
"""

export (NodePath) var mouth_path: NodePath

# A frame to switch to when the creature faces away from the camera.
export (int) var north_frame: int

onready var _mouth: Sprite = get_node(mouth_path)
onready var _creature: Creature = $".."

func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# avoid playing animations in editor. manually set frames instead
		_apply_default_frames()
	else:
		if not is_playing():
			_play_mouth_ambient_animation()


"""
Plays an appropriate mouth ambient animation for the creature's orientation.
"""
func _play_mouth_ambient_animation() -> void:
	if _creature.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		play("ambient-se")
	else:
		play("ambient-nw")


"""
Updates the frame to something appropriate for the creature's orientation.

Usually the frame is controlled by an animation. But when it's not, this ensures it still looks reasonable.
"""
func _apply_default_frames() -> void:
	_mouth.frame = 1 if _creature.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST] else north_frame


"""
Reset the mouth frame when loading a new creature appearance.

If we don't reset the eye frame, we have one strange transition frame.
"""
func _on_Creature_before_creature_arrived() -> void:
	_apply_default_frames()


func _on_Creature_orientation_changed(orientation: int) -> void:
	if is_processing():
		_play_mouth_ambient_animation()
