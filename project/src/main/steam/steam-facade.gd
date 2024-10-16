extends Node
## Facade for interacting with Steam.
##
## This facade caches Steam responses for achievements and stats to limit the number of API calls. This serves three
## purposes:
##
## 1. Reduces the size of our log files, as we log every Steam call
## 2. Keeps us within Steam's API usage guidelines
## 3. Sidesteps GodotSteam bugs such as GodotSteam #474 (https://github.com/GodotSteam/GodotSteam/issues/474)
##
## In the absence of a cache, we make 44 calls on startup (31 achievement checks, 12 stat checks, and 1 init call),
## and 18 calls when clearing a typical level (18 achievement checks).
##
## With the presence of a cache, we make 38 calls on startup (25 achievement checks, 12 stat checks, and 1 init call),
## and 0 calls when clearing a typical level.

## If 'true', detailed messages will be shown for every call to Steam.
var verbose := true

## key: (String) achievement name
## value: (Dictionary) cached getAchievement response with the following keys: ret(bool), achieved(bool)
var _cached_achievement_responses_by_name := {}

## key: (String) stat name
## value: (float) cached getStatFloat response
var _cached_stat_float_responses_by_name := {}

## Resets the unlock status of an achievement.
func clearAchievement(achievement_name: String) -> bool:
	_cached_achievement_responses_by_name[achievement_name] = {"achieved": false, "ret": true}
	
	_log("Clearing Steam achievement: %s" % [achievement_name])
	var response: bool = Steam.clearAchievement(achievement_name)
	_log("clearAchievement(%s) response: %s" % [achievement_name, response])
	return response


## Connects a Steam signal to a method on a target object.
func connect(signal_name: String, target: Object, method: String, binds: Array = [], flags: int = 0) -> int:
	return Steam.connect(signal_name, target, method, binds, flags)


## Gets the unlock status of the Achievement, utilizing a cache to avoid unnecessary Steam calls.
func getAchievement(achievement_name: String) -> Dictionary:
	if not _cached_achievement_responses_by_name.has(achievement_name):
		_log("Getting Steam achievement: %s" % [achievement_name])
		var response := Steam.getAchievement(achievement_name)
		_log("getAchievement(%s) response: %s" % [achievement_name, response])
		
		_cached_achievement_responses_by_name[achievement_name] = response
	
	return _cached_achievement_responses_by_name[achievement_name]


## Gets the current value of the a stat for the current user, utilizing a cache to avoid unnecessary Steam calls.
func getStatFloat(stat_name: String) -> float:
	if not _cached_stat_float_responses_by_name.has(stat_name):
		_log("Getting Steam stat: %s" % [stat_name])
		var response := Steam.getStatFloat(stat_name)
		_log("getStatFloat(%s) response: %s" % [stat_name, response])
		
		_cached_stat_float_responses_by_name[stat_name] = response
	
	return _cached_stat_float_responses_by_name[stat_name]


## Resets the current users stats and, optionally achievements.
##
## Purges all entries in the stat/achievement cache. We could instead assign them their reset values, but that risks
## introducing bugs for stats with an unusual default value.
func resetAllStats(achievements_too: bool) -> bool:
	_cached_stat_float_responses_by_name.clear()
	_cached_achievement_responses_by_name.clear()
	
	_log("Resetting Steam stats: %s" % [achievements_too])
	var response: bool = Steam.resetAllStats(achievements_too)
	_log("resetAllStats(%s) response: %s" % [achievements_too, response])
	return response


## Enables your application to receive callbacks from Steamworks. Must be placed in your _process function.
func run_callbacks() -> void:
	Steam.run_callbacks()


## Unlocks an achievement, updating the cache to avoid unnecessary Steam calls.
func setAchievement(achievement_name: String) -> bool:
	_cached_achievement_responses_by_name[achievement_name] = {"achieved": true, "ret": true}
	
	_log("Setting Steam achievement: %s" % [achievement_name])
	var response: bool = Steam.setAchievement(achievement_name)
	_log("setAchievement(%s) response: %s" % [achievement_name, response])
	return response


## Sets / updates the float value of a given stat for the current user, updating the cache to avoid unnecessary Steam
## calls.
func setStatFloat(stat_name: String, value: float) -> bool:
	_cached_stat_float_responses_by_name[stat_name] = value
	
	_log("Setting Steam stat: %s -> %s" % [stat_name, value])
	var response: bool = Steam.setStatFloat(stat_name, value)
	_log("setStatFloat(%s, %s) response: %s" % [stat_name, value, response])
	return response


## Initializes the Steamworks SDK.
func steamInitEx(retrieve_stats: bool = true, app_id: int = 0, embed_callbacks: bool = false) -> Dictionary:
	_log("Initializing Steam: %s %s %s" % [retrieve_stats, app_id, embed_callbacks])
	var response: Dictionary = Steam.steamInitEx(retrieve_stats, app_id, embed_callbacks)
	_log("steamInitEx response: %s" % [response])
	return response


## Sends the changed stats and achievements data to the server for permanent storage.
func storeStats() -> bool:
	_log("Storing stats")
	var response: bool = Steam.storeStats()
	_log("storeStats response: %s" % [response])
	return response


## Prints a message if logging is enabled.
func _log(message: String) -> void:
	if not verbose:
		return
	
	print("[STEAM] %s %s" % [Time.get_ticks_msec(), message])
