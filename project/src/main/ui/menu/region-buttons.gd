extends HBoxContainer
## Creates and arranges region buttons for the region select screen.

## Emitted when the player highlights a region to show more information.
signal region_selected(region)

## Emitted when a new region button is added.
signal button_added(button)

const REGIONS_PER_PAGE := 7

export (PackedScene) var RegionButtonScene: PackedScene

## the current page of regions being shown
var _page := 0

## container for new region buttons
onready var _hbox_container := $HBoxContainer

## arrows for paging left and right
onready var _left_arrow := $LeftArrow
onready var _right_arrow := $RightArrow

func _ready() -> void:
	# warning-ignore:integer_division
	_page = _max_selectable_page()
	
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
	# determine how many buttons should be shown
	var min_shown_region := clamp(_page * REGIONS_PER_PAGE,
			0, CareerLevelLibrary.regions.size() - 1)
	var max_shown_region := clamp(_page * REGIONS_PER_PAGE + REGIONS_PER_PAGE - 1,
			0, CareerLevelLibrary.regions.size() - 1)
	
	# create and add the region buttons
	var last_region_button: RegionSelectButton
	for i in range(min_shown_region, max_shown_region + 1):
		var new_region_button: RegionSelectButton = _region_select_button(
				i - min_shown_region, CareerLevelLibrary.regions[i])
		if not new_region_button.disabled:
			last_region_button = new_region_button
		_hbox_container.add_child(new_region_button)
		emit_signal("button_added", new_region_button)
	
	if last_region_button:
		last_region_button.grab_focus()


## Enables/disables the paging arrows, hiding them if the player only has access to a single page of regions.
func _refresh_arrows() -> void:
	_left_arrow.disabled = _page == 0
	_right_arrow.disabled = _page == _max_selectable_page()
	
	if _max_selectable_page() == 0:
		_left_arrow.visible = false
		_right_arrow.visible = false


## Calculates the highest page the player can select.
func _max_selectable_page() -> int:
	var max_selectable_region_index := 0
	for i in range(CareerLevelLibrary.regions.size()):
		if not PlayerData.career.is_region_locked(CareerLevelLibrary.regions[i]):
			max_selectable_region_index = i
	return max_selectable_region_index / REGIONS_PER_PAGE


## Creates a region select button for the specified region.
func _region_select_button(button_index: int, region: CareerRegion) -> Node:
	var region_button: RegionSelectButton = RegionButtonScene.instance()
	region_button.button_index = button_index
	region_button.name_text = region.name
	region_button.button_type = Utils.enum_from_snake_case(RegionSelectButton.Type, region.region_button_name)
	
	var ranks := []
	for career_level_obj in region.levels:
		var career_level: CareerLevel = career_level_obj
		var best_result := PlayerData.level_history.best_result(career_level.level_id)
		var rank := RankResult.WORST_RANK
		if best_result:
			rank = best_result.seconds_rank if best_result.compare == "-seconds" else best_result.score_rank
		ranks.append(rank)
	region_button.ranks = ranks
	region_button.completion_percent = PlayerData.career.region_completion(region).completion_percent()
	
	region_button.connect("focus_entered", self, "_on_RegionButton_focus_entered", [region])
	region_button.connect("region_started", self, "_on_RegionButton_region_started", [region])
	region_button.disabled = PlayerData.career.is_region_locked(region)
	return region_button


## When the player clicks a region button once, we emit a signal to show more information.
func _on_RegionButton_focus_entered(region: CareerRegion) -> void:
	emit_signal("region_selected", region)


## When the player clicks a region button twice, we launch career mode
func _on_RegionButton_region_started(region: CareerRegion) -> void:
	PlayerData.career.distance_travelled = region.start
	PlayerData.career.remain_in_region = region.end < PlayerData.career.max_distance_travelled
	
	if Breadcrumb.trail.front() == Global.SCENE_CAREER_REGION_SELECT_MENU:
		Breadcrumb.trail.pop_front()
	Breadcrumb.trail.push_front(Global.SCENE_CAREER_MAP)
	PlayerData.career.push_career_trail()


func _on_LeftArrow_pressed() -> void:
	_page = max(0, _page - 1)
	_refresh()


func _on_RightArrow_pressed() -> void:
	_page = min(_max_selectable_page(), _page + 1)
	_refresh()
