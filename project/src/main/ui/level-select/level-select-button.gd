class_name LevelSelectButton
extends Button
"""
A button on the level select screen which launches a level.
"""

# emitted when a level is launched.
signal level_started

signal lowlight_changed

# short levels have smaller buttons; long levels have larger buttons
enum LevelSize {
	SHORT,
	MEDIUM,
	LONG
}

const SHORT := LevelSize.SHORT
const MEDIUM := LevelSize.MEDIUM
const LONG := LevelSize.LONG

const VERTICAL_SPACING := 6

var world_id: String
var level_id: String

# the duration of the level; this affects the button size
var level_duration: int = LevelSize.MEDIUM setget set_level_duration

# the width of the column this button is in
var level_column_width: int = 120

# the status whether or not this level is locked/unlocked
var lock_status: int = LevelLock.STATUS_NONE setget set_lock_status

# the number of remaining levels the player needs to play to unlock this level
var keys_needed := -1 setget set_keys_needed

var level_title: String setget set_level_title

# 'true' if this button should be darkened so that it doesn't draw the player's attention.
var lowlight: bool setget set_lowlight

# 'true' if this button just received focus this frame. a mouse click which grants focus doesn't emit a 'level
# started' event
var _focus_just_entered := false

# 'true' if the 'level started' signal should be emitted in response to a button click.
var _emit_level_started := false

func _ready() -> void:
	text = ""
	_refresh_appearance()


func _process(_delta: float) -> void:
	_focus_just_entered = false


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


func set_lowlight(new_lowlight: bool) -> void:
	lowlight = new_lowlight
	modulate = Color("50ffffff") if lowlight else Color.white
	emit_signal("lowlight_changed")


"""
Updates the button's text, colors, size and icon based on the level and its status.
"""
func _refresh_appearance() -> void:
	match level_duration:
		LevelSize.SHORT: rect_min_size.y = level_column_width * 0.5
		LevelSize.MEDIUM: rect_min_size.y = level_column_width * 0.75 + VERTICAL_SPACING * 0.5
		LevelSize.LONG: rect_min_size.y = level_column_width + VERTICAL_SPACING
	
	$Label.text = level_title if level_title else "-"
	
	var hue: float
	match $Label.text.hash() % 5:
		0: hue = 0.9611 # red
		1: hue = 0.0389 # orange
		2: hue = 0.1250 # yellow
		3: hue = 0.2861 # green
		4: hue = 0.7472 # purple
		
	get("custom_styles/normal").bg_color.h = hue
	get("custom_styles/hover").bg_color.h = hue


func _on_pressed() -> void:
	if lock_status in [LevelLock.STATUS_SOFT_LOCK, LevelLock.STATUS_HARD_LOCK]:
		# level is locked, don't launch the level
		return
	
	if _emit_level_started:
		_emit_level_started = false
		emit_signal("level_started")


func _on_focus_entered() -> void:
	_focus_just_entered = true
	var font: DynamicFont = $Label.get("custom_fonts/font")
	font.outline_color = Color("007a99")


func _on_focus_exited() -> void:
	var font: DynamicFont = $Label.get("custom_fonts/font")
	font.outline_color = Color("6c4331")


func _on_button_down() -> void:
	if _focus_just_entered:
		pass
	else:
		_emit_level_started = true
