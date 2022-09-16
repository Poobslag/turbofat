class_name PagedLevelButtons
extends HBoxContainer
## Creates and arranges level buttons for the level select screen.
##
## These buttons are arranged in multiple pages which can be navigated with arrow buttons.

const MAX_LEVELS_PER_PAGE := 18

## Emitted when the player 'starts' a level, choosing it for practice.
signal level_chosen(settings)

## Emitted when the player highlights a locked level to show more information.
signal locked_level_chosen(settings)

## Emitted when the player highlights an unlocked level to show more information.
signal unlocked_level_chosen(settings)

## Emitted when a new level button is added.
signal button_added(button)

export (PackedScene) var LevelButtonScene: PackedScene

## A CareerRegion or OtherRegion instance whose levels are being shown
var region: Object setget set_region

var level_ids: Array setget set_level_ids

## the current page of buttons being shown
var _page := 0

## key: (String) level id
## value: (LevelSettings) level settings for the level id
var _level_settings_by_id: Dictionary = {}

## container for new level buttons
onready var _grid_container := $GridContainer

## arrows for paging left and right
onready var _left_arrow := $LeftArrow
onready var _right_arrow := $RightArrow

func _ready() -> void:
	_refresh()


## Focuses a specific level button, possibly changing the current page.
##
## Parameters:
## 	'level_id_to_focus': level whose button should be focused
func focus_level(level_id_to_focus: String) -> void:
	var page_to_focus := -1
	var button_index_to_focus := -1
	
	if level_ids.has(level_id_to_focus):
		# warning-ignore:integer_division
		page_to_focus = level_ids.find(level_id_to_focus) / MAX_LEVELS_PER_PAGE
		button_index_to_focus = level_ids.find(level_id_to_focus) % MAX_LEVELS_PER_PAGE
	
	if page_to_focus != -1 and button_index_to_focus != -1:
		if _page != page_to_focus:
			_page = page_to_focus
			_refresh()
		_grid_container.get_children()[button_index_to_focus].grab_focus()


func set_region(new_region: Object) -> void:
	region = new_region
	_refresh()


func set_level_ids(new_level_ids: Array) -> void:
	level_ids = new_level_ids
	_page = clamp(_page, 0, _max_selectable_page())
	_refresh()


## Refreshes the buttons and arrows based on our current properties.
##
## Removes all buttons and adds new buttons for the current page. Enables/disables the paging arrows, hiding them if
## the player only has access to a single page of levels.
func _refresh() -> void:
	_clear_contents()
	_refresh_level_settings()
	_add_buttons()
	_refresh_arrows()


## Adds buttons representing levels the player can choose.
func _add_buttons() -> void:
	if not level_ids:
		# avoid out of bounds errors when there are zero levels
		return
	
	# determine how many buttons should be shown
	var min_shown_level: int = clamp(_page * MAX_LEVELS_PER_PAGE,
			0, level_ids.size() - 1)
	var max_shown_level: int = clamp(_page * MAX_LEVELS_PER_PAGE + MAX_LEVELS_PER_PAGE - 1,
			0, level_ids.size() - 1)
	
	# create and add the level buttons
	for i in range(min_shown_level, max_shown_level + 1):
		var new_level_button: LevelSelectButton = _level_select_button(
				level_ids[i], max_shown_level - min_shown_level + 1)
		
		_grid_container.add_child(new_level_button)
		emit_signal("button_added", new_level_button)
	
	# assign default focus to the first button
	if _grid_container.get_child_count():
		_grid_container.get_children().front().grab_focus()


## Removes all buttons/placeholders in preparation for loading a new set of level buttons.
func _clear_contents() -> void:
	for child in _grid_container.get_children():
		_grid_container.remove_child(child)
		child.queue_free()


## Loads the level settings and sorts the level ids by their name
func _refresh_level_settings() -> void:
	for level_id in level_ids:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		_level_settings_by_id[level_id] = level_settings
	
	# Sort the levels
	if region is CareerRegion:
		# Career levels aren't in any particular order so we sort them.
		level_ids.sort_custom(self, "_compare_by_level_name")
	else:
		# Training/tutorial levels are already sorted from easiest to hardest.
		pass


func _compare_by_level_name(a: String, b: String) -> bool:
	return _level_settings_by_id[b].name > _level_settings_by_id[a].name


