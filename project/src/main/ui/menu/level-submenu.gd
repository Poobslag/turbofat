extends Control
## A level select screen which shows buttons and level info. Used in the practice menu.

## Emitted when the player 'starts' a level, choosing it for practice.
##
## Parameters:
## 	'region': A CareerRegion or OtherRegion instance for the chosen region.
##
## 	'level_id': The chosen level id
signal level_chosen(region, level_id)

export (NodePath) var level_buttons_path: NodePath

## A CareerRegion/OtherRegion instance for the region whose levels should be shown
var _region: Object

onready var _level_buttons: PagedLevelButtons = get_node(level_buttons_path)

## Populates this submenu with levels and shows it to the player.
##
## We create a button for each level defined in the region. If the player has selected a level before, we focus the
## level they previously chose.
##
## Parameters:
## 	'new_region': A CareerRegion/OtherRegion instance for the region whose levels should be shown
##
## 	'default_level_id': The level whose button is focused after showing the menu
func popup(new_region: Object, default_level_id: String = "") -> void:
	var level_ids := []
	_region = new_region
	if _region is CareerRegion:
		for career_level in _region.levels:
			level_ids.append(career_level.level_id)
	else:
		level_ids.append_array(_region.level_ids)
	
	_level_buttons.region = _region
	_level_buttons.level_ids = level_ids
	if default_level_id:
		_level_buttons.focus_level(default_level_id)
	show()


func _on_LevelButtons_level_chosen(settings: LevelSettings) -> void:
	emit_signal("level_chosen", _region, settings)


func _on_BackButton_pressed() -> void:
	hide()
