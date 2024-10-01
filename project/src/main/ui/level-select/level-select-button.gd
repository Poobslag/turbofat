class_name LevelSelectButton
extends Control
## Button on the level select screen which launches a level.
##
## The button adjusts its rect_min_size based on level duration.

## emitted when the button is pressed, if the level is not locked.
signal level_chosen

## emitted when the button is pressed.
signal pressed

## emitted when the button starts being held down.
signal button_down

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

const MAX_ICON_COUNT := 5

const STATUS_NONE := LockStatus.NONE
const STATUS_KEY := LockStatus.KEY
const STATUS_CROWN := LockStatus.CROWN
const STATUS_CLEARED := LockStatus.CLEARED
const STATUS_LOCKED := LockStatus.LOCKED

const SHORT := LevelSize.SHORT
const MEDIUM := LevelSize.MEDIUM
const LONG := LevelSize.LONG

var level_id: String

## Enum from LevelSize for the duration of the level. This affects the button size
var level_duration: int = LevelSize.MEDIUM setget set_level_duration

## status whether or not this level is locked/unlocked
var lock_status: int = STATUS_NONE setget set_lock_status

## number of remaining levels the player needs to play to unlock this level
var keys_needed := -1 setget set_keys_needed

var level_name: String setget set_level_name

var level_icons := [] setget set_level_icons

## Button's background color. If omitted, the button will use a pseudo-random background color based on its id
var bg_color: Color setget set_bg_color

## 'true' if this button just received focus this frame. A mouse click which grants focus doesn't emit a 'level
## started' event
var _focus_just_entered := false

## 'true' if the 'level started' signal should be emitted in response to a button click.
var _emit_level_chosen := false

onready var _label := $ButtonControlHolder/ButtonControl/Label
onready var _icon_tile_map := $ButtonControlHolder/ButtonControl/IconTileMapHolder/IconTileMap

onready var button_control := $ButtonControlHolder/ButtonControl

func _ready() -> void:
	button_control.text = ""
	button_control.rect_size = rect_size
	refresh_size()
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


func set_level_icons(new_level_icons: Array) -> void:
	level_icons = new_level_icons
	_refresh_appearance()


## Updates the button's fields based on the specified level.
##
## Specifically, this updates the level_id, level_name, lock_status, duration and bg_color fields.
func decorate_for_level(region: Object, settings: LevelSettings, force_unlock: bool = false) -> void:
	level_id = settings.id
	level_name = settings.name

	# calculate the lock status
	lock_status = STATUS_NONE
	
	# lock unplayed/unreached career levels
	var is_boss_level: bool = region is CareerRegion and region.boss_level \
			and region.boss_level.level_id == settings.id
	if not force_unlock and region is CareerRegion:
		if is_boss_level and not PlayerData.level_history.has_result(settings.id) \
				and not PlayerData.career.is_region_finished(region):
			# boss levels are locked if the player hasn't gotten past them and hasn't played them
			lock_status = STATUS_LOCKED
		if not is_boss_level and not PlayerData.level_history.has_result(settings.id):
			# career levels are locked if the player hasn't played them
			lock_status = STATUS_LOCKED
	
	# assign cleared/crown status for completed levels
	if lock_status == STATUS_NONE:
		if region.id == OtherRegion.ID_TUTORIAL:
			# tutorial levels show a checkmark if completed
			if PlayerData.level_history.is_level_finished(settings.id):
				lock_status = STATUS_CLEARED
		elif region is OtherRegion and region.id in [OtherRegion.ID_RANK, OtherRegion.ID_MARATHON]:
			# rank/marathon levels show a crown if completed
			if PlayerData.level_history.is_level_success(settings.id):
				lock_status = STATUS_CROWN
	
	if settings.rank.duration < 100:
		level_duration = SHORT
	elif settings.rank.duration < 200:
		level_duration = MEDIUM
	else:
		level_duration = LONG
	
	# calculate the background color. this is usually random, but for rank mode we use specific colors
	if settings.color_string:
		match settings.color_string:
			"red": set_bg_color(BUTTON_COLOR_RED)
			"orange": set_bg_color(BUTTON_COLOR_ORANGE)
			"yellow": set_bg_color(BUTTON_COLOR_YELLOW)
			"green": set_bg_color(BUTTON_COLOR_GREEN)
			"blue": set_bg_color(BUTTON_COLOR_BLUE)
			"purple": set_bg_color(BUTTON_COLOR_PURPLE)
			_:
				push_warning("Unrecognized color string '%s'" % [settings.color_string])

	level_icons = settings.icons


## Updates the button's style colors. Can be overridden by child buttons who use different styles.
func refresh_style_color(color: Color) -> void:
	if not is_inside_tree():
		return
	
	button_control.get("custom_styles/normal").bg_color = color
	button_control.get("custom_styles/hover").bg_color = color


## Returns true if this button is currently focused.
##
## For cosmetic reasons, this control itself doesn't have focus, but the child button control does.
func has_focus() -> bool:
	return button_control.has_focus()


## Steals the focus from another control and becomes the focused control.
##
## For cosmetic reasons, this control itself doesn't have focus, but the child button control does.
func grab_focus() -> void:
	button_control.grab_focus()


## Assigns the focus access mode for the control (None, Click or All).
##
## For cosmetic reasons, this control itself doesn't have a focus mode, but the child button control does.
func set_focus_mode(new_button_focus_mode: int) -> void:
	button_control.focus_mode = new_button_focus_mode


## Returns the focus access mode for the control (None, Click or All).
##
## For cosmetic reasons, this control itself doesn't have a focus mode, but the child button control does.
func get_focus_mode() -> int:
	return button_control.focus_mode


func refresh_size() -> void:
	if not button_control:
		return
	
	button_control.rect_size = rect_size


## Updates the button's text, colors, size and icon based on the level and its status.
func _refresh_appearance() -> void:
	if not is_inside_tree():
		return
	
	match level_duration:
		LevelSize.SHORT: rect_min_size.y = 80
		LevelSize.MEDIUM: rect_min_size.y = 100
		LevelSize.LONG: rect_min_size.y = 120
	
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
	
	_icon_tile_map.clear()
	for i in range(min(level_icons.size(), MAX_ICON_COUNT)):
		var level_icon_autotile_coord := Vector2(level_icons[i] % 8, floor(level_icons[i] / 8))
		_icon_tile_map.set_cell(-i, 0, 0, false, false, false, level_icon_autotile_coord)


func _on_resized() -> void:
	refresh_size()


func _on_ButtonControl_pressed() -> void:
	emit_signal("pressed")
	
	if lock_status != STATUS_LOCKED and _emit_level_chosen:
		_emit_level_chosen = false
		emit_signal("level_chosen")


func _on_ButtonControl_focus_entered() -> void:
	_focus_just_entered = true
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = Color("007a99")
	_icon_tile_map.material.set("shader_param/black", font.outline_color)
	
	# Propagate the focus_entered signal. This control cannot be focused, but other scenes such as the career map and
	# level select screen need to react to our focus events
	emit_signal("focus_entered")


func _on_ButtonControl_focus_exited() -> void:
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = Color("6c4331")
	_icon_tile_map.material.set("shader_param/black", font.outline_color)


func _on_ButtonControl_button_down() -> void:
	emit_signal("button_down")
	
	if _focus_just_entered:
		pass
	else:
		_emit_level_chosen = true
