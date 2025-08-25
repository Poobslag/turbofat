extends Node
## Stores information about the current level.

## emitted after the level has customized the puzzle's settings.
signal settings_changed

## emitted when the 'best_result' field changes, such as when starting or clearing a level.
signal best_result_changed

## If 'true' then the level is one which the player might keep retrying, even after clearing it.
## This is especially true for practice levels such as the 3 minute sprint level.
var keep_retrying := false

## Settings for the level currently being launched or played
var settings := LevelSettings.new() setget switch_level

## If 'true' the player only gets one life.
var hardcore := false

## If 'true' the player selected a career mode boss level.
var boss_level: bool

var puzzle: Puzzle

## The level which was originally launched. Some tutorial levels transition
## into other levels, so this keeps track of the original.
var level_id: String

## Piece speed to adjust the level to
var piece_speed: String

## Customers to queue up at the start of the level. If absent, random customers will be queued.
##
## This array can hold a combination of creature ids and CreatureDef instances.
var customers: Array

## Creature who will be the chef for the level. If absent, the player will be the chef.
var chef_id: String

## Monitors when the player finishes a level.
var first_result: int = Levels.Result.NONE
var best_result: int = Levels.Result.NONE setget set_best_result

## How many times the player has tried the level in this session.
var attempt_count := 0

## Human-readable id such as 'lemon' or 'marsh' for the puzzle environment
var puzzle_environment_id: String

func _ready() -> void:
	Breadcrumb.connect("before_scene_changed", self, "_on_Breadcrumb_before_scene_changed")


## Unsets all of the 'launched level' data.
func reset() -> void:
	keep_retrying = false
	settings = LevelSettings.new()
	hardcore = false
	boss_level = false
	puzzle = null
	level_id = ""
	piece_speed = ""
	customers = []
	chef_id = ""
	first_result = Levels.Result.NONE
	best_result = Levels.Result.NONE
	attempt_count = 0
	puzzle_environment_id = ""


## Stores the launched level data, so the level can be played later.
##
## Some tutorial levels transition into other levels, so this keeps track of the original.
##
## Parameters:
## 	'level_id': The level to launch
func set_launched_level(new_level_id: String) -> void:
	reset()
	level_id = new_level_id
	
	if new_level_id:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		GameplayDifficultyAdjustments.adjust_milestones(level_settings)
		if level_settings.other.tutorial:
			customers = [CreatureLibrary.SENSEI_ID]


## Updates the current level settings and resets all score data.
##
## Parameters:
## 	'new_settings': Settings to apply to the current level.
##
## 	'suppress_change_signal': (Optional) If true, the 'settings_changed' is suppressed. This signal normally
## 		initializes tile maps, sprites, and plays sound effects during a puzzle. If this is unnecessary, the signal
## 		should be suppressed. Defaults to false.
func start_level(new_settings: LevelSettings, suppress_change_signal: bool = false) -> void:
	level_id = new_settings.id
	PuzzleState.reset()
	switch_level(new_settings, suppress_change_signal)


## Updates the current level settings.
##
## Parameters:
## 	'new_settings': Settings to apply to the current level.
##
## 	'suppress_change_signal': (Optional) If true, the 'settings_changed' is suppressed. This signal normally
## 		initializes tile maps, sprites, and plays sound effects during a puzzle. If this is unnecessary, the signal
## 		should be suppressed. Defaults to false.
func switch_level(new_settings: LevelSettings, suppress_change_signal: bool = false) -> void:
	settings = new_settings
	if not suppress_change_signal:
		emit_signal("settings_changed")


## Launches a puzzle scene with the previously specified 'launched level' settings.
func push_level_trail() -> void:
	var level_settings := LevelSettings.new()
	level_settings.load_from_resource(level_id)
	GameplayDifficultyAdjustments.adjust_milestones(level_settings)
	if piece_speed:
		LevelSpeedAdjuster.new(level_settings).adjust(piece_speed)
	if hardcore:
		level_settings.lose_condition.top_out = 1
	
	# When the player first launches the game and does the tutorial, we skip the typical puzzle intro.
	if level_id == OtherLevelLibrary.BEGINNER_TUTORIAL \
			and not PlayerData.level_history.is_level_finished(OtherLevelLibrary.BEGINNER_TUTORIAL):
		level_settings.other.skip_intro = true
	
	start_level(level_settings)
	for customer_obj in customers:
		if customer_obj is String:
			var customer_id: String = customer_obj
			var creature_def: CreatureDef = PlayerData.creature_library.get_creature_def(customer_id)
			PlayerData.customer_queue.priority_queue.append(creature_def)
		elif customer_obj is CreatureDef:
			var creature_def: CreatureDef = customer_obj
			PlayerData.customer_queue.priority_queue.append(creature_def)
		else:
			push_warning("Unrecognized customer: %s" % [customer_obj])
	SceneTransition.push_trail(Global.SCENE_PUZZLE)


