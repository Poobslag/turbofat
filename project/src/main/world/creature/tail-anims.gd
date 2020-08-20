extends AnimationPlayer
"""
An AnimationPlayer which animates a creature's tail.

Specifically, this animationplayer ensures the tail is always moving, if nothing else is animating it.
"""

export (NodePath) var movement_anims_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_parent()
onready var _movement_anims: AnimationPlayer = get_node(movement_anims_path)

func _ready() -> void:
	_movement_anims.connect("animation_started", self, "_on_MovementAnims_animation_started")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# avoid playing animations in editor
		return
	
	if not is_playing() and not _movement_anims.current_animation.begins_with("sprint"):
		_play_tail_ambient_animation()


"""
Plays an appropriate tail ambient animation for the creature's orientation and movement state.
"""
func _play_tail_ambient_animation() -> void:
	var tail_ambient_animation: String
	if _creature_visuals.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		tail_ambient_animation = "ambient-se"
	else:
		tail_ambient_animation = "ambient-nw"
	play(tail_ambient_animation)


func _on_MovementAnims_animation_started(anim_name: String) -> void:
	if anim_name.begins_with("sprint"):
		stop()


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, _new_orientation: int) -> void:
	if is_playing():
		_play_tail_ambient_animation()
