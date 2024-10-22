class_name UniqueLevelAchievement
extends SteamAchievement
## Unlocks an achievement when a condition is met during a specific level.
##
## This script is specifically extended by achievements which cannot rely on save data, and which must check for a
## condition while the level is still being played.
##
## For achievements such as "reach this score" or "reach this rank", we can check the player's save data because we
## always save their best score or best rank. However for arbitrary achievements like "Have six carrots visible on a
## level" or "Earn ¥500 from your first customer" we can't check the save data, either because the data isn't saved or
## because it can be erased by a higher score which doesn't reach that arbitrary milestone.

## The level ID whose achievement condition should be checked.
export (String) var level_id: String

## 'true' if the prepare_level_listeners() method has already been called
var _prepared_level_listeners := false

func connect_signals() -> void:
	.connect_signals()
	disconnect_save_signal()
	disconnect_load_signal()
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	Breadcrumb.connect("before_scene_changed", self, "_on_Breadcrumb_before_scene_changed")


## Overridden by child classes to connect listeners to the Puzzle or PuzzleState.
func prepare_level_listeners() -> void:
	pass


## Overridden by child classes to disconnect listeners from the Puzzle or PuzzleState.
func remove_level_listeners() -> void:
	pass


func _on_PuzzleState_game_prepared() -> void:
	if get_tree().current_scene is Puzzle \
			and CurrentLevel.level_id == level_id \
			and not _prepared_level_listeners:
		prepare_level_listeners()
		_prepared_level_listeners = true


func _on_Breadcrumb_before_scene_changed() -> void:
	if _prepared_level_listeners:
		remove_level_listeners()
		_prepared_level_listeners = false
