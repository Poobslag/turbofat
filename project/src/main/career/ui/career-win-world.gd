#@tool
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles which appear on the career mode's victory screen.

## The path to the scene resource defining creatures and obstacles for career regions which do not specify an
## environment, or regions which specify an invalid environment
const DEFAULT_ENVIRONMENT_PATH := "res://src/main/world/environment/marsh/MarshWinEnvironment.tscn"

## key: (String) an Environment name which appears in the json definitions
## value: (String) Path to the scene resource defining creatures and obstacles which appear on the victory screen
## 	in that environment
const ENVIRONMENT_PATH_BY_NAME := {
	"lemon": "res://src/main/world/environment/lemon/LemonWinEnvironment.tscn",
	"marsh": "res://src/main/world/environment/marsh/MarshWinEnvironment.tscn",
	"poki": "res://src/main/world/environment/poki/PokiWinEnvironment.tscn",
}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		var sensei := CreatureManager.get_creature_by_id(CreatureLibrary.SENSEI_ID)
		sensei.visible = false
	
	_refresh_mood()


func get_initial_environment_path() -> String:
	var environment_name := PlayerData.career.current_region().overworld_environment_name
	return ENVIRONMENT_PATH_BY_NAME.get(environment_name, DEFAULT_ENVIRONMENT_PATH)


## Updates the creature moods based on the player's performance.
func _refresh_mood() -> void:
	var player := CreatureManager.get_player()
	var sensei := CreatureManager.get_sensei()
	if PlayerData.career.daily_steps >= Careers.DAILY_STEPS_GOOD:
		player.play_mood(Creatures.Mood.LAUGH0)
		if sensei:
			sensei.play_mood(Creatures.Mood.LAUGH0)
	elif PlayerData.career.daily_steps >= Careers.DAILY_STEPS_OK:
		player.play_mood(Creatures.Mood.SMILE0)
		if sensei:
			sensei.play_mood(Creatures.Mood.SMILE0)
	else:
		player.play_mood(Creatures.Mood.RAGE0)
		if sensei:
			sensei.play_mood(Creatures.Mood.RAGE0)
