extends Control
"""
Scene which lets the player repeatedly play a set of scenarios.

Displays their daily and all-time high scores for each mode, encouraging the player to improve.
"""

# Rank required to unlock harder levels. Rank 24 is an S-
const RANK_TO_UNLOCK := 24.0

"""
Array of scenario categories used to initialize the scene.
[0]: Mode name, used to reference the mode selector
[1]: Difficulty name, used to populate the difficulty selector
[2]: Scenario name, used to load the scenario definitions
"""
const SCENARIO_CATEGORIES := [
	["Survival", "Normal", "survival-normal"],
	["Survival", "Hard", "survival-hard"],
	["Survival", "Expert", "survival-expert"],
	["Survival", "Master", "survival-master"],
	
	["Ultra", "Normal", "ultra-normal"],
	["Ultra", "Hard", "ultra-hard"],
	["Ultra", "Expert", "ultra-expert"],
	
	["Sprint", "Normal", "sprint-normal"],
	["Sprint", "Expert", "sprint-expert"],
	
	["Rank", "7k", "rank-7k"],
	["Rank", "6k", "rank-6k"],
	["Rank", "5k", "rank-5k"],
	["Rank", "4k", "rank-4k"],
	["Rank", "3k", "rank-3k"],
	["Rank", "2k", "rank-2k"],
	["Rank", "1k", "rank-1k"],
	["Rank", "1d", "rank-1d"],
	["Rank", "2d", "rank-2d"],
	["Rank", "3d", "rank-3d"],
	["Rank", "4d", "rank-4d"],
	["Rank", "5d", "rank-5d"],
	["Rank", "6d", "rank-6d"],
	["Rank", "7d", "rank-7d"],
	["Rank", "8d", "rank-8d"],
	["Rank", "9d", "rank-9d"],
	["Rank", "10d", "rank-10d"],
	["Rank", "M", "rank-m"],
]

"""
Key: Mode names, 'Survival', 'Ultra'
Value: Difficulty names, 'Normal', 'Hard'
"""
var mode_difficulties: Dictionary

"""
Key: Mode/Difficulty names separated with a space, 'Survival Normal', 'Ultra Hard'
Value: Scenario names, 'survival-normal', 'ultra-hard'
"""
var scenarios: Dictionary

var _rank_lowlights := []

func _ready() -> void:
	# default mode/difficulty if the player hasn't played a scenario recently
	var current_mode: String = "Ultra"
	var current_difficulty: String = "Normal"
	var current_scenario_name: String = "ultra-normal"
	
	for category_obj in SCENARIO_CATEGORIES:
		var category: Array = category_obj
		var mode: String = category[0]
		var difficulty: String = category[1]
		var scenario_name: String = category[2]
		if not mode_difficulties.has(mode):
			mode_difficulties[mode] = []
		mode_difficulties[mode].append(difficulty)
		scenarios["%s %s" % [mode, difficulty]] = ScenarioLibrary.load_scenario_from_name(scenario_name)
		
		if scenario_name == Global.scenario_settings.name:
			# if they've just played a practice mode scenario, we default to that scenario
			current_mode = mode
			current_scenario_name = scenario_name
			current_difficulty = difficulty
	
	# grab focus so the player can navigate with the keyboard
	$VBoxContainer/System/Start.grab_focus()
	
	# populate the UI with their selected scenario
	$VBoxContainer/Mode.set_selected_mode(current_mode)
	_refresh()
	$VBoxContainer/Difficulty.set_selected_difficulty(current_difficulty)


func _refresh() -> void:
	$VBoxContainer/Difficulty.set_difficulty_names(mode_difficulties[_get_mode()])
	if _get_mode() == "Rank":
		_calculate_lowlights()
		$VBoxContainer/Difficulty.set_difficulty_lowlights(_rank_lowlights)
	$VBoxContainer/Mode.set_scenario(_get_scenario())
	$VBoxContainer/HighScores.set_scenario(_get_scenario())


"""
Calculates the lowlights for rank difficulties, if they have not yet been calculated.

This calculation is complex and involves iterating over all of the player's performances for all of the rank
scenarios, so we cache the result.
"""
func _calculate_lowlights() -> void:
	if _rank_lowlights:
		# already calculated
		return
	
	for difficulty in mode_difficulties[_get_mode()]:
		var scenario: ScenarioSettings = scenarios["%s %s" % [_get_mode(), difficulty]]
		_rank_lowlights.append(_calculate_lowlight(scenario))


"""
Calculates whether the specified scenario should be lowlighted.

If the player achieved the success condition without losing, the scenario appears lit up. Otherwise it's lowlighted.
"""
func _calculate_lowlight(scenario: ScenarioSettings) -> bool:
	var best_results: Array = PlayerData.scenario_history.best_results(scenario.name, false)
	if not best_results:
		return true
	
	var success: bool
	var best_result: RankResult = best_results[0]
	if best_result.lost:
		success = false
	elif scenario.success_condition.type == Milestone.TIME_UNDER:
		success = best_result.seconds <= scenario.success_condition.value
	else:
		success = best_result.score >= scenario.success_condition.value
	return not success


func _get_mode() -> String:
	return $VBoxContainer/Mode.get_selected_mode()


func _get_difficulty() -> String:
	return $VBoxContainer/Difficulty.get_selected_difficulty()


func _get_scenario() -> ScenarioSettings:
	return scenarios["%s %s" % [_get_mode(), _get_difficulty()]]


func _on_Difficulty_difficulty_changed() -> void:
	_refresh()


func _on_Mode_mode_changed() -> void:
	_refresh()


func _on_Start_pressed() -> void:
	Global.overworld_puzzle = false
	ScenarioLibrary.push_scenario_trail(_get_scenario())
