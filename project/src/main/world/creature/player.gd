class_name Player
extends Creature
"""
Script for manipulating the player-controlled character in the overworld.
"""

func _ready() -> void:
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	set_creature_def(PlayerData.creature_library.player_def)
	ChattableManager.player = self


func _unhandled_input(_event: InputEvent) -> void:
	if Utils.walk_pressed_dir(_event) or Utils.walk_released_dir(_event):
		# calculate the direction the player wants to move
		set_non_iso_walk_direction(Utils.walk_pressed_dir())
		get_tree().set_input_as_handled()


"""
Stop moving when a chat choice appears.
"""
func _on_OverworldUi_showed_chat_choices() -> void:
	if non_iso_walk_direction:
		set_non_iso_walk_direction(Vector2.ZERO)


func _on_SceneTransition_fade_out_started() -> void:
	# suppress 'bonk' sound effects, otherwise it sounds like the player bumps into the door
	set_suppress_sfx(true)
