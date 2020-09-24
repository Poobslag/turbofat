class_name LevelSelectButton
extends Button
"""
A button on the level select screen which launches a scenario.
"""

# emitted when a scenario is launched.
signal scenario_started

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

# the duration of the level; this affects the button size
var level_duration: int = LevelSize.MEDIUM setget set_level_duration

# the width of the column this button is in
var level_column_width: int = 120

# the status whether or not this level is locked/unlocked
var lock_status: int = LevelLock.STATUS_NONE setget set_lock_status

# the number of remaining levels the player needs to play to unlock this level
var keys_needed := -1 setget set_keys_needed

var level_title: String setget set_level_title

# 'true' if this button just received focus this frame. a mouse click which grants focus doesn't emit a 'scenario
# started' event
var _focus_just_entered := false

# 'true' if the 'scenario started' signal should be emitted in response to a button click.
var _emit_scenario_started := false

var _key_texture: Texture = preload("res://assets/main/ui/level-select/key.png")
var _locked_texture: Texture = preload("res://assets/main/ui/level-select/locked.png")
var _unlockable_texture: Texture = preload("res://assets/main/ui/level-select/unlockable.png")

func _ready() -> void:
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


"""
Updates the button's text, colors, size and icon based on the level and its status.
"""
func _refresh_appearance() -> void:
	match level_duration:
		LevelSize.SHORT: rect_min_size.y = level_column_width * 0.5
		LevelSize.MEDIUM: rect_min_size.y = level_column_width * 0.75 + VERTICAL_SPACING * 0.5
		LevelSize.LONG: rect_min_size.y = level_column_width + VERTICAL_SPACING
	
	text = level_title if level_title else "-"
	
	match lock_status:
		LevelLock.STATUS_NONE:
			icon = null
			set("custom_colors/font_color", null)
			text = "%s" % text
		LevelLock.STATUS_KEY:
			icon = _key_texture
			set("custom_colors/font_color", Color("36d936"))
			text = "%s" % text
		LevelLock.STATUS_SOFT_LOCK:
			icon = _unlockable_texture
			set("custom_colors/font_color", Color("d9be36"))
			text = "(%s)" % text
		LevelLock.STATUS_HARD_LOCK:
			icon = _locked_texture
			set("custom_colors/font_color", Color("d93636"))
			text = "(???)"


func _on_pressed() -> void:
	if lock_status in [LevelLock.STATUS_SOFT_LOCK, LevelLock.STATUS_HARD_LOCK]:
		# level is locked, don't launch the scenario
		return
	
	if _emit_scenario_started:
		_emit_scenario_started = false
		emit_signal("scenario_started")


func _on_focus_entered() -> void:
	_focus_just_entered = true


func _on_button_down() -> void:
	if _focus_just_entered:
		pass
	else:
		_emit_scenario_started = true
