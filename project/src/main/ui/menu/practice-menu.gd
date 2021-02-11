extends Control
"""
Scene which lets the player repeatedly play a set of levels.

Displays their daily and all-time high scores for each mode, encouraging the player to improve.
"""

# Rank required to unlock harder levels. Rank 24 is an S-
const RANK_TO_UNLOCK := 24.0

"""
Array of level categories used to initialize the scene.
[0]: Mode name, used to reference the mode selector
[1]: Difficulty name, used to populate the difficulty selector
[2]: Level name, used to load the level definitions
"""
const LEVEL_CATEGORIES := [
	["Survival", "Normal", "practice/survival_normal"],
	["Survival", "Hard", "practice/survival_hard"],
	["Survival", "Expert", "practice/survival_expert"],
	["Survival", "Master", "practice/survival_master"],
	
	["Ultra", "Normal", "practice/ultra_normal"],
	["Ultra", "Hard", "practice/ultra_hard"],
	["Ultra", "Expert", "practice/ultra_expert"],
	
	["Sprint", "Normal", "practice/sprint_normal"],
	["Sprint", "Expert", "practice/sprint_expert"],
	
	["Rank", "7k", "rank/7k"],
	["Rank", "6k", "rank/6k"],
	["Rank", "5k", "rank/5k"],
	["Rank", "4k", "rank/4k"],
	["Rank", "3k", "rank/3k"],
	["Rank", "2k", "rank/2k"],
	["Rank", "1k", "rank/1k"],
	["Rank", "1d", "rank/1d"],
	["Rank", "2d", "rank/2d"],
	["Rank", "3d", "rank/3d"],
	["Rank", "4d", "rank/4d"],
	["Rank", "5d", "rank/5d"],
	["Rank", "6d", "rank/6d"],
	["Rank", "7d", "rank/7d"],
	["Rank", "8d", "rank/8d"],
	["Rank", "9d", "rank/9d"],
	["Rank", "10d", "rank/10d"],
	["Rank", "M", "rank/m"],
	
	["Sandbox", "Normal", "practice/sandbox_normal"],
	["Sandbox", "Hard", "practice/sandbox_hard"],
	["Sandbox", "Expert", "practice/sandbox_expert"],
	["Sandbox", "Master", "practice/sandbox_master"],
]

"""
Key: Mode names, 'Survival', 'Ultra'
Value: Difficulty names, 'Normal', 'Hard'
"""
var mode_difficulties: Dictionary

"""
Key: Mode/Difficulty names separated with a space, 'Survival Normal', 'Ultra Hard'
Value: Level names, 'survival_normal', 'ultra_hard'
"""
var levels: Dictionary

var _rank_lowlights := []

func _ready() -> void:
	ResourceCache.substitute_singletons()
	
	# default mode/difficulty if the player hasn't played a level recently
	var current_mode: String = "Ultra"
	var current_difficulty: String = "Normal"
	
	for category_obj in LEVEL_CATEGORIES:
		var category: Array = category_obj
		var mode: String = category[0]
		var difficulty: String = category[1]
		var level_id: String = category[2]
		if not mode_difficulties.has(mode):
			mode_difficulties[mode] = []
		mode_difficulties[mode].append(difficulty)
		
		var settings: LevelSettings = LevelSettings.new()
		settings.load_from_resource(level_id)
		levels["%s %s" % [mode, difficulty]] = settings
		
		if level_id == Level.settings.id:
			# if they've just played a practice mode level, we default to that level
			current_mode = mode
			current_difficulty = difficulty
	
	# grab focus so the player can navigate with the keyboard
	$VBoxContainer/System/Start.grab_focus()
	
	# populate the UI with their selected level
	$VBoxContainer/Mode.set_selected_mode(current_mode)
	_refresh()
	$VBoxContainer/Difficulty.set_selected_difficulty(current_difficulty)


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _refresh() -> void:
	$VBoxContainer/Difficulty.set_difficulty_names(mode_difficulties[_get_mode()])
	if _get_mode() == "Rank":
		_calculate_lowlights()
		$VBoxContainer/Difficulty.set_difficulty_lowlights(_rank_lowlights)
	$VBoxContainer/Mode.set_level(_get_level())
	$VBoxContainer/HighScores.set_level(_get_level())


"""
Calculates the lowlights for rank difficulties, if they have not yet been calculated.

This calculation is complex and involves iterating over all of the player's performances for all of the rank
levels, so we cache the result.
"""
func _calculate_lowlights() -> void:
	if _rank_lowlights:
		# already calculated
		return
	
	for difficulty in mode_difficulties[_get_mode()]:
		var level: LevelSettings = levels["%s %s" % [_get_mode(), difficulty]]
		_rank_lowlights.append(not PlayerData.level_history.successful_levels.has(level.id))


func _get_mode() -> String:
	return $VBoxContainer/Mode.get_selected_mode()


func _get_difficulty() -> String:
	return $VBoxContainer/Difficulty.get_selected_difficulty()


func _get_level() -> LevelSettings:
	return levels["%s %s" % [_get_mode(), _get_difficulty()]]


func _on_Difficulty_difficulty_changed() -> void:
	_refresh()


func _on_Mode_mode_changed() -> void:
	_refresh()


func _on_Start_pressed() -> void:
	Level.set_launched_level(_get_level().id)
	# upon completion, practice levels default to 'retry'
	Level.keep_retrying = true
	Level.push_level_trail()
