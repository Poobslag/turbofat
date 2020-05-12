extends Node
"""
Stores data about the player's progress in memory.

This data includes how well they've done on each level and how much money they've earned.
"""

signal money_changed(money)

"""
Stores every RankResult the player has received for different scenarios. This is currently used for calculating high
scores, but could eventually be used for displaying statistics or calculating rewards.

key: (String) Scenario name 
value: (Array) All RankResults for the specified scenario
"""
var scenario_history := {}

var money := 0 setget set_money

# how many records we can store before we start deleting old ones
var history_size := 1000

var _rank_calculator := RankCalculator.new()

"""
Calculates the best rank a player's received for a specific scenario.

Parameters:
	'scenario': The name of the scenario to evaluate
	
	'property': (Optional) The property evaluated to determine which of the player's RankResults was the best, such
		as 'score' or 'seconds'. Defaults to 'score'.
"""
func get_best_scenario_rank(scenario: String, property: String = "score") -> float:
	var best_rank_result := get_best_scenario_result(scenario, property)
	return best_rank_result.get(property + "_rank") if best_rank_result else 999.0


"""
Calculates the best rank a player's received for a specific scenario.

Parameters:
	'scenario': The name of the scenario to evaluate
	
	'property': (Optional) The property evaluated to determine which of the player's RankResults was the best, such
		as 'score' or 'seconds'. Defaults to 'score'.
"""
func get_best_scenario_result(scenario: String, property: String = "score") -> RankResult:
	var best_performance: RankResult
	if scenario_history.has(scenario):
		for rank_result in scenario_history[scenario]:
			if property == "seconds":
				if rank_result.died:
					# when comparing seconds, deaths disqualify your score
					pass
				elif best_performance == null or rank_result.get(property) < best_performance.get(property):
					# when comparing seconds, lower numbers are better
					best_performance = rank_result
			else:
				if best_performance == null or rank_result.get(property) > best_performance.get(property):
					best_performance = rank_result
	return best_performance


"""
Records the current scenario performance to the player's history.
"""
func add_scenario_history(scenario: String, rank_result: RankResult) -> void:
	if not scenario:
		# can't store history without a scenario name
		return
	
	if not scenario_history.has(scenario):
		scenario_history[scenario] = []
	scenario_history[scenario].push_front(rank_result)
	if scenario_history[scenario].size() > history_size:
		scenario_history[scenario].resize(history_size)


func set_money(new_money: int) -> void:
	money = new_money
	emit_signal("money_changed", money)
