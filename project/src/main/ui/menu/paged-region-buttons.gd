class_name PagedRegionButtons
extends HBoxContainer
## Creates and arranges region buttons for the region select screen.
##
## These buttons are arranged in multiple pages which can be navigated with arrow buttons.

## Emitted when the player highlights a region to show more information.
signal region_selected(region)

## Emitted when the player 'starts' a region, choosing it for practice.
signal region_started(region)

## Emitted when a new region button is added.
signal button_added(button)

const MAX_REGIONS_PER_PAGE := 7

export (PackedScene) var RegionButtonScene: PackedScene

## Array of CareerRegion and OtherRegion instances to show
var regions: Array setget set_regions

## the current page of regions being shown
var _page := 0

var _regions_by_page := []

## container for new region buttons
onready var _hbox_container := $HBoxContainer

## arrows for paging left and right
onready var _left_arrow := $LeftArrow
onready var _right_arrow := $RightArrow

func _ready() -> void:
	_refresh()


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
		if i == 0 or _regions_by_page.back().size() >= MAX_REGIONS_PER_PAGE:
			_regions_by_page.append([])
		_regions_by_page.back().append(regions[i])
	
	_refresh()


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
	if not _regions_by_page:
		# avoid out of bounds errors when there are zero regions
		return
	
	# create and add the region buttons
	for i in range(_regions_by_page[_page].size()):
		var new_region_button: RegionSelectButton = _region_select_button(
				i, _regions_by_page[_page][i])
		_hbox_container.add_child(new_region_button)
		emit_signal("button_added", new_region_button)


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
## 	'region': region whose button should be created
##
## Returns:
## 	A new orphaned RegionSelectButton instance for the specified region
func _region_select_button(button_index: int, region: CareerRegion) -> RegionSelectButton:
	var region_button: RegionSelectButton = RegionButtonScene.instance()
	region_button.button_index = button_index
	
	region_button.name_text = region.name
	region_button.button_type = Utils.enum_from_snake_case(RegionSelectButton.Type, region.region_button_name)
	
	var ranks := []
	for career_level_obj in region.levels:
		var career_level: CareerLevel = career_level_obj
		var best_result := PlayerData.level_history.best_result(career_level.level_id)
		var rank := best_result.overall_rank() if best_result else RankResult.WORST_RANK
		ranks.append(rank)
	region_button.ranks = ranks
	region_button.completion_percent = PlayerData.career.region_completion(region).completion_percent()
	region_button.disabled = PlayerData.career.is_region_locked(region)
	
	region_button.connect("focus_entered", self, "_on_RegionButton_focus_entered", [region])
	region_button.connect("region_started", self, "_on_RegionButton_region_started", [region])
	return region_button


## When the player clicks a region button once, we emit a signal to show more information.
func _on_RegionButton_focus_entered(region: Object) -> void:
	emit_signal("region_selected", region)


## When the player clicks a region button twice, we emit a signal which chooses the region
func _on_RegionButton_region_started(region: Object) -> void:
	emit_signal("region_started", region)


func _on_LeftArrow_pressed() -> void:
	_page = max(0, _page - 1)
	_refresh()


func _on_RightArrow_pressed() -> void:
	_page = min(_max_selectable_page(), _page + 1)
	_refresh()