class_name LevelSelectButton
extends Button
## A button on the level select screen which launches a level.

## emitted when a level is launched.
signal level_started

## Emitted when a button is 'lowlighted'.
##
## Lowlighted buttons are unrelated to the currently selected world and fade into the background.
signal lowlight_changed

## short levels have smaller buttons; long levels have larger buttons
enum LevelSize {
	SHORT,
	MEDIUM,
	LONG
}

const BUTTON_COLOR_RED := Color("e35274")
const BUTTON_COLOR_ORANGE := Color("e37452")
const BUTTON_COLOR_YELLOW := Color("e3bf52")
const BUTTON_COLOR_GREEN := Color("7be352")
const BUTTON_COLOR_BLUE := Color("52afe3")
const BUTTON_COLOR_PURPLE := Color("9852e3")

const SHORT := LevelSize.SHORT
const MEDIUM := LevelSize.MEDIUM
const LONG := LevelSize.LONG

const VERTICAL_SPACING := 6

var world_id: String
var level_id: String

## an enum from LevelSize for the duration of the level. this affects the button size
var level_duration: int = LevelSize.MEDIUM setget set_level_duration

## the width of the column this button is in
var level_column_width: int = 120

## the status whether or not this level is locked/unlocked
var lock_status: int = LevelLock.STATUS_NONE setget set_lock_status

## the number of remaining levels the player needs to play to unlock this level
var keys_needed := -1 setget set_keys_needed

var level_title: String setget set_level_title

## 'true' if this button should be darkened so that it doesn't draw the player's attention.
var lowlight: bool setget set_lowlight

## 'true' if this button just received focus this frame. A mouse click which grants focus doesn't emit a 'level
## started' event
var _focus_just_entered := false

## 'true' if the 'level started' signal should be emitted in response to a button click.
var _emit_level_started := false

## The button's background color. If omitted, the button will use a pseudo-random background color based on its id
var bg_color: Color setget set_bg_color

onready var _label := $Label

func _ready() -> void:
	text = ""
	_refresh_appearance()


func _process(_delta: float) -> void:
	_focus_just_entered = false


func set_bg_color(new_bg_color: Color) -> void:
	bg_color = new_bg_color
	_set_style_color(bg_color)


func _set_style_color(color: Color) -> void:
	get("custom_styles/normal").bg_color = color
	get("custom_styles/hover").bg_color = color


func set_lock_status(new_lock_status: int) -> void:
	lock_status = new_lock_status
	_refresh_appearance()


func set_keys_needed(new_keys_needed: int) -> void:
	keys_needed = new_keys_needed
	_refresh_appearance()


func set_level_title(new_level_title: String) -> void:
	level_title = new_level_title
	_refresh_appearance()


func set_level_duration(new_level_duration: int) -> void:
	level_duration = new_level_duration
	_refresh_appearance()


## Updates the button to be 'lowlighted'.
##
## Lowlighted buttons are unrelated to the currently selected world and fade into the background.
func set_lowlight(new_lowlight: bool) -> void:
	lowlight = new_lowlight
	modulate = Color("50ffffff") if lowlight else Color.white
	emit_signal("lowlight_changed")


## Updates the button's text, colors, size and icon based on the level and its status.
func _refresh_appearance() -> void:
	if not is_inside_tree():
		return
	
	match level_duration:
		LevelSize.SHORT: rect_min_size.y = level_column_width * 0.5
		LevelSize.MEDIUM: rect_min_size.y = level_column_width * 0.75 + VERTICAL_SPACING * 0.5
		LevelSize.LONG: rect_min_size.y = level_column_width + VERTICAL_SPACING
	
	_label.text = StringUtils.default_if_empty(level_title, "-")
	
	var new_style_color: Color
	if bg_color:
		new_style_color = bg_color
	else:
		match level_id.hash() % 6:
			0: new_style_color = BUTTON_COLOR_RED
			1: new_style_color = BUTTON_COLOR_ORANGE
			2: new_style_color = BUTTON_COLOR_YELLOW
			3: new_style_color = BUTTON_COLOR_GREEN
			4: new_style_color = BUTTON_COLOR_BLUE
			5: new_style_color = BUTTON_COLOR_PURPLE
	_set_style_color(new_style_color)


func _on_pressed() -> void:
	if lock_status in [LevelLock.STATUS_SOFT_LOCK, LevelLock.STATUS_HARD_LOCK]:
		# level is locked, don't launch the level
		return
	
	if _emit_level_started:
		_emit_level_started = false
		emit_signal("level_started")


func _on_focus_entered() -> void:
	_focus_just_entered = true
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = Color("007a99")


func _on_focus_exited() -> void:
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = Color("6c4331")


func _on_button_down() -> void:
	if _focus_just_entered:
		pass
	else:
		_emit_level_started = true
