#tool #uncomment to view creature in editor
extends AnimationPlayer
"""
An AnimationPlayer which animates mouths.
"""

onready var _creature_visuals: CreatureVisuals = get_parent()

func _ready() -> void:
	_creature_visuals.connect("before_creature_arrived", self, "_on_CreatureVisuals_before_creature_arrived")
	set_process(false)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# avoid playing animations in editor
		return
	
	if not is_playing():
		_play_mouth_ambient_animation()


"""
Plays an appropriate mouth ambient animation for the creature's orientation.
"""
func _play_mouth_ambient_animation() -> void:
	if _creature_visuals.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		play("ambient-se")
	else:
		play("ambient-nw")


"""
This function manually assigns fields which Godot would ideally assign automatically by calling _ready. It is a
workaround for Godot issue #16974 (https://github.com/godotengine/godot/issues/16974)

Tool scripts do not call _ready on reload, which means all onready fields will be null. This breaks this script's
functionality and throws errors when it is used as a tool. This function manually assigns those fields to avoid those
problems.
"""
func _apply_tool_script_workaround() -> void:
	if not _creature_visuals:
		_creature_visuals = get_parent()


func _on_CreatureVisuals_before_creature_arrived() -> void:
	stop()


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, _new_orientation: int) -> void:
	if is_processing() and not Engine.is_editor_hint():
		_creature_visuals.get_node("Neck0/HeadBobber/Mouth").z_index = 0
		_creature_visuals.get_node("Neck0/HeadBobber/EmoteGlow").z_index = 0
		_play_mouth_ambient_animation()


func _on_IdleTimer_start_idle_animation(anim_name) -> void:
	if is_processing() and anim_name in get_animation_list():
		play(anim_name)