func set_best_result(new_best_result: int) -> void:
	best_result = new_best_result
	emit_signal("best_result_changed")


## Returns a list of all creature ids in the level.
##
## This includes the creature the player interacted with to launch the level, the chef, and any customers. Empty
## creature ids are not included.
func get_creature_ids() -> Array:
	var result := {}
	if chef_id:
		result[chef_id] = true
	for customer_obj in customers:
		if customer_obj is String:
			result[customer_obj] = true
		elif customer_obj is CreatureDef:
			result[customer_obj.creature_id] = true
		else:
			push_warning("Unrecognized customer: %s" % [customer_obj])
	if result.has(""):
		result.erase("")
	return result.keys()


## Returns 'true' if the hold piece window should be visible for the current level.
##
## Even if the player wants to cheat, we hide the hold piece window if the player is in a tutorial.
func is_hold_piece_cheat_enabled() -> bool:
	return PlayerData.difficulty.hold_piece \
			and not is_tutorial()


## Returns 'true' if the piece speed should be adjusted for the current level.
##
## Even if the player wants to cheat, we preserve the game's original piece speed if the player is in a tutorial.
func is_piece_speed_cheat_enabled() -> bool:
	return PlayerData.difficulty.speed != DifficultyData.Speed.DEFAULT \
			and not CurrentLevel.is_tutorial()


## Returns 'true' if line pieces should be inserted for the current level.
##
## Even if the player wants to cheat, we don't add line pieces if the player is in the tutorial or if the level already
## includes line pieces.
##
## Adding line pieces for tutorials can make the tutorials impossible.
func is_line_piece_cheat_enabled() -> bool:
	return PlayerData.difficulty.line_piece \
			and not CurrentLevel.is_tutorial() \
			and not PieceTypes.piece_i in CurrentLevel.settings.piece_types.start_types \
			and not PieceTypes.piece_i in CurrentLevel.settings.piece_types.types


## Returns 'true' for tutorial levels which are led by Turbo.
func is_tutorial() -> bool:
	return settings.other.tutorial


## Returns 'true' if the customer queue already has the specified customer.
##
## Customers are compared by creature_id, or by name if neither customer has a creature_id.
##
## Parameters:
## 	'customer_obj': A String creature_id or CreatureDef to search for.
func has_customer(customer_obj) -> bool:
	var result := false
	for other_customer_obj in customers:
		if _customers_match(customer_obj, other_customer_obj):
			result = true
			break
	return result


## Returns 'true' if the specified objects represent the same customer.
##
## Customers are compared by creature_id, or by name if neither customer has a creature_id.
##
## Parameters:
## 	'customer1': A String creature_id or CreatureDef to compare.
##
## 	'customer2': A String creature_id or CreatureDef to compare.
func _customers_match(customer1, customer2) -> bool:
	var result := false
	
	var id1 := customer1 as String if customer1 is String else customer1.creature_id
	var id2 := customer2 as String if customer2 is String else customer2.creature_id
	var name1 := "" if customer1 is String else customer1.creature_name
	var name2 := "" if customer2 is String else customer2.creature_name
	
	if id1 or id2:
		result = id1 == id2
	elif name1 or name2:
		result = name1 == name2
	
	return result


## Purges all node instances from the singleton.
##
## Because CurrentLevel is a singleton, node instances should be purged before changing scenes. Otherwise they'll
## continue consuming resources and could cause side effects.
func _on_Breadcrumb_before_scene_changed() -> void:
	Global.print_verbose("Scene changing; unassigning CurrentLevel.puzzle.")
	puzzle = null
	Global.print_verbose("Finished unassigning CurrentLevel.puzzle.")
