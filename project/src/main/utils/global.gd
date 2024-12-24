extends Node
## Contains variables for preserving state when loading different scenes.

## splash screen which precedes the main menu.
const SCENE_SPLASH := "res://src/main/ui/menu/SplashScreen.tscn"

## menu the player sees after starting the game.
const SCENE_MAIN_MENU := "res://src/main/ui/menu/MainMenu.tscn"

## non-interactive cutscene which shows creatures talking and interacting.
const SCENE_CUTSCENE := "res://src/main/world/Cutscene.tscn"

## scene for career mode which shows the player's progress between levels
const SCENE_CAREER_MAP := "res://src/main/career/CareerMap.tscn"

## scene for career mode which is shown at the end of a day
const SCENE_CAREER_WIN := "res://src/main/career/ui/CareerWin.tscn"

## scene for career mode's region select menu (chapter select menu)
const SCENE_CAREER_REGION_SELECT_MENU := "res://src/main/career/ui/CareerRegionSelectMenu.tscn"

## credits scene which shows scrolling credits.
const SCENE_CREDITS := "res://src/main/credits/CreditsScroll.tscn"

## menu where the player selects their difficulty
const SCENE_DIFFICULTY_MENU := "res://src/main/ui/difficulty/DifficultyMenu.tscn"

## puzzle where a player drops pieces into a playfield of blocks.
const SCENE_PUZZLE := "res://src/main/puzzle/Puzzle.tscn"

## cutscene demo; only used during development
const SCENE_CUTSCENE_DEMO := "res://src/demo/world/CutsceneDemo.tscn"

## Scale of the TextureRect the creature is rendered to
const CREATURE_SCALE := 0.4

## weighted distribution of 'fatnesses' in the range [1.0, 10.0]. most creatures are skinny.
const FATNESSES := [
	1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
	1.1, 1.2, 1.3, 1.5,
	1.8, 2.3,
]

## Factor to multiply by to convert non-isometric coordinates into isometric coordinates
const ISO_FACTOR := Vector2(1.0, 0.5)

var verbose_stdout_mode := false

## Game's main viewport width, as specified in the project settings
var window_size: Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/width"), \
		ProjectSettings.get_setting("display/window/size/height"))

## Stores all of the benchmarks which have been started
var _benchmark_start_times := Dictionary()


func _init() -> void:
	# ensure music, pieces are random
	randomize()


func _ready() -> void:
	if "--tf-verbose" in OS.get_cmdline_args() or OS.is_debug_build():
		verbose_stdout_mode = true


## Sets the start time for a benchmark. Calling 'benchmark_start(foo)' and 'benchmark_finish(foo)' will display a
## message like 'foo took 123 milliseconds'.
func benchmark_start(key: String = "") -> void:
	_benchmark_start_times[key] = Time.get_ticks_usec()


## Prints the amount of time which has passed since a benchmark was started. Calling 'benchmark_start(foo)' and
## 'benchmark_finish(foo)' will display a message like 'foo took 123 milliseconds'.
func benchmark_end(key: String = "") -> void:
	if not _benchmark_start_times.has(key):
		print("Invalid benchmark: %s" % key)
		return
	print("benchmark %s: %.3f msec" % [key, (Time.get_ticks_usec() - _benchmark_start_times[key]) / 1000.0])


func get_overworld_ui() -> OverworldUi:
	if not is_inside_tree():
		return null
	var nodes := get_tree().get_nodes_in_group("overworld_ui")
	return nodes[0] if nodes else null


func get_creature_editor_library() -> CreatureEditorLibrary:
	if not is_inside_tree():
		return null
	var nodes := get_tree().get_nodes_in_group("creature_editor_library")
	return nodes[0] if nodes else null


func print_verbose(s: String) -> void:
	if verbose_stdout_mode:
		print(s)


## Convert a coordinate from global coordinates to isometric (squashed) coordinates
static func to_iso(vector: Vector2) -> Vector2:
	return vector * ISO_FACTOR


## Convert a coordinate from isometric coordinates to global (unsquashed) coordinates
static func from_iso(vector: Vector2) -> Vector2:
	return vector / ISO_FACTOR
