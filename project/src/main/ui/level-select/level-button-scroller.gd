class_name LevelButtonScroller
extends Control
## Shows a horizontal strip of level buttons which the player can scroll through.
##
## Shows a promiment 'central button' with several other secondary translucent buttons beside it.

## Emitted when the central button is pressed.
signal central_button_pressed

## Emitted when a new central button is selected, such as when the scroller scrolls left and right.
signal central_button_changed

## Threshold below which the secondary buttons are not interactable.
const INVISIBLE_BUTTON_THRESHOLD := 0.10

export (PackedScene) var LevelSelectButtonScene: PackedScene

var central_button_index: int setget set_central_button_index

## CareerRegion/OtherRegion instance for the _region whose levels should be shown
var _region: Object

var _level_ids: Array

## 'true' if the player has temporarily unlocked all levels with a cheat code
var _unlock_cheat_enabled := false

## key: (String) level id
## value: (LevelSettings) level settings for the level id
var _level_settings_by_id: Dictionary = {}

## Smoothly scrolls the level buttons
var _tween: SceneTreeTween

## true if the central_button_index changed this frame
var _central_button_just_changed := false

## true if the current 'button_down' even corresponds to the central button
var _central_button_down := true

onready var _level_buttons_container: HBoxContainer = $LevelButtons
onready var _grade_labels := $GradeLabels

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		return
	
	if _level_button_has_focus() and event.is_action_pressed("ui_right"):
		# scroll level buttons right, if possible
		if central_button_index < _level_buttons_container.get_child_count() - 1:
			_slide_central_button(central_button_index + 1)
			_central_button().grab_focus()
		if is_inside_tree():
			get_tree().set_input_as_handled()

	if _level_button_has_focus() and event.is_action_pressed("ui_left"):
		# scroll level buttons left, if possible
		if central_button_index > 0:
			_slide_central_button(central_button_index - 1)
			_central_button().grab_focus()
		if is_inside_tree():
			get_tree().set_input_as_handled()


func _process(_delta: float) -> void:
	_central_button_just_changed = false
	
	for button in _level_buttons_container.get_children():
		# Update the button's transparency. The further from the center, the more transparent it is
		var button_relative_position: Vector2 = button.get_global_rect().get_center() - get_global_rect().get_center()
		var alpha := clamp(inverse_lerp(rect_size.x * 0.4, 20, abs(button_relative_position.x)), 0, 1)
		alpha = pow(alpha, 1.3)
		button.modulate = Utils.to_transparent(Color.white, alpha)
		
		# Update the button's focus mode. If it falls below a threshold, it is not interactable.
		if button.modulate.a < INVISIBLE_BUTTON_THRESHOLD and button.get_focus_mode() == FOCUS_CLICK:
			button.set_focus_mode(FOCUS_NONE)
		if button.modulate.a >= INVISIBLE_BUTTON_THRESHOLD and button.get_focus_mode() == FOCUS_NONE:
			button.set_focus_mode(FOCUS_CLICK)


## Populate the scroller with a new set of level buttons.
##
## Parameters:
## 	'new_region': A CareerRegion/OtherRegion instance for the region whose levels should be shown
##
## 	'default_level_id': The level whose button is focused after populating the scroller
func populate(new_region: Object, default_level_id: String = "") -> void:
	_level_ids = []
	_region = new_region
	if _region is CareerRegion:
		for career_level in _region.levels:
			_level_ids.append(career_level.level_id)
		if _region.boss_level and not _region.boss_level.level_id in _level_ids:
			_level_ids.append(_region.boss_level.level_id)
		if _region.intro_level and not _region.intro_level.level_id in _level_ids:
			_level_ids.append(_region.intro_level.level_id)
	else:
		_level_ids.append_array(_region.level_ids)

	_refresh()
	if default_level_id:
		call_deferred("set_central_button_index", _level_ids.find(default_level_id))
	call_deferred("_refresh_central_button_index", false)


func set_central_button_index(new_central_button_index: int) -> void:
	if central_button_index == new_central_button_index:
		return
	
	central_button_index = new_central_button_index
	_central_button_just_changed = true
	_refresh_central_button_index(false)
	emit_signal("central_button_changed")


## Steals the focus from another control and becomes the focused control.
##
## This control itself doesn't have focus, so we delegate to a child control.
func grab_focus() -> void:
	_central_button().grab_focus()


func get_level_settings() -> LevelSettings:
	return _level_settings_by_id[_level_ids[central_button_index]]


func get_lock_status() -> int:
	return _central_button().lock_status


## Refreshes the buttons and arrows based on our current properties.
##
## Removes all buttons and adds new buttons for the current page. Enables/disables the paging arrows, hiding them if
## the player only has access to a single page of levels.
func _refresh() -> void:
	_clear_contents()
	_refresh_level_settings()
	_add_buttons()


