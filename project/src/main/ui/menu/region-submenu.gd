extends Control
## Region select screen which shows buttons and region info. Used in the practice menu.

## Emitted when the player finishes choosing a region to play.
##
## Parameters:
## 	'region': A CareerRegion or OtherRegion instance for the chosen region.
signal region_chosen(region)

export (NodePath) var region_buttons_path: NodePath

onready var _region_buttons: PagedRegionButtons = get_node(region_buttons_path)

## Shows the region submenu.
##
## Parameters:
## 	'default_region_id': The region whose button should be focused
func popup(default_region_id: String) -> void:
	var regions := []
	for region_obj in OtherLevelLibrary.regions:
		var region: OtherRegion = region_obj
		if region.id == OtherRegion.ID_TUTORIAL:
			# don't include tutorials, those are on the main menu
			pass
		else:
			regions.append(region)
	regions.append_array(CareerLevelLibrary.regions)
	_region_buttons.regions = regions
	if default_region_id:
		_region_buttons.focus_region(default_region_id)
	show()


func _on_Panel_region_chosen(region: Object) -> void:
	emit_signal("region_chosen", region)


func _on_BackButton_pressed() -> void:
	hide()
