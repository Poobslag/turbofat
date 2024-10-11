extends Control
## Receipt shown at the start of most levels which summarizes the level and the player's goal.
##
## The summary includes a title such as '15-Line Marathon' and a brief goal such as 'Earn ¥25 with 15 lines for rank
## A!'

var _popped_out := false

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("game_started", self, "_on_PuzzleState_game_started")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	
	_refresh()


## Makes the receipt visible/invisible based on the level settings.
##
## The receipt is invisible for tutorials, or if the level has already started.
func _refresh() -> void:
	visible = not CurrentLevel.is_tutorial() and not CurrentLevel.settings.other.after_tutorial and not _popped_out


## Makes the receipt disappear.
##
## Animating the receipt disappearing seems unnecessary and distracting, so it is not currently animated.
func _pop_out() -> void:
	_popped_out = true
	visible = false


func _on_PuzzleState_game_prepared() -> void:
	_pop_out()


func _on_PuzzleState_game_started() -> void:
	_pop_out()


func _on_Level_settings_changed() -> void:
	_refresh()
