class_name SteamAchievement
extends Node
## Unlocks an achievement when a condition is met.
##
## The condition is checked every time data is saved or loaded.

## The 'API Name' of the achievement to unlock.
export (String) var achievement_id: String

func _ready() -> void:
	add_to_group("steam_achievements")
	connect_signals()


## Connects signals needed for this achievement. Can be overridden by child scripts to connect other signals.
func connect_signals() -> void:
	PlayerSave.connect("save_scheduled", self, "_on_PlayerSave_save_scheduled")
	PlayerSave.connect("after_load", self, "_on_PlayerSave_after_load")


func disconnect_save_signal() -> void:
	PlayerSave.disconnect("save_scheduled", self, "_on_PlayerSave_save_scheduled")


func disconnect_load_signal() -> void:
	PlayerSave.disconnect("after_load", self, "_on_PlayerSave_after_load")


## Overridden by child classes to refresh the achievement and any stats.
##
## Child classes should call SteamUtils.set_achievement and SteamUtils.set_stat_xxx appropriately.
func refresh_achievement() -> void:
	pass


## Resets the unlock status of an achievement.
##
## This is primarily only ever used for testing.
func clear_achievement() -> void:
	SteamUtils.clear_achievement(achievement_id)


## We check the achievement condition each time the player loads save data.
##
## This allows the player to unlock achievements when launching the game or changing save slots.
func _on_PlayerSave_after_load() -> void:
	if not SteamUtils.is_achievement_achieved(achievement_id):
		refresh_achievement()


## We check the achievement condition each time the player saves save data.
##
## This allows the player to unlock achievements after playing a level or watching a cutscene.
func _on_PlayerSave_save_scheduled() -> void:
	if not SteamUtils.is_achievement_achieved(achievement_id):
		refresh_achievement()