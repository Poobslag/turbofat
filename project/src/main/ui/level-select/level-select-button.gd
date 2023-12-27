class_name LevelSelectButton
extends Control
## Button on the level select screen which launches a level.
##
## The button adjusts its rect_min_size based on level duration.

## emitted when a level is launched.
signal level_chosen

## short levels have smaller buttons; long levels have larger buttons
enum LevelSize {
	SHORT,
	MEDIUM,
	LONG
}

## status whether or not a level is locked/unlocked
enum LockStatus {
	NONE, # not locked
	CLEARED, # cleared without any rank; used for tutorials
	KEY, # not locked, and can unlock another level
	CROWN, # not locked, and can unlock another world
	LOCKED, # locked
}

const BUTTON_COLOR_RED := Color("e35274")
const BUTTON_COLOR_ORANGE := Color("e37452")
const BUTTON_COLOR_YELLOW := Color("e3bf52")
const BUTTON_COLOR_GREEN := Color("7be352")
const BUTTON_COLOR_BLUE := Color("52afe3")
const BUTTON_COLOR_PURPLE := Color("9852e3")

const STATUS_NONE := LockStatus.NONE
const STATUS_KEY := LockStatus.KEY
const STATUS_CROWN := LockStatus.CROWN
const STATUS_CLEARED := LockStatus.CLEARED
const STATUS_LOCKED := LockStatus.LOCKED

const SHORT := LevelSize.SHORT
const MEDIUM := LevelSize.MEDIUM
const LONG := LevelSize.LONG

const MAX_BUTTON_HEIGHT := 120
const VERTICAL_SPACING := 6

var level_id: String

## Enum from LevelSize for the duration of the level. This affects the button size
var level_duration: int = LevelSize.MEDIUM setget set_level_duration

## status whether or not this level is locked/unlocked
var lock_status: int = STATUS_NONE setget set_lock_status

## number of remaining levels the player needs to play to unlock this level
var keys_needed := -1 setget set_keys_needed

var level_name: String setget set_level_name

## Button's background color. If omitted, the button will use a pseudo-random background color based on its id
var bg_color: Color setget set_bg_color

## 'true' if this button just received focus this frame. A mouse click which grants focus doesn't emit a 'level
## started' event
var _focus_just_entered := false

## 'true' if the 'level started' signal should be emitted in response to a button click.
var _emit_level_chosen := false

onready var _button_control := $ButtonControlHolder/ButtonControl
onready var _label := $ButtonControlHolder/ButtonControl/Label

func _ready() -> void:
	_button_control.text = ""
	_button_control.rect_size = rect_size
	_refresh_size()
	_refresh_appearance()


func _process(_delta: float) -> void:
	_focus_just_entered = false


func set_bg_color(new_bg_color: Color) -> void:
	bg_color = new_bg_color
	refresh_style_color(bg_color)


func set_lock_status(new_lock_status: int) -> void:
	lock_status = new_lock_status
	_refresh_appearance()


func set_keys_needed(new_keys_needed: int) -> void:
	keys_needed = new_keys_needed
	_refresh_appearance()


func set_level_name(new_level_name: String) -> void:
	level_name = new_level_name
	_refresh_appearance()


func set_level_duration(new_level_duration: int) -> void:
	level_duration = new_level_duration
	_refresh_appearance()


## Updates the button's style colors. Can be overridden by child buttons who use different styles.
func refresh_style_color(color: Color) -> void:
	_button_control.get("custom_styles/normal").bg_color = color
	_button_control.get("custom_styles/hover").bg_color = color


## Updates the button's text, colors, size and icon based on the level and its status.
func _refresh_appearance() -> void:
	if not is_inside_tree():
		return
	
	match level_duration:
		LevelSize.SHORT: rect_min_size.y = MAX_BUTTON_HEIGHT * 0.5
		LevelSize.MEDIUM: rect_min_size.y = MAX_BUTTON_HEIGHT * 0.75 + VERTICAL_SPACING * 0.5
		LevelSize.LONG: rect_min_size.y = MAX_BUTTON_HEIGHT + VERTICAL_SPACING
	
	_label.text = StringUtils.default_if_empty(level_name, "-")
	
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
	refresh_style_color(new_style_color)


func _refresh_size() -> void:
	if not _button_control:
		return
	
	_button_control.rect_size = rect_size


func _on_resized() -> void:
	_refresh_size()


func _on_ButtonControl_pressed() -> void:
	if lock_status == STATUS_LOCKED:
		# level is locked, don't launch the level
		return
	
	if _emit_level_chosen:
		_emit_level_chosen = false
		emit_signal("level_chosen")


func _on_ButtonControl_focus_entered() -> void:
	_focus_just_entered = true
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = Color("007a99")


func _on_ButtonControl_focus_exited() -> void:
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = Color("6c4331")


func _on_ButtonControl_button_down() -> void:
	if _focus_just_entered:
		pass
	else:
		_emit_level_chosen = true
