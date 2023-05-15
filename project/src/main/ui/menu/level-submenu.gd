extends Control
## Level select screen which shows buttons and level info. Used in the practice menu.

## Emitted when the player finishes choosing a level to play.
##
## Parameters:
## 	'region': A CareerRegion or OtherRegion instance for the chosen region.
##
## 	'level_id': The chosen level id
signal level_chosen(region, settings)

## CareerRegion/OtherRegion instance for the region whose levels should be shown
var _region: Object

onready var _paged_level_panel := $Panel

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
	_region = new_region
	_paged_level_panel.populate(new_region, default_level_id)
	show()


func disable_cheat_sfx() -> void:
	_paged_level_panel.disable_cheat_sfx()


func _on_Panel_level_chosen(settings: LevelSettings) -> void:
	emit_signal("level_chosen", _region, settings)


func _on_BackButton_pressed() -> void:
	hide()
