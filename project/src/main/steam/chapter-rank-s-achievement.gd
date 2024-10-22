extends SteamAchievement
## Unlocks an achievement when the player gets rank "S-" on all levels in a chapter, excluding the boss level.

## The 'API Name' of the Steam stat which tracks how many levels the player has achieved an 'S' rank on
export (String) var stat_id: String

## The region ID whose unlock status should be tracked.
export (String) var region_id: String

func connect_signals() -> void:
	.connect_signals()
	# avoid checking for 'rank s' every time we save; this changes infrequently and is expensive to check.
	disconnect_save_signal()
	PuzzleState.connect("after_game_ended", self, "_on_PuzzleState_after_game_ended")


## Refreshes the achievement based on whether the chapter has been unlocked.
func refresh_achievement() -> void:
	var s_rank_percent: float = _s_rank_percent()
	
	if s_rank_percent >= 0.0 and s_rank_percent <= 1.0:
		SteamUtils.set_stat_float(stat_id, 100 * s_rank_percent)
	else:
		push_error("Invalid s_rank_percent for region %s: %s" % [region_id, s_rank_percent])
	
	if s_rank_percent == 1.0:
		SteamUtils.set_achievement(achievement_id)


## Returns a number in the range [0.0, 1.0] for how many levels the player has achieved an 'S' rank on.
func _s_rank_percent() -> float:
	var region := CareerLevelLibrary.region_for_id(region_id)
	var s_rank_count := 0
	for level_obj in region.levels:
		var level: CareerLevel = level_obj
		var rank := PlayerData.level_history.best_overall_rank(level.level_id)
		if Ranks.rank_meets_grade(rank, "S-"):
			s_rank_count += 1
	
	return s_rank_count / float(max(1, region.levels.size()))


## When a level is played, if it corresponds to our region we refresh our achievement status.
func _on_PuzzleState_after_game_ended() -> void:
	if SteamUtils.is_achievement_achieved(achievement_id):
		return
	var level_region_id := CareerLevelLibrary.region_id_for_level_id(CurrentLevel.level_id)
	if level_region_id == region_id:
		refresh_achievement()
