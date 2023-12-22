extends FryingPansUi
## Updates the FryingPansUi based on the level's settings and how the player is doing.

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	_refresh_lives()


## Updates the state of the FryingPansUi and refreshes the tilemap.
func _refresh_lives() -> void:
	pans_max = CurrentLevel.settings.lose_condition.top_out
	if PuzzleState.level_performance.lost:
		pans_remaining = 0
	else:
		pans_remaining = CurrentLevel.settings.lose_condition.top_out - PuzzleState.level_performance.top_out_count
		
		if PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0:
			pans_remaining = int(max(0, pans_remaining - PlayerData.career.top_out_count))
			if pans_remaining == 0 and PuzzleState.level_performance.top_out_count == 0:
				# the player always starts with at least one life in career mode, even if they've topped out a lot on
				# previous levels
				pans_remaining = 1
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
