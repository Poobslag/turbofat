extends Node
## Utilities for interacting with Steam.
##
## This method interacts with SteamFacade to avoid calling Steam's API too frequently. Calling Steam's API too
## frequently seems to cause crashes, possibly due to GodotSteam #474
## (https://github.com/GodotSteam/GodotSteam/issues/474)

const STEAM_APP_ID: int = 2213410

## Timer which calls Steam.storeStats() after a delay.
var _store_stats_timer: SceneTreeTimer

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	_initialize_steam()


func _process(_delta: float) -> void:
	SteamFacade.run_callbacks()


## Gets the current value of a given stat for the current user.
##
## Parameters:
## 	'id': The 'API Name' of the stat.
func get_stat_float(id: String) -> float:
	var get_stat_float_response: float = SteamFacade.getStatFloat(id)
	return get_stat_float_response


## Returns true if the specified achievement is unlocked.
##
## Parameters:
## 	'id': The 'API Name' of the achievement.
func is_achievement_achieved(id: String) -> bool:
	var get_achievement_response: Dictionary = SteamFacade.getAchievement(id)
	
	var result := false
	if get_achievement_response \
			and get_achievement_response.has("achieved") \
			and get_achievement_response["achieved"] is bool:
		result = get_achievement_response["achieved"]
	else:
		push_warning("Unexpected getAchievement response: %s" % [get_achievement_response])
	
	return result


## Unlocks an achievement.
##
## Parameters:
## 	'id': The 'API Name' of the achievement.
func set_achievement(id: String) -> void:
	if is_achievement_achieved(id):
		# avoid unnecessary storeStats calls
		return
	
	SteamFacade.setAchievement(id)
	_schedule_store_stats()


## Sets / updates the value of a given stat for the current user.
##
## Parameters:
## 	'id': The 'API Name' of the stat.
##
## 	'value': The new value of the stat.
func set_stat_float(id: String, value: float) -> void:
	if is_equal_approx(get_stat_float(id), value):
		# avoid unnecessary storeStats calls
		return
	
	SteamFacade.setStatFloat(id, value)
	_schedule_store_stats()


## Resets the current users stats and, optionally achievements.
##
## Parameters:
## 	'achievements_too': If 'true', the user's achievements are also reset
func reset_all_stats(achievements_too: bool) -> void:
	SteamFacade.resetAllStats(achievements_too)


## Resets the unlock status of an achievement.
##
## This is primarily only ever used for testing.
##
## Parameters:
## 	'id': The 'API Name' of the achievement.
func clear_achievement(id: String) -> void:
	if not is_achievement_achieved(id):
		# avoid unnecessary storeStats calls
		return
	
	SteamFacade.clearAchievement(id)
	_schedule_store_stats()


## Initialize the Steamworks SDK.
func _initialize_steam() -> void:
	## When the game is run through the Steam client, it already knows which game we are playing. However, during
	## development and testing, we must supply a valid app ID via these environment variables.
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	SteamFacade.steamInitEx(true, STEAM_APP_ID)
	SteamFacade.connect("overlay_toggled", self, "_on_Steam_overlay_toggled")


## Schedules the changed stats and achievements data to be sent to the server a few milliseconds in the future.
##
## storeStats() sends the user's achievements and stats to the server, and call frequency should be on the order of
## minutes, rather than seconds. To avoid calling it too frequently, we use a timer so that a bunch of achievements
## and stats can all be set in one storeStats call.
##
## If a storeStats() call is already scheduled, this method has no effect.
func _schedule_store_stats() -> void:
	if _store_stats_timer == null:
		_store_stats_timer = get_tree().create_timer(0.5)
		_store_stats_timer.connect("timeout", self, "_on_StoreStatsTimer_timeout")


## Send the changed stats and achievements data to the server for permanent storage.
##
## This should only be called by _schedule_store_stats(), everyone else should use _schedule_store_stats() instead.
func _store_stats() -> void:
	SteamFacade.storeStats()


## When the StoreStatsTimer times out, we call SteamFacade.storeStats() and reset the timer.
func _on_StoreStatsTimer_timeout() -> void:
	_store_stats_timer = null
	_store_stats()


## When the Steam overlay is toggled, we pause the game.
func _on_Steam_overlay_toggled(toggled: bool, _user_initiated: bool, _app_id: int) -> void:
	Pauser.toggle_pause("steam-overlay", toggled)
