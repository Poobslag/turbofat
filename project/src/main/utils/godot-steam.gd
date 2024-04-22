extends Node

const STEAM_APP_ID: int = 2213410

# Steam variables
onready var Steam = preload("res://addons/godotsteam/godotsteam.gdns").new()

func _ready() -> void:
	_initialize_steam()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


func _initialize_steam() -> void:
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	print("[STEAM] Initializing Steam: %s" % [STEAM_APP_ID])
	
	var steam_init_ex_response: Dictionary = Steam.steamInitEx(true, STEAM_APP_ID)
	print("[STEAM] steamInitEx response: %s" % steam_init_ex_response)


func set_achievement(id: String) -> void:
	print("[STEAM] Setting Steam achievement: %s" % id)
	
	var set_achievement_response: bool = Steam.setAchievement(id)
	print("[STEAM] setAchievement(%s) response: %s" % [id, set_achievement_response])
	
	var store_stats_response: bool = Steam.storeStats()
	print("[STEAM] storeStats response: %s" % [store_stats_response])


func clear_achievement(id: String) -> void:
	print("[STEAM] Clearing Steam achievement: %s" % id)
	
	var clear_achievement_response: bool = Steam.clearAchievement(id)
	print("[STEAM] clearAchievement(%s) response: %s" % [id, clear_achievement_response])
	
	var store_stats_response: bool = Steam.storeStats()
	print("[STEAM] storeStats response: %s" % [store_stats_response])
