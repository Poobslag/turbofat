extends Node
"""
Stores information about the current level.
"""

# emitted after the level has customized the puzzle's settings.
signal settings_changed

# emitted when the 'best_result' field changes, such as when starting or clearing a level.
signal best_result_changed

# If 'true' then the level is one which the player might keep retrying, even after clearing it.
# This is especially true for practice levels such as the 3 minute sprint level.
var keep_retrying := false

# The settings for the level currently being launched or played
var settings := LevelSettings.new() setget switch_level

# The puzzle scene
var puzzle: Puzzle

# The level which was originally launched. Some tutorial levels transition
# into other levels, so this keeps track of the original.
var level_id: String

# The creature who launched the level.
var creature_id: String

# The customers to queue up at the start of the level. If absent, random customers will be queued.
var customer_ids: Array

# The creature who will be the chef for the level. If absent, the player will be the chef.
var chef_id: String

# Tracks when the player finishes a level.
var best_result: int = Levels.Result.NONE setget set_best_result

# Tracks whether or not the player wants to play/skip this level's cutscene.
var cutscene_force: int = Levels.CutsceneForce.NONE

func _ready() -> void:
	Breadcrumb.connect("before_scene_changed", self, "_on_Breadcrumb_before_scene_changed")


"""
Unsets all of the 'launched level' data.

This ensures the overworld will allow free roam and not try to play a cutscene.
"""
func clear_launched_level() -> void:
	set_launched_level("")


"""
Sets the launched level data.

Some tutorial levels transition into other levels, so this keeps track of the original. These properties also
used on the overworld to track whether or not it should play a cutscene or allow free roam.

Parameters:
	'level_id': The level to launch
"""
func set_launched_level(new_level_id: String) -> void:
	level_id = new_level_id
	var level_lock: LevelLock
	if level_id:
		level_lock = LevelLibrary.level_lock(level_id)
	
	set_best_result(Levels.Result.NONE)
	cutscene_force = Levels.CutsceneForce.NONE
	
	if level_lock:
		creature_id = level_lock.creature_id
		customer_ids = level_lock.customer_ids
		chef_id = level_lock.chef_id
	else:
		creature_id = ""
		customer_ids = []
		chef_id = ""


func start_level(new_settings: LevelSettings) -> void:
	level_id = new_settings.id
	PuzzleState.reset()
	switch_level(new_settings)


func switch_level(new_settings: LevelSettings) -> void:
	settings = new_settings
	emit_signal("settings_changed")


"""
Returns 'true' if the specified cutscene should be played.

We skip cutscenes if the player's seen them already, or if its 'skip_if' condition is met. This can be overridden with
the 'cutscene_force' field which the player can configure on the level select screen.

Parameters:
	'chat_tree': The cutscene to evaluate.
	
	'ignore_player_preferences': If 'true', the player's preferences will be ignored, and the method will only
		check whether the player's seen the cutscene and whether its 'skip_if' condition is met.
"""
func should_play_cutscene(chat_tree: ChatTree, ignore_player_preferences = false) -> bool:
	var result := true
	if not chat_tree:
		# return 'false' to account for levels without cutscenes
		result = false
	elif not ignore_player_preferences and cutscene_force == Levels.CutsceneForce.SKIP:
		# player wants to skip this cutscene
		result = false
	elif not ignore_player_preferences and cutscene_force == Levels.CutsceneForce.PLAY:
		# player wants to play this cutscene
		result = true
	elif PlayerData.chat_history.is_chat_finished(chat_tree.history_key):
		# skip repeated cutscenes
		result = false
	elif chat_tree.meta and chat_tree.meta.get("skip_if") \
			and BoolExpressionEvaluator.evaluate(chat_tree.meta.get("skip_if")):
		# skip cutscenes if their 'skip_if' condition is met
		result = false
	return result


"""
Launches a puzzle scene with the previously specified 'launched level' settings.
"""
func push_level_trail() -> void:
	var level_settings := LevelSettings.new()
	level_settings.load_from_resource(level_id)
	
	# When the player first launches the game and does the tutorial, we skip the typical puzzle intro.
	if level_id == LevelLibrary.BEGINNER_TUTORIAL \
			and not PlayerData.level_history.is_level_finished(LevelLibrary.BEGINNER_TUTORIAL):
		level_settings.other.skip_intro = true
	
	start_level(level_settings)
	for launched_customer_id_obj in customer_ids:
		var launched_customer_id: String = launched_customer_id_obj
		var creature_def: CreatureDef = PlayerData.creature_library.get_creature_def(launched_customer_id)
		PlayerData.creature_queue.primary_queue.push_front(creature_def)
	SceneTransition.push_trail(Global.SCENE_PUZZLE)


func set_best_result(new_best_result: int) -> void:
	best_result = new_best_result
	emit_signal("best_result_changed")


"""
Purges all node instances from the singleton.

Because CurrentLevel is a singleton, node instances should be purged before changing scenes. Otherwise they'll
continue consuming resources and could cause side effects.
"""
func _on_Breadcrumb_before_scene_changed() -> void:
	puzzle = null
