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
	$VBoxContainer/Mode.set_scenario(_get_scenario())
	$VBoxContainer/HighScores.set_scenario(_get_scenario())


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
