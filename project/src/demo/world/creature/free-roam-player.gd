class_name FreeRoamPlayer
extends Creature
## Script for manipulating the player-controlled character in the overworld.

## if 'true' the player is in free roam mode and can move with the arrow keys.
var free_roam := false

func _ready() -> void:
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	refresh_collision_extents()


func _unhandled_input(event: InputEvent) -> void:
	if not free_roam:
		# disable movement outside of free roam mode
		return
	
	if Utils.ui_pressed_dir(event) or Utils.ui_released_dir(event):
		# calculate the direction the player wants to move
		set_non_iso_walk_direction(Utils.ui_pressed_dir())
		if is_inside_tree():
			get_tree().set_input_as_handled()


## Stop moving when a chat choice appears.
func _on_OverworldUi_showed_chat_choices() -> void:
	if non_iso_walk_direction:
		set_non_iso_walk_direction(Vector2.ZERO)


func _on_SceneTransition_fade_out_started(_duration: float) -> void:
	# suppress 'bonk' sound effects, otherwise it sounds like the player bumps into the door
	set_suppress_sfx(true)
