class_name SteamAchievement
extends Node

export (String) var achievement_id: String

func _ready():
	PlayerSave.connect("after_load", self, "_on_PlayerSave_after_load")
	PlayerSave.connect("after_save", self, "_on_PlayerSave_after_save")


## Overridden by child classes to call GodotSteam.set_achievement appropriately.
func refresh_achievement() -> void:
	pass


func clear_achievement() -> void:
	GodotSteam.clear_achievement(achievement_id)


func _on_PlayerSave_after_load() -> void:
	refresh_achievement()


func _on_PlayerSave_after_save() -> void:
	refresh_achievement()
