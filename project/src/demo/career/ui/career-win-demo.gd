extends Node
## Demonstrates different Career Win screens.
##
## Keys:
## 	[-/=]: Select the previous/next career region

export (PackedScene) var CareerWinScene: PackedScene

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_EQUAL:
			var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
			var next_region := CareerLevelLibrary.region_for_distance(region.start + region.length)
			PlayerData.career.distance_travelled = next_region.start
			_refresh_career_win()
		KEY_MINUS:
			var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
			var prev_region := CareerLevelLibrary.region_for_distance(region.start - 1)
			PlayerData.career.distance_travelled = prev_region.start
			_refresh_career_win()


## Refreshes the CareerWin node so that it reflects the current career data.
func _refresh_career_win() -> void:
	remove_child($CareerWin)
	var career_win := CareerWinScene.instance()
	career_win.name = "CareerWin"
	add_child(career_win)
