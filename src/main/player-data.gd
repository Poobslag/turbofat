extends Node
"""
Stores data about the player's progress in memory.

This data includes how well they've done on each level and how much money they've earned.
"""

signal money_changed(value)

"""
Stores every RankResult the player has received for different scenarios. This is currently used for calculating high
scores, but could eventually be used for displaying statistics or calculating rewards.

key: (String) Scenario name 
value: (Array) All RankResults for the specified scenario
"""
var scenario_history := {}

var volume_settings := VolumeSettings.new()

var money := 0 setget set_money

# how many records we can store before we start deleting old ones
var history_size := 1000

var _rank_calculator := RankCalculator.new()

"""
Resets the player's in-memory data to a default state.
"""
func reset() -> void:
	scenario_history.clear()
	money = 0
	volume_settings.reset_to_default()


"""
Returns a player's best performances for a specific scenario.

Parameters:
	'scenario': The name of the scenario to evaluate
	
	'daily': If true, only performances with today's date are included
	
	'property': (Optional) The property evaluated to determine which of the player's RankResults was the best, such
		as 'score' or 'seconds'. Defaults to 'score'.
"""
func get_best_scenario_results(scenario: String, daily: bool, property: String = "score") -> Array:
	if not scenario_history.has(scenario):
		return []
	
	var results: Array = scenario_history[scenario].duplicate()
	if daily:
		# only include items with today's date
		var now := OS.get_datetime()
		var daily_results := []
		for result_obj in results:
			var result: RankResult = result_obj
			if result.timestamp["year"] == now["year"] \
					and result.timestamp["month"] == now["month"] \
					and result.timestamp["day"] == now["day"]:
				daily_results.append(result)
		results = daily_results
	
	if property == "seconds":
		results.sort_custom(self, "_compare_by_seconds")
	else:
		results.sort_custom(self, "_compare_by_score")
	return results


func _compare_by_seconds(a: RankResult, b: RankResult) -> bool:
	# when comparing seconds, dying disqualifies you
	if a.lost and b.lost:
		return a.lines > b.lines
	if a.lost != b.lost:
		return b.lost
	# when comparing seconds, lower is better
	return a.seconds < b.seconds


func _compare_by_score(a: RankResult, b: RankResult) -> bool:
	return a.score > b.score


func get_last_scenario_result(scenario: String) -> RankResult:
	if not scenario_history.has(scenario) or scenario_history[scenario].empty():
		return null
	return scenario_history[scenario][0]


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
