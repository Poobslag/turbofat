tool
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles which appear on the career mode's victory screen.

## The path to the scene resource defining creatures and obstacles for career regions which do not specify an
## environment, or regions which specify an invalid environment
const DEFAULT_ENVIRONMENT_PATH := "res://src/main/world/environment/MarshWinEnvironment.tscn"

## key: (String) an environment name which appears in the json definitions
## value: (String) The path to the scene resource defining creatures and obstacles which appear on the victory screen
## 	in that environment
const ENVIRONMENT_PATH_BY_NAME := {
	"lemon": "res://src/main/world/environment/LemonWinEnvironment.tscn",
	"marsh": "res://src/main/world/environment/MarshWinEnvironment.tscn",
}


# Loads the cutscene's environment, replacing the current one in the scene tree.
func prepare_environment_resource() -> void:
	var loaded_environment_path := _career_environment_path()
	EnvironmentScene = load(loaded_environment_path)


func _career_environment_path() -> String:
	var environment_name := PlayerData.career.current_region().environment_name
	return ENVIRONMENT_PATH_BY_NAME.get(environment_name, DEFAULT_ENVIRONMENT_PATH)
