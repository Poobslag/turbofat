extends SteamAchievement
## Unlocks an achievement when the player obtains a grade of 'M' on any level.

## The best rank the player has achieved on any level since launching the game.
var _best_level_rank: float = Ranks.WORST_RANK

func connect_signals() -> void:
	.connect_signals()
	disconnect_save_signal()
	disconnect_load_signal()
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")


## Refreshes the achievement and stat based on how many cutscenes the player has viewed in a chapter.
func refresh_achievement() -> void:
	if Ranks.rank_meets_grade(_best_level_rank, "M"):
		SteamUtils.set_achievement(achievement_id)


func _on_PuzzleState_game_ended() -> void:
	if CurrentLevel.is_tutorial() or CurrentLevel.settings.other.after_tutorial:
		# don't activate the achievement for tutorials
		return
	if SteamUtils.is_achievement_achieved(achievement_id):
		return
	
	var rank_result := RankCalculator.new().calculate_rank()
	var current_level_rank := rank_result.rank
	
	_best_level_rank = min(_best_level_rank, current_level_rank)
	refresh_achievement()
