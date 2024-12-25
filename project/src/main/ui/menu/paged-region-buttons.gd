class_name PagedRegionButtons
extends HBoxContainer
## Creates and arranges region buttons for the region select screen.
##
## These buttons are arranged in multiple pages which can be navigated with arrow buttons.

## Emitted when the player highlights a locked region to show more information.
signal locked_region_focused(region)

## Emitted when the player highlights an unlocked region to show more information.
signal unlocked_region_focused(region)

## Emitted when the player finishes choosing a region to play.
signal region_chosen(region)

## Emitted when a new region button is added.
signal button_added(button)

const MAX_REGIONS_PER_PAGE := 7

export (PackedScene) var RegionButtonScene: PackedScene

## Array of CareerRegion and OtherRegion instances to show
var regions: Array setget set_regions

## current page of regions being shown
var _page := 0

var _regions_by_page := []

## 'true' if the player has temporarily unlocked all regions with a cheat code
var _unlock_cheat_enabled := false

## container for new region buttons
onready var _hbox_container := $HBoxContainer

## arrows for paging left and right
onready var _left_arrow := $LeftArrow
onready var _right_arrow := $RightArrow

func _ready() -> void:
	_refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		return
	
	if _rightmost_region_button_has_focus() and event.is_action_pressed("ui_right"):
		if _page < _max_selectable_page():
			_select_next_page()
		if is_inside_tree():
			get_tree().set_input_as_handled()

	if _leftmost_region_button_has_focus() and event.is_action_pressed("ui_left"):
		if _page > 0:
			_select_previous_page()
		if is_inside_tree():
			get_tree().set_input_as_handled()


## Focuses a specific region button, possibly changing the current page.
##
## Parameters:
## 	'region_id_to_focus': the region whose button should be focused
func focus_region(region_id_to_focus: String) -> void:
	var page_to_focus := -1
	var button_index_to_focus := -1
	for next_page in range(_regions_by_page.size()):
		for next_region_index in range(_regions_by_page[next_page].size()):
			var next_region: Object = _regions_by_page[next_page][next_region_index]
			if next_region.id == region_id_to_focus:
				page_to_focus = next_page
				button_index_to_focus = next_region_index
				break
	
	if page_to_focus != -1 and button_index_to_focus != -1:
		if _page != page_to_focus:
			_page = page_to_focus
			_refresh()
		_hbox_container.get_children()[button_index_to_focus].grab_focus()


func set_regions(new_regions: Array) -> void:
	regions = new_regions
	
	# populate _regions_by_page
	_regions_by_page.clear()
	for i in range(regions.size()):
		var same_group := true
		if i == 0:
			same_group = false
		elif regions[i] is CareerRegion and regions[i - 1] is CareerRegion:
			if regions[i].has_flag(CareerRegion.FLAG_NEW_PAGE):
				same_group = false
		elif regions[i] is OtherRegion and regions[i - 1] is OtherRegion:
			var curr_region_is_tutorial: bool = regions[i].id == OtherRegion.ID_TUTORIAL
			var prev_region_is_tutorial: bool = regions[i - 1].id == OtherRegion.ID_TUTORIAL
			if curr_region_is_tutorial != prev_region_is_tutorial:
				same_group = false
		else:
			same_group = false
		
		if not same_group or _regions_by_page.back().size() >= MAX_REGIONS_PER_PAGE:
			_regions_by_page.append([])
		_regions_by_page.back().append(regions[i])
	
	_refresh()


func _rightmost_region_button_has_focus() -> bool:
	if not _hbox_container.get_children():
		return false
	return _hbox_container.get_children().back().has_focus()


func _leftmost_region_button_has_focus() -> bool:
	if not _hbox_container.get_children():
		return false
	return _hbox_container.get_children().front().has_focus()


## Refreshes the buttons and arrows based on our current properties.
##
## Removes all buttons and adds new buttons for the current page. Enables/disables the paging arrows, hiding them if
## the player only has access to a single page of regions.
func _refresh() -> void:
	_clear_contents()
	_add_buttons()
	_refresh_arrows()


## Removes all buttons/placeholders in preparation for loading a new set of region buttons.
func _clear_contents() -> void:
	for child in _hbox_container.get_children():
		_hbox_container.remove_child(child)
		child.queue_free()