## Removes all buttons
func _clear_contents() -> void:
	for child in _level_buttons_container.get_children():
		_level_buttons_container.remove_child(child)
		child.queue_free()


## Loads the level settings and sorts the level ids by their name
func _refresh_level_settings() -> void:
	for level_id in _level_ids:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		GameplayDifficultyAdjustments.adjust_milestones(level_settings)
		_level_settings_by_id[level_id] = level_settings

	# Sort the levels
	if _region is CareerRegion:
		# Career levels aren't in any particular order so we sort them.
		_level_ids.sort_custom(self, "_compare_by_level_name")
	else:
		# Training/tutorial levels are already sorted from easiest to hardest.
		pass


func _compare_by_level_name(a: String, b: String) -> bool:
	return _level_settings_by_id[b].name > _level_settings_by_id[a].name


## Creates and adds the level buttons.
func _add_buttons() -> void:
	if _level_ids.empty():
		# avoid out of bounds errors when there are zero levels
		return

	# create and add the level buttons
	for i in range(_level_ids.size()):
		var new_level_button: LevelSelectButton = _level_select_button(_level_ids[i])
		_grade_labels.add_label(new_level_button)

	# make the first button focusable
	central_button_index = 0
	_central_button_just_changed = true
	_refresh_central_button_index(false)


## Smoothly slides a new button into into the center.
func _slide_central_button(new_central_button_index: int) -> void:
	if central_button_index == new_central_button_index:
		return
	
	central_button_index = new_central_button_index
	_central_button_just_changed = true
	_refresh_central_button_index(true)
	emit_signal("central_button_changed")


## Moves a new button into the center.
##
## Parameters:
## 	'animate': If true, the button smoothly slides into the center.
func _refresh_central_button_index(animate: bool = true) -> void:
	if _level_buttons_container.get_child_count() == 0:
		return
	
	# set appropriate focus_mode for all level select buttons
	for child in _level_buttons_container.get_children():
		child.set_focus_mode(Control.FOCUS_CLICK)
	_central_button().set_focus_mode(Control.FOCUS_ALL)
	
	# move all buttons so the central button appears in the center
	var target_x: float = get_parent().rect_size.x / 2 \
			- _central_button().rect_position.x - _central_button().rect_size.x / 2
	if animate:
		_tween = Utils.recreate_tween(self, _tween)
		_tween.tween_property(_level_buttons_container, "rect_position:x", target_x, 0.4) \
			.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	else:
		_tween = Utils.kill_tween(_tween)
		_level_buttons_container.rect_position.x = target_x


func _central_button() -> LevelSelectButton:
	return _level_buttons_container.get_child(central_button_index) as LevelSelectButton


## Returns 'true' if any level button in this container has focus.
func _level_button_has_focus() -> bool:
	var result := false
	for child in _level_buttons_container.get_children():
		if child.has_focus():
			result = true
			break
	return result


## Adds a new level select button to the scene tree.
##
## Parameters:
## 	'settings': The level settings which control the button's appearance.
func _level_select_button(level_id: String) -> LevelSelectButton:
	var settings: LevelSettings = _level_settings_by_id[level_id]
	var button: LevelSelectButton = LevelSelectButtonScene.instance()
	button.decorate_for_level(_region, settings, _unlock_cheat_enabled)
	button.size_flags_horizontal = 4
	button.size_flags_vertical = 4
	
	button.connect("button_down", self, "_on_LevelSelectButton_button_down")
	button.connect("pressed", self, "_on_LevelSelectButton_pressed", [button])
	button.connect("focus_entered", self, "_on_LevelSelectButton_focus_entered", \
			[_level_buttons_container.get_child_count()])
	_level_buttons_container.add_child(button)

	_grade_labels.add_label(button)
	return button


func _on_LevelSelectButton_focus_entered(button_index: int) -> void:
	_slide_central_button(button_index)


func _on_LevelSelectButton_button_down() -> void:
	if _central_button_just_changed:
		_central_button_down = false


func _on_LevelSelectButton_pressed(button: LevelSelectButton) -> void:
	if button.modulate.a < INVISIBLE_BUTTON_THRESHOLD:
		return
	
	if _central_button_down:
		emit_signal("central_button_pressed")
	_central_button_down = true


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "unlock":
		_unlock_cheat_enabled = !_unlock_cheat_enabled
		detector.play_cheat_sound(_unlock_cheat_enabled)
		var old_level_button_has_focus := _level_button_has_focus()
		
		_refresh()
		call_deferred("set_central_button_index", central_button_index)
		call_deferred("_refresh_central_button_index", false)

		if old_level_button_has_focus:
			call_deferred("grab_focus")
