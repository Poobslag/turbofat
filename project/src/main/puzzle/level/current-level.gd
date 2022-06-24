extends Node
## Stores information about the current level.

## emitted after the level has customized the puzzle's settings.
signal settings_changed

## emitted when the 'best_result' field changes, such as when starting or clearing a level.
signal best_result_changed

## If 'true' then the level is one which the player might keep retrying, even after clearing it.
## This is especially true for practice levels such as the 3 minute sprint level.
var keep_retrying := false

## The settings for the level currently being launched or played
var settings := LevelSettings.new() setget switch_level

## The puzzle scene
var puzzle: Puzzle

## The level which was originally launched. Some tutorial levels transition
## into other levels, so this keeps track of the original.
var level_id: String

## The piece speed to adjust the level to
var piece_speed: String

## The creature who launched the level.
var creature_id: String

## The customers to queue up at the start of the level. If absent, random customers will be queued.
##
## This array can hold a combination of creature ids and CreatureDef instances.
var customers: Array

## The creature who will be the chef for the level. If absent, the player will be the chef.
var chef_id: String

## Tracks when the player finishes a level.
var best_result: int = Levels.Result.NONE setget set_best_result

## How many times the player has tried the level in this session.
var attempt_count := 0

## Tracks whether or not the player wants to play or skip this level's cutscene.
var cutscene_force: int = Levels.CutsceneForce.NONE

## A human-readable environment name, such as 'lemon' or 'marsh' for the puzzle environment
var puzzle_environment_name: String

func _ready() -> void:
	Breadcrumb.connect("before_scene_changed", self, "_on_Breadcrumb_before_scene_changed")


## Unsets all of the 'launched level' data.
func clear_launched_level() -> void:
	set_launched_level("")


## Stores the launched level data, so the level can be played later.
##
## Some tutorial levels transition into other levels, so this keeps track of the original.
##
## Parameters:
## 	'level_id': The level to launch
func set_launched_level(new_level_id: String) -> void:
	level_id = new_level_id
	piece_speed = ""
	
	var level_lock: LevelLock
	if level_id:
		level_lock = LevelLibrary.level_lock(level_id)
	
	set_best_result(Levels.Result.NONE)
	attempt_count = 0
	cutscene_force = Levels.CutsceneForce.NONE
	puzzle_environment_name = ""
	
	if level_lock:
		creature_id = level_lock.creature_id
		customers = level_lock.customer_ids.duplicate()
		chef_id = level_lock.chef_id
	else:
		creature_id = ""
		customers = []
		chef_id = ""


func start_level(new_settings: LevelSettings) -> void:
	level_id = new_settings.id
	PuzzleState.reset()
	switch_level(new_settings)


func switch_level(new_settings: LevelSettings) -> void:
	settings = new_settings
	emit_signal("settings_changed")


## Launches a puzzle scene with the previously specified 'launched level' settings.
func push_level_trail() -> void:
	var level_settings := LevelSettings.new()
	level_settings.load_from_resource(level_id)
	if piece_speed:
		LevelSpeedAdjuster.new(level_settings).adjust(piece_speed)
	
	# When the player first launches the game and does the tutorial, we skip the typical puzzle intro.
	if level_id == LevelLibrary.BEGINNER_TUTORIAL \
			and not PlayerData.level_history.is_level_finished(LevelLibrary.BEGINNER_TUTORIAL):
		level_settings.other.skip_intro = true
	
	start_level(level_settings)
	for customer_obj in customers:
		if customer_obj is String:
			var customer_id: String = customer_obj
			var creature_def: CreatureDef = PlayerData.creature_library.get_creature_def(customer_id)
			PlayerData.creature_queue.primary_queue.push_front(creature_def)
		elif customer_obj is CreatureDef:
			var creature_def: CreatureDef = customer_obj
			PlayerData.creature_queue.primary_queue.push_front(creature_def)
		else:
			push_warning("Unrecognized customer: %s" % [customer_obj])
	SceneTransition.push_trail(Global.SCENE_PUZZLE)


func set_best_result(new_best_result: int) -> void:
	best_result = new_best_result
	emit_signal("best_result_changed")


## Purges all node instances from the singleton.
##
## Because CurrentLevel is a singleton, node instances should be purged before changing scenes. Otherwise they'll
## continue consuming resources and could cause side effects.
func _on_Breadcrumb_before_scene_changed() -> void:
	puzzle = null