## Adds buttons representing regions the player can choose.
func _add_buttons() -> void:
	if _regions_by_page.empty():
		# avoid out of bounds errors when there are zero regions
		return
	
	# create and add the region buttons
	for i in range(_regions_by_page[_page].size()):
		var new_region_button: RegionSelectButton = _region_select_button(i, _regions_by_page[_page][i])
		_hbox_container.add_child(new_region_button)
		emit_signal("button_added", new_region_button)
	
	# assing default focus to the first button
	if _hbox_container.get_child_count():
		_hbox_container.get_children().front().grab_focus()


## Enables/disables the paging arrows, hiding them if the player only has access to a single page of regions.
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
	return _regions_by_page.size() - 1


## Creates a region select button for the specified region.
##
## Parameters:
## 	'button_index': The index of the button for the current page, 0 being the leftmost button on the page. Used for
## 		layout purposes, the buttons follow a vertical zigzag pattern.
##
## 	'region_obj': CareerRegion or OtherRegion instance whose button should be created
##
## Returns:
## 	A new orphaned RegionSelectButton instance for the specified region
func _region_select_button(button_index: int, region_obj: Object) -> RegionSelectButton:
	var region_button: RegionSelectButton = RegionButtonScene.instance()
	region_button.button_index = button_index
	
	if region_obj is CareerRegion:
		var region: CareerRegion = region_obj
		region_button.region_name = PlayerData.career.obfuscated_region_name(region)
		region_button.button_type = Utils.enum_from_snake_case(RegionSelectButton.Type, region.region_button_id)
		
		var ranks := []
		for career_level_obj in region.levels:
			var career_level: CareerLevel = career_level_obj
			var rank := PlayerData.level_history.best_overall_rank(career_level.level_id)
			ranks.append(rank)
		region_button.ranks = ranks
		region_button.completion_percent = PlayerData.career.region_completion(region).completion_percent()
		region_button.disabled = PlayerData.career.is_region_locked(region) and not _unlock_cheat_enabled
	else:
		var region: OtherRegion = region_obj
		
		var level_completion := 0
		var potential_completion := region.level_ids.size()
		var ranks := []
		for level_id in region.level_ids:
			if region.id in [OtherRegion.ID_RANK, OtherRegion.ID_MARATHON]:
				if PlayerData.level_history.is_level_success(level_id):
					level_completion += 1
			elif PlayerData.level_history.is_level_finished(level_id):
				level_completion += 1
			ranks.append(PlayerData.level_history.best_overall_rank(level_id))
		region_button.ranks = ranks
		region_button.completion_percent = level_completion / float(potential_completion)
		region_button.region_name = region.name
		region_button.button_type = Utils.enum_from_snake_case(RegionSelectButton.Type, region.region_button_id)
	
	region_button.connect("focus_entered", self, "_on_RegionButton_focus_entered", [region_button, region_obj])
	region_button.connect("region_chosen", self, "_on_RegionButton_region_chosen", [region_obj])
	return region_button


func _select_previous_page() -> void:
	_page = max(0, _page - 1)
	_refresh()
	_hbox_container.get_children().back().grab_focus()


func _select_next_page() -> void:
	_page = min(_max_selectable_page(), _page + 1)
	_refresh()
	_hbox_container.get_children().front().grab_focus()


## When the player clicks a region button once, we emit a signal to show more information.
func _on_RegionButton_focus_entered(region_button: RegionSelectButton, region: Object) -> void:
	if region_button.disabled:
		emit_signal("locked_region_focused", region)
	else:
		emit_signal("unlocked_region_focused", region)


## When the player clicks a region button twice, we emit a signal which chooses the region
func _on_RegionButton_region_chosen(region: Object) -> void:
	emit_signal("region_chosen", region)


func _on_LeftArrow_pressed() -> void:
	_select_previous_page()


func _on_RightArrow_pressed() -> void:
	_select_next_page()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "unlock":
		_unlock_cheat_enabled = !_unlock_cheat_enabled
		detector.play_cheat_sound(_unlock_cheat_enabled)
		var button_index_to_focus := -1
		if get_focus_owner() in _hbox_container.get_children():
			button_index_to_focus = get_focus_owner().get_index()
		_refresh()
		if button_index_to_focus != -1:
			if is_inside_tree():
				yield(get_tree(), "idle_frame")
			_hbox_container.get_children()[button_index_to_focus].grab_focus()
