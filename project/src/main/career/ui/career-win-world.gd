tool
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles which appear on the career mode's victory screen.

## The path to the scene resource defining creatures and obstacles for career regions which do not specify an
## environment, or regions which specify an invalid environment
const DEFAULT_ENVIRONMENT_PATH := "res://src/main/world/environment/marsh/MarshWinEnvironment.tscn"

## key: (String) an Environment id which appears in the json definitions
## value: (String) Path to the scene resource defining creatures and obstacles which appear on the victory screen
## 	in that environment
const ENVIRONMENT_PATH_BY_ID := {
	"lemon": "res://src/main/world/environment/lemon/LemonWinEnvironment.tscn",
	"marsh": "res://src/main/world/environment/marsh/MarshWinEnvironment.tscn",
	"poki": "res://src/main/world/environment/poki/PokiWinEnvironment.tscn",
	"sand": "res://src/main/world/environment/sand/SandWinEnvironment.tscn",
	"lava": "res://src/main/world/environment/lava/LavaWinEnvironment.tscn",
}

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		var sensei := overworld_environment.get_creature_by_id(CreatureLibrary.SENSEI_ID)
		sensei.visible = false
	
	_refresh_mood()


func initial_environment_path() -> String:
	var environment_id := PlayerData.career.current_region().overworld_environment_id
	return ENVIRONMENT_PATH_BY_ID.get(environment_id, DEFAULT_ENVIRONMENT_PATH)


## Updates the creature moods based on the player's performance.
func _refresh_mood() -> void:
	var player := overworld_environment.player
	var sensei := overworld_environment.sensei
	if PlayerData.career.steps >= Careers.DAILY_STEPS_GOOD:
		if player:
			player.play_mood(Creatures.Mood.LAUGH0)
		if sensei:
			sensei.play_mood(Creatures.Mood.LAUGH0)
	elif PlayerData.career.steps >= Careers.DAILY_STEPS_OK:
		if player:
			player.play_mood(Creatures.Mood.SMILE0)
		if sensei:
			sensei.play_mood(Creatures.Mood.SMILE0)
	else:
		if player:
			player.play_mood(Creatures.Mood.RAGE0)
		if sensei:
			sensei.play_mood(Creatures.Mood.RAGE0)
