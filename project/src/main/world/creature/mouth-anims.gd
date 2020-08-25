#tool #uncomment to view creature in editor
extends AnimationPlayer
"""
An AnimationPlayer which animates mouths.
"""

# emote animations which should result in a frown, if the mouth is capable of frowning
const FROWN_ANIMS = {
	"ambient-sweat": "",
	"cry0": "",
	"cry1": "",
	"eat-sweat0": "",
	"eat-sweat1": "",
	"eat-sweat2": "",
	"eat-again-sweat0": "",
	"eat-again-sweat1": "",
	"eat-again-sweat2": "",
	"rage0": "",
	"rage1": "",
	"sweat0": "",
	"sweat1": "",
	"think1": "",
}

export (NodePath) var emote_anims_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_parent()
onready var _emote_anims: AnimationPlayer = get_node(emote_anims_path)

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
Plays an appropriate mouth ambient animation for the creature's orientation and mood.
"""
func _play_mouth_ambient_animation() -> void:
	var mouth_ambient_animation: String
	if _creature_visuals.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		if _emote_anims.current_animation in ["", "ambient"] \
				and current_animation in ["ambient-se", "ambient-unhappy"]:
			# keep old mood; otherwise we have one 'happy mouth frame' between two angry moods
			mouth_ambient_animation = current_animation
		elif has_animation("ambient-unhappy") and FROWN_ANIMS.has(_emote_anims.current_animation):
			mouth_ambient_animation = "ambient-unhappy"
		else:
			mouth_ambient_animation = "ambient-se"
	else:
		mouth_ambient_animation = "ambient-nw"
	play(mouth_ambient_animation)


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


func _on_IdleTimer_idle_animation_started(anim_name: String) -> void:
	if is_processing() and anim_name in get_animation_list():
		play(anim_name)


func _on_EmoteAnims_animation_started(_anim_name: String) -> void:
	if current_animation.begins_with("ambient-"):
		_play_mouth_ambient_animation()


func _on_IdleTimer_idle_animation_stopped() -> void:
	if is_processing() and current_animation.begins_with("idle"):
		stop()
