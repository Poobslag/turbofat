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

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

var _creature_visuals: CreatureVisuals
var _emote_player: AnimationPlayer

func _ready() -> void:
	_refresh_creature_visuals_path()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# avoid playing animations in editor
		return
	
	if not is_playing():
		_play_mouth_ambient_animation()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


"""
Plays an eating animation.
"""
func eat() -> void:
	if current_animation.begins_with("eat"):
		stop()
		play("eat-again")
	else:
		stop()
		play("eat")


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	if _creature_visuals:
		_creature_visuals.disconnect("before_creature_arrived", self, "_on_CreatureVisuals_before_creature_arrived")
		_creature_visuals.disconnect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
		_emote_player.disconnect("animation_started", self, "_on_EmotePlayer_animation_started")
		_creature_visuals.get_idle_timer().disconnect(
				"idle_animation_started", self, "_on_IdleTimer_idle_animation_started")
		_creature_visuals.get_idle_timer().disconnect(
				"idle_animation_stopped", self, "_on_IdleTimer_idle_animation_stopped")
	
	_creature_visuals = get_node(creature_visuals_path)
	_emote_player = _creature_visuals.get_emote_player()
	
	_creature_visuals.connect("before_creature_arrived", self, "_on_CreatureVisuals_before_creature_arrived")
	_creature_visuals.connect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")
	_emote_player.connect("animation_started", self, "_on_EmotePlayer_animation_started")
	_creature_visuals.get_idle_timer().connect("idle_animation_started", self, "_on_IdleTimer_idle_animation_started")
	_creature_visuals.get_idle_timer().connect("idle_animation_stopped", self, "_on_IdleTimer_idle_animation_stopped")


"""
Plays an appropriate mouth ambient animation for the creature's orientation and mood.
"""
func _play_mouth_ambient_animation() -> void:
	var mouth_ambient_animation: String
	if _creature_visuals.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		if _emote_player.current_animation in ["", "ambient"] \
				and current_animation in ["ambient-se", "ambient-unhappy"]:
			# keep old mood; otherwise we have one 'happy mouth frame' between two angry moods
			mouth_ambient_animation = current_animation
		elif has_animation("ambient-unhappy") and FROWN_ANIMS.has(_emote_player.current_animation):
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
	if not Engine.is_editor_hint():
		_creature_visuals.get_node("Neck0/HeadBobber/Mouth").z_index = 0
		_creature_visuals.get_node("Neck0/HeadBobber/EmoteGlow").z_index = 0
		_play_mouth_ambient_animation()


func _on_IdleTimer_idle_animation_started(anim_name: String) -> void:
	if anim_name in get_animation_list():
		play(anim_name)


func _on_IdleTimer_idle_animation_stopped() -> void:
	if current_animation.begins_with("idle"):
		stop()


func _on_EmotePlayer_animation_started(_anim_name: String) -> void:
	if current_animation.begins_with("ambient-"):
		_play_mouth_ambient_animation()
