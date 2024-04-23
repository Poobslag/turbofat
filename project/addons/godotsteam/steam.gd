extends Node
## Utilities for interacting with Steam.
##
## This script is TurboFat specific. Due to how GDNative works, it must remain at "res://addons/steam.gd" and cannot
## be renamed or moved.

const STEAM_APP_ID: int = 2213410

## If 'true', detailed messages will be shown for every call to Steam.
var verbose := true

## Timer which calls Steam.storeStats() after a delay.
var _store_stats_timer: SceneTreeTimer

onready var Steam = preload("res://addons/godotsteam/godotsteam.gdns").new()

func _ready() -> void:
	_initialize_steam()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


## Gets the current value of a given stat for the current user.
##
## Parameters:
## 	'id': The 'API Name' of the stat.
func get_stat_float(id: String) -> float:
	_log("Getting Steam stat: %s" % [id])
	
	var get_stat_float_response: float = Steam.getStatFloat(id)
	_log("get_stat_float(%s) response: %s" % [id, get_stat_float_response])
	
	return get_stat_float_response


## Returns true if the specified achievement is unlocked.
##
## Parameters:
## 	'id': The 'API Name' of the achievement.
func is_achievement_achieved(id: String) -> bool:
	_log("Getting Steam achievement: %s" % [id])
	
	var get_achievement_response: Dictionary = Steam.getAchievement(id)
	_log("getAchievement(%s) response: %s" % [id, get_achievement_response])
	
	return get_achievement_response["achieved"]


## Unlocks an achievement.
##
## Parameters:
## 	'id': The 'API Name' of the achievement.
func set_achievement(id: String) -> void:
	_log("Setting Steam achievement: %s" % [id])
	
	if is_achievement_achieved(id):
		# avoid unnecessary storeStats calls
		return
	
	var set_achievement_response: bool = Steam.setAchievement(id)
	_log("setAchievement(%s) response: %s" % [id, set_achievement_response])
	
	_schedule_store_stats()


## Sets / updates the value of a given stat for the current user.
##
## Parameters:
## 	'id': The 'API Name' of the stat.
##
## 	'value': The new value of the stat.
func set_stat_float(id: String, value: float) -> void:
	_log("Setting Steam stat: %s -> %s" % [id, value])
	
	if is_equal_approx(get_stat_float(id), value):
		# avoid unnecessary storeStats calls
		return
	
	var set_stat_float_response: bool = Steam.setStatFloat(id, value)
	_log("setStatFloat(%s, %s) response: %s" % [id, value, set_stat_float_response])
	
	_schedule_store_stats()


## Resets the current users stats and, optionally achievements.
##
## Parameters:
## 	'achievements_too': If 'true', the user's achievements are also reset
func reset_all_stats(achievements_too: bool) -> void:
	_log("Resetting Steam stats: %s" % [achievements_too])
	
	var reset_all_stats_response: bool = Steam.resetAllStats(achievements_too)
	_log("resetAllStats(%s) response: %s" % [achievements_too, reset_all_stats_response])


## Resets the unlock status of an achievement.
##
## This is primarily only ever used for testing.
##
## Parameters:
## 	'id': The 'API Name' of the achievement.
func clear_achievement(id: String) -> void:
	_log("Clearing Steam achievement: %s" % [id])
	
	if not is_achievement_achieved(id):
		# avoid unnecessary storeStats calls
		return
	
	var clear_achievement_response: bool = Steam.clearAchievement(id)
	_log("clearAchievement(%s) response: %s" % [id, clear_achievement_response])
	
	_schedule_store_stats()


## Initialize the Steamworks SDK.
func _initialize_steam() -> void:
	## When the game is run through the Steam client, it already knows which game we are playing. However, during
	## development and testing, we must supply a valid app ID via these environment variables.
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	_log("Initializing Steam: %s" % [STEAM_APP_ID])
	
	## steamInitEx() accepts a STEAM_APP_ID, but GDNative does not support it.
	var steam_init_ex_response: Dictionary = Steam.steamInitEx(true)
	_log("steamInitEx response: %s" % [steam_init_ex_response])


## Prints a message if logging is enabled.
func _log(message: String) -> void:
	if not verbose:
		return
	
	print("[STEAM] %s" % [message])


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
	_log("Storing stats")
	
	var store_stats_response: bool = Steam.storeStats()
	_log("storeStats response: %s" % [store_stats_response])


## When the StoreStatsTimer times out, we call Steam.storeStats() and reset the timer.
func _on_StoreStatsTimer_timeout() -> void:
	_store_stats_timer = null
	_store_stats()
