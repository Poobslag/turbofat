class_name Player
extends Creature
## Script for manipulating the player-controlled character in the overworld.

## if 'true' the ui has focus and the player shouldn't move.
var ui_has_focus := false setget set_ui_has_focus

## if 'true' the player is in free roam mode and can move with the arrow keys.
var free_roam := false

## Cannot statically type as 'OverworldUi' because of circular reference
onready var _overworld_ui: Node = Global.get_overworld_ui()

func _ready() -> void:
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	set_creature_id(CreatureLibrary.PLAYER_ID)
	refresh_collision_extents()


func _unhandled_input(_event: InputEvent) -> void:
	if not free_roam:
		# disable movement outside of free roam mode
		return
	
	if ui_has_focus:
		# disable movement when navigating menus
		return
	
	if ui_pressed_dir(_event) or ui_released_dir(_event):
		# calculate the direction the player wants to move
		set_non_iso_walk_direction(ui_pressed_dir())
		get_tree().set_input_as_handled()


func set_ui_has_focus(new_ui_has_focus: bool) -> void:
	ui_has_focus = new_ui_has_focus
	if ui_has_focus and non_iso_walk_direction:
		# if the player is moving when something grabs focus, stop their movement
		set_non_iso_walk_direction(Vector2.ZERO)


## Stop moving when a chat choice appears.
func _on_OverworldUi_showed_chat_choices() -> void:
	if non_iso_walk_direction:
		set_non_iso_walk_direction(Vector2.ZERO)


func _on_SceneTransition_fade_out_started() -> void:
	# suppress 'bonk' sound effects, otherwise it sounds like the player bumps into the door
	set_suppress_sfx(true)


## Returns a vector corresponding to the direction the user is pressing.
##
## Parameters:
## 	'event': (Optional) The input event to be evaluated. If null, this method will evaluate all current inputs.
static func ui_pressed_dir(event: InputEvent = null) -> Vector2:
	var ui_dir := Vector2.ZERO
	if event:
		if event.is_action_pressed("ui_up"):
			ui_dir += Vector2.UP
		if event.is_action_pressed("ui_down"):
			ui_dir += Vector2.DOWN
		if event.is_action_pressed("ui_left"):
			ui_dir += Vector2.LEFT
		if event.is_action_pressed("ui_right"):
			ui_dir += Vector2.RIGHT
	else:
		if Input.is_action_pressed("ui_up"):
			ui_dir += Vector2.UP
		if Input.is_action_pressed("ui_down"):
			ui_dir += Vector2.DOWN
		if Input.is_action_pressed("ui_left"):
			ui_dir += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			ui_dir += Vector2.RIGHT
	return ui_dir


## Returns 'true' if the player just released a direction key.
##
## Parameters:
## 	'event': (Optional) The input event to be evaluated. If null, this method will evaluate all current inputs.
static func ui_released_dir(event: InputEvent = null) -> bool:
	var ui_dir := Vector2.ZERO
	if event:
		if event.is_action_released("ui_up"):
			ui_dir += Vector2.UP
		if event.is_action_released("ui_down"):
			ui_dir += Vector2.DOWN
		if event.is_action_released("ui_left"):
			ui_dir += Vector2.LEFT
		if event.is_action_released("ui_right"):
			ui_dir += Vector2.RIGHT
	else:
		if Input.is_action_just_released("ui_up"):
			ui_dir += Vector2.UP
		if Input.is_action_just_released("ui_down"):
			ui_dir += Vector2.DOWN
		if Input.is_action_just_released("ui_left"):
			ui_dir += Vector2.LEFT
		if Input.is_action_just_released("ui_right"):
			ui_dir += Vector2.RIGHT
	return ui_dir.length() > 0
