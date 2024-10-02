extends SteamAchievement
## Unlocks an achievement when the player customizes their creature.

func connect_signals() -> void:
	.connect_signals()
	# The creature editor does not fire a 'save_scheduled' signal when saving; we connect a 'before_save' signal
	# instead
	disconnect_save_signal()
	PlayerSave.connect("before_save", self, "_on_PlayerSave_before_save")


func refresh_achievement() -> void:
	var player_dna := PlayerData.creature_library.get_player_def().dna
	if not Utils.is_json_deep_equal(player_dna, CreatureDef.DEFAULT_DNA):
		SteamUtils.set_achievement(achievement_id)


func _on_PlayerSave_before_save() -> void:
	refresh_achievement()