## Enables/disables the paging arrows, hiding them if the player only has access to a single page of levels.
func _refresh_arrows() -> void:
	_left_arrow.disabled = _page == 0
	_right_arrow.disabled = _page == _max_selectable_page()
	
	if _max_selectable_page() == 0:
		_left_arrow.visible = false
		_right_arrow.visible = false
	else:
		_left_arrow.visible = true
		_right_arrow.visible = true


## Calculates the highest page the player can select.
func _max_selectable_page() -> int:
	# warning-ignore:integer_division
	return (level_ids.size() - 1) / MAX_LEVELS_PER_PAGE


## Creates a level select button for the specified level.
##
## Parameters:
## 	'level_id': The level whose button will be created
##
## 	'level_count': The number of levels which will be shown on the current page. If there are fewer levels, we make
## 		the buttons bigger.##
##
## Returns:
## 	A new orphaned LevelSelectButton instance for the specified level
func _level_select_button(level_id: String, level_count: int) -> Node:
	var level_settings: LevelSettings = _level_settings_by_id[level_id]
	
	var level_button: LevelSelectButton = LevelButtonScene.instance()
	level_button.level_id = level_id
	level_button.level_duration = LevelSelectButton.MEDIUM if level_count >= 10 else LevelSelectButton.LONG
	level_button.level_name = level_settings.name
	
	# calculate the lock status
	level_button.lock_status = LevelSelectButton.STATUS_NONE
	if region is CareerRegion and not PlayerData.level_history.has_result(level_id):
		# career levels are locked if the player hasn't played them
		level_button.lock_status = LevelSelectButton.STATUS_LOCKED
	elif region.id == OtherRegion.ID_TUTORIAL:
		# tutorial levels show a checkmark if completed
		if PlayerData.level_history.is_level_finished(level_id):
			level_button.lock_status = LevelSelectButton.STATUS_CLEARED
	elif region is OtherRegion and region.id in [OtherRegion.ID_RANK, OtherRegion.ID_MARATHON]:
		# rank/marathon levels show a crown if completed
		if PlayerData.level_history.is_level_success(level_id):
			level_button.lock_status = LevelSelectButton.STATUS_CROWN
	
	# calculate the background color. this is usually random, but for rank mode we use specific colors
	if region is OtherRegion and region.id == OtherRegion.ID_RANK:
		match level_id:
			"rank/7k", "rank/6k", "rank/5k", "rank/4k", "rank/3k", "rank/2k", "rank/1k":
				level_button.set_bg_color(LevelSelectButton.BUTTON_COLOR_BLUE)
			"rank/1d", "rank/2d", "rank/3d", "rank/4d", "rank/5d":
				level_button.set_bg_color(LevelSelectButton.BUTTON_COLOR_GREEN)
			"rank/6d", "rank/7d", "rank/8d":
				level_button.set_bg_color(LevelSelectButton.BUTTON_COLOR_YELLOW)
			"rank/9d", "rank/10d":
				level_button.set_bg_color(LevelSelectButton.BUTTON_COLOR_ORANGE)
			"rank/m":
				level_button.set_bg_color(LevelSelectButton.BUTTON_COLOR_RED)
	
	level_button.connect("focus_entered", self, "_on_LevelButton_focus_entered", [level_button, level_id])
	level_button.connect("level_chosen", self, "_on_LevelButton_level_chosen", [level_settings])
	return level_button


## When the player clicks a level button once, we emit a signal to show more information.
func _on_LevelButton_focus_entered(level_button: LevelSelectButton, level_id: String) -> void:
	if level_button.lock_status == LevelSelectButton.STATUS_LOCKED:
		emit_signal("locked_level_chosen", _level_settings_by_id[level_id])
	else:
		emit_signal("unlocked_level_chosen", _level_settings_by_id[level_id])


## When the player clicks a level button twice, we emit a signal which chooses the level
func _on_LevelButton_level_chosen(level_settings: LevelSettings) -> void:
	emit_signal("level_chosen", level_settings)


func _on_LeftArrow_pressed() -> void:
	_page = max(0, _page - 1)
	_refresh()


func _on_RightArrow_pressed() -> void:
	_page = min(_max_selectable_page(), _page + 1)
	_refresh()
