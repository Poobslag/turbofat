extends SteamAchievement
## Unlocks an achievement when the player views all cutscenes in a chapter.

## The 'API Name' of the Steam stat which tracks how many cutscenes the player has viewed.
export (String) var stat_id: String

## The region ID whose cutscenes should be tracked.
export (String) var region_id: String

func connect_signals() -> void:
	.connect_signals()
	# avoid checking for story completion every time we save; this changes infrequently and is expensive to check.
	disconnect_save_signal()
	CurrentCutscene.connect("cutscene_played", self, "_on_CurrentCutscene_cutscene_played")


## Refreshes the achievement and stat based on how many cutscenes the player has viewed in a chapter.
func refresh_achievement() -> void:
	var cutscene_completion_percent: float = _cutscene_completion_percent()
	
	if cutscene_completion_percent >= 0.0 and cutscene_completion_percent <= 1.0:
		SteamUtils.set_stat_float(stat_id, 100 * cutscene_completion_percent)
	else:
		push_error("Invalid cutscene_completion_percent for region %s: %s" % [region_id, cutscene_completion_percent])
	
	if cutscene_completion_percent == 1.0:
		SteamUtils.set_achievement(achievement_id)


func _cutscene_completion_percent() -> float:
	var region_completion := PlayerData.career.region_completion(CareerLevelLibrary.region_for_id(region_id))
	return region_completion.cutscene_completion_percent()


## When a cutscene is played, if it corresponds to our region we refresh our achievement status.
func _on_CurrentCutscene_cutscene_played(chat_key: String) -> void:
	var cutscene_region: CareerRegion = CareerLevelLibrary.region_for_chat_key(chat_key)
	if cutscene_region and cutscene_region.id == region_id:
		refresh_achievement()
