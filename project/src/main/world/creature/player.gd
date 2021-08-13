class_name Player
extends Creature
"""
Script for manipulating the player-controlled character in the overworld.
"""

# If 'true' the player cannot move. Used during cutscenes.
var input_disabled := false

# if 'true' the ui has focus, and the player shouldn't move.
var ui_has_focus := false setget set_ui_has_focus

func _ready() -> void:
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	
	set_creature_def(PlayerData.creature_library.player_def)
	creature_id = CreatureLibrary.PLAYER_ID
	if PlayerData.creature_library.forced_fatness:
		set_fatness(PlayerData.creature_library.forced_fatness)
		set_visual_fatness(PlayerData.creature_library.forced_fatness)
	refresh_collision_extents()
	ChattableManager.player = self


func _unhandled_input(_event: InputEvent) -> void:
	if input_disabled or ui_has_focus:
		return
	
	if Utils.walk_pressed_dir(_event) or Utils.walk_released_dir(_event):
		# calculate the direction the player wants to move
		set_non_iso_walk_direction(Utils.walk_pressed_dir())
		get_tree().set_input_as_handled()


func set_ui_has_focus(new_ui_has_focus: bool) -> void:
	ui_has_focus = new_ui_has_focus
	if ui_has_focus and non_iso_walk_direction:
		# if the player is moving when something grabs focus, stop their movement
		set_non_iso_walk_direction(Vector2(0, 0))


"""
Stop moving when a chat choice appears.
"""
func _on_OverworldUi_showed_chat_choices() -> void:
	if non_iso_walk_direction:
		set_non_iso_walk_direction(Vector2.ZERO)


func _on_SceneTransition_fade_out_started() -> void:
	# suppress 'bonk' sound effects, otherwise it sounds like the player bumps into the door
	set_suppress_sfx(true)
