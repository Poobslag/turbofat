extends "res://src/main/puzzle/pan/frying-pans-ui.gd"
## Updates the FryingPansUi based on the level's settings and how the player is doing.

func _ready() -> void:
	_ready()
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)
	PuzzleState.topped_out.connect(_on_PuzzleState_topped_out)
	PuzzleState.game_ended.connect(_on_PuzzleState_game_ended)
	_refresh_lives()


## Updates the state of the FryingPansUi and refreshes the tilemap.
func _refresh_lives() -> void:
	pans_max = CurrentLevel.settings.lose_condition.top_out
	if PuzzleState.level_performance.lost:
		pans_remaining = 0
	else:
		pans_remaining = CurrentLevel.settings.lose_condition.top_out - PuzzleState.level_performance.top_out_count
	gold = CurrentLevel.settings.blocks_during.clear_on_top_out
	refresh_tilemap()


func _on_PuzzleState_game_prepared() -> void:
	_refresh_lives()


func _on_PuzzleState_game_ended() -> void:
	_refresh_lives()


## Updates the state of the FryingPansUi when the player loses a life.
##
## We deliberately avoid calling refresh_lives because we want to trigger the animation where a frying pan fades out.
func _on_PuzzleState_topped_out() -> void:
	set_pans_remaining(pans_remaining - 1)
