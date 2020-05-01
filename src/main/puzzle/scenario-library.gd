extends Node
"""
Stores different kinds of puzzle scenarios.
"""

var sprint_normal : ScenarioSettings;
var sprint_expert : ScenarioSettings;

var ultra_normal : ScenarioSettings;
var ultra_hard : ScenarioSettings;
var ultra_expert : ScenarioSettings;

var marathon_normal : ScenarioSettings;
var marathon_hard : ScenarioSettings;
var marathon_expert : ScenarioSettings;
var marathon_master : ScenarioSettings;

func _ready() -> void:
	marathon_normal  = ScenarioSettings.new()
	marathon_normal.set_name("marathon-normal")
	marathon_normal.set_start_level(PieceSpeeds.beginner_level_0)
	marathon_normal.add_level_up("lines", 10, PieceSpeeds.beginner_level_1)
	marathon_normal.add_level_up("lines", 20, PieceSpeeds.beginner_level_2)
	marathon_normal.add_level_up("lines", 30, PieceSpeeds.beginner_level_3)
	marathon_normal.add_level_up("lines", 40, PieceSpeeds.beginner_level_4)
	marathon_normal.add_level_up("lines", 50, PieceSpeeds.beginner_level_5)
	marathon_normal.add_level_up("lines", 60, PieceSpeeds.beginner_level_6)
	marathon_normal.add_level_up("lines", 70, PieceSpeeds.beginner_level_7)
	marathon_normal.add_level_up("lines", 80, PieceSpeeds.beginner_level_8)
	marathon_normal.add_level_up("lines", 90, PieceSpeeds.beginner_level_9)
	marathon_normal.set_win_condition("lines", 100)

	marathon_hard = ScenarioSettings.new()
	marathon_hard.set_name("marathon-hard")
	marathon_hard.set_start_level(PieceSpeeds.hard_level_1)
	marathon_hard.add_level_up("lines", 50, PieceSpeeds.hard_level_2)
	marathon_hard.add_level_up("lines", 60, PieceSpeeds.hard_level_3)
	marathon_hard.add_level_up("lines", 70, PieceSpeeds.hard_level_4)
	marathon_hard.add_level_up("lines", 80, PieceSpeeds.hard_level_5)
	marathon_hard.add_level_up("lines", 90, PieceSpeeds.hard_level_6)
	marathon_hard.add_level_up("lines", 100, PieceSpeeds.hard_level_7)
	marathon_hard.add_level_up("lines", 115, PieceSpeeds.hard_level_8)
	marathon_hard.add_level_up("lines", 130, PieceSpeeds.hard_level_9)
	marathon_hard.add_level_up("lines", 150, PieceSpeeds.hard_level_10)
	marathon_hard.set_win_condition("lines", 200, 150)

	marathon_expert = ScenarioSettings.new()
	marathon_expert.set_name("marathon-expert")
	marathon_expert.set_start_level(PieceSpeeds.hard_level_5)
	marathon_expert.add_level_up("lines", 75, PieceSpeeds.hard_level_10)
	marathon_expert.add_level_up("lines", 100, PieceSpeeds.hard_level_11)
	marathon_expert.add_level_up("lines", 125, PieceSpeeds.hard_level_12)
	marathon_expert.add_level_up("lines", 150, PieceSpeeds.hard_level_13)
	marathon_expert.add_level_up("lines", 175, PieceSpeeds.hard_level_14)
	marathon_expert.add_level_up("lines", 200, PieceSpeeds.hard_level_15)
	marathon_expert.set_win_condition("lines", 300, 200)
	
	marathon_master = ScenarioSettings.new()
	marathon_master.set_name("marathon-master")
	marathon_master.set_start_level(PieceSpeeds.crazy_level_2)
	marathon_master.add_level_up("lines", 100, PieceSpeeds.crazy_level_3)
	marathon_master.add_level_up("lines", 200, PieceSpeeds.crazy_level_4)
	marathon_master.add_level_up("lines", 300, PieceSpeeds.crazy_level_5)
	marathon_master.add_level_up("lines", 400, PieceSpeeds.crazy_level_6)
	marathon_master.add_level_up("lines", 500, PieceSpeeds.crazy_level_7)
	marathon_master.set_win_condition("lines", 1000, 500)
	
	sprint_normal = ScenarioSettings.new()
	sprint_normal.set_name("sprint-normal")
	sprint_normal.set_start_level(PieceSpeeds.hard_level_0)
	sprint_normal.set_win_condition("time", 150)
	
	sprint_expert = ScenarioSettings.new()
	sprint_expert.set_name("sprint-expert")
	sprint_expert.set_start_level(PieceSpeeds.crazy_level_0)
	sprint_expert.set_win_condition("time", 180)
	
	ultra_normal = ScenarioSettings.new()
	ultra_normal.set_name("ultra-normal")
	ultra_normal.set_start_level(PieceSpeeds.beginner_level_0)
	ultra_normal.set_win_condition("score", 200)
	
	ultra_hard = ScenarioSettings.new()
	ultra_hard.set_name("ultra-hard")
	ultra_hard.set_start_level(PieceSpeeds.hard_level_0)
	ultra_hard.set_win_condition("score", 1000)

	ultra_expert = ScenarioSettings.new()
	ultra_expert.set_name("ultra-expert")
	ultra_expert.set_start_level(PieceSpeeds.crazy_level_0)
	ultra_expert.set_win_condition("score", 3000)


"""
Launches a scenario scene with the specified puzzle settings.

Parameters:
	'scenario_settings': Defines the scenario's difficulty and win condition
	'overworld_puzzle': True if the player should return to the overworld when the puzzle is done
	'customer_def': Customers who should appear in the restaurant.
"""
func change_scenario_scene(scenario_settings: ScenarioSettings, overworld_puzzle: bool, customer_def: Dictionary = {}) -> void:
	Global.scenario_settings = scenario_settings
	Global.customer_queue.push_back(customer_def)
	Global.overworld_puzzle = overworld_puzzle
	get_tree().change_scene("res://src/main/puzzle/Scenario.tscn")
