class_name Player
extends Creature
## Script for manipulating the player-controlled character in the overworld.

## if 'true' the ui has focus and the player shouldn't move.
var ui_has_focus := false: set = set_ui_has_focus

## if 'true' the player is in free roam mode and can move with the arrow keys.
var free_roam := false

func _ready() -> void:
	super()
	SceneTransition.fade_out_started.connect(_on_SceneTransition_fade_out_started)
	set_creature_id(CreatureLibrary.PLAYER_ID)
	refresh_collision_extents()


func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if not free_roam:
		# disable movement outside of free roam mode
		return
	
	if ui_has_focus:
		# disable movement when navigating menus
		return
	
	if Utils.ui_pressed_dir(event).length() > 0 or Utils.ui_released_dir(event):
		# calculate the direction the player wants to move
		set_non_iso_walk_direction(Utils.ui_pressed_dir())
		get_viewport().set_input_as_handled()


func set_ui_has_focus(new_ui_has_focus: bool) -> void:
	ui_has_focus = new_ui_has_focus
	if ui_has_focus and non_iso_walk_direction.length() > 0:
		# if the player is moving when something grabs focus, stop their movement
		set_non_iso_walk_direction(Vector2.ZERO)


## Stop moving when a chat choice appears.
func _on_OverworldUi_showed_chat_choices() -> void:
	if non_iso_walk_direction:
		set_non_iso_walk_direction(Vector2.ZERO)


func _on_SceneTransition_fade_out_started() -> void:
	# suppress 'bonk' sound effects, otherwise it sounds like the player bumps into the door
	set_suppress_sfx(true)
