class_name Spira
extends Creature
"""
Script for manipulating the player-controlled character 'Spira' in the overworld.
"""

func _ready() -> void:
	ChattableManager.spira = self


func _unhandled_input(_event: InputEvent) -> void:
	if Utils.ui_pressed_dir(_event) or Utils.ui_released_dir(_event):
		# calculate the direction the player wants to move
		set_non_iso_walk_direction(Utils.ui_pressed_dir())
		get_tree().set_input_as_handled()


"""
Stop moving when a chat choice appears.
"""
func _on_OverworldUi_showed_chat_choices() -> void:
	if non_iso_walk_direction:
		set_non_iso_walk_direction(Vector2.ZERO)
