extends SteamAchievement
## Unlocks an achievement when the player obtains a grade of 'M' on any level.

## The best rank the player has achieved on any level since launching the game.
var _best_level_rank: float = RankCalculator.WORST_RANK

func _ready() -> void:
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")


## Refreshes the achievement and stat based on how many cutscenes the player has viewed in a chapter.
func refresh_achievement() -> void:
	if RankCalculator.rank_meets_grade(_best_level_rank, "M"):
		Steam.set_achievement(achievement_id)


func _on_PuzzleState_game_ended() -> void:
	var rank_result := RankCalculator.new().calculate_rank()
	var current_level_rank: float
	if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
		current_level_rank = rank_result.seconds_rank
	else:
		current_level_rank = rank_result.score_rank
	
	_best_level_rank = min(_best_level_rank, current_level_rank)
