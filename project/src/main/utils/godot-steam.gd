extends Node

const STEAM_APP_ID: int = 2213410

## toggle to view detailed steam messages
var verbose := false

# Steam variables
onready var Steam = preload("res://addons/godotsteam/godotsteam.gdns").new()

func _ready() -> void:
	_initialize_steam()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func _log(message: String) -> void:
	if not verbose:
		return
	
	print("[STEAM] %s" % [message])


func _initialize_steam() -> void:
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	_log("Initializing Steam: %s" % [STEAM_APP_ID])
	
	var steam_init_ex_response: Dictionary = Steam.steamInitEx(true, STEAM_APP_ID)
	_log("steamInitEx response: %s" % [steam_init_ex_response])


func set_achievement(id: String) -> void:
	_log("Setting Steam achievement: %s" % [id])
	
	var set_achievement_response: bool = Steam.setAchievement(id)
	_log("setAchievement(%s) response: %s" % [id, set_achievement_response])
	
	var store_stats_response: bool = Steam.storeStats()
	_log("storeStats response: %s" % [store_stats_response])


func set_stat_float(id: String, value: float) -> void:
	_log("Setting Steam stat: %s -> %s" % [id, value])
	
	var set_stat_float_response: bool = Steam.setStatFloat(id, value)
	_log("setStatFloat(%s, %s) response: %s" % [id, value, set_stat_float_response])


func clear_achievement(id: String) -> void:
	_log("Clearing Steam achievement: %s" % [id])
	
	var clear_achievement_response: bool = Steam.clearAchievement(id)
	_log("clearAchievement(%s) response: %s" % [id, clear_achievement_response])
	
	var store_stats_response: bool = Steam.storeStats()
	_log("storeStats response: %s" % [store_stats_response])
