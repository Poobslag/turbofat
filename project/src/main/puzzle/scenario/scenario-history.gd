class_name ScenarioHistory
"""
Stores the best results the player has achieved for different scenarios. This is currently used for calculating high
scores, but could eventually be used for displaying statistics or calculating rewards.
"""

# how many daily and all-time records we can store before we start deleting old ones
var max_size := 3

# key: scenario name
# value: array of RankResults for the specified scenario
var rank_results := {}

# key: scenario name
# value: date when the player was first successful at the scenario
var successful_scenarios := {}

# key: scenario name
# value: date when the player first finished the scenario
var finished_scenarios := {}

func scenario_names() -> Array:
	return rank_results.keys()


"""
Resets the scenario history to its default empty state.
"""
func reset() -> void:
	rank_results.clear()


"""
Returns a player's performances for a specific scenario.
"""
func results(scenario_id: String) -> Array:
	return rank_results.get(scenario_id, [])


"""
Returns a player's best performance for a specific scenario.

Parameters:
	'scenario_id': The id of the scenario to evaluate
	
	'daily': (Optional) If true, only performances with today's date are included
"""
func best_result(scenario_id: String, daily: bool = false) -> RankResult:
	var best_result: RankResult
	var best_results := best_results(scenario_id, daily)
	if best_results:
		best_result = best_results[0]
	return best_result


"""
Returns a player's best performances for a specific scenario.

Parameters:
	'scenario_id': The id of the scenario to evaluate
	
	'daily': (Optional) If true, only performances with today's date are included
"""
func best_results(scenario_id: String, daily: bool = false) -> Array:
	if not rank_results.has(scenario_id):
		return []
	
	var results: Array = rank_results[scenario_id].duplicate()
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
	
	if results:
		# sort results
		var result: RankResult = results[0]
		match result.compare:
			"-seconds":
				results.sort_custom(self, "_compare_by_low_seconds")
			_:
				results.sort_custom(self, "_compare_by_high_score")
	return results.slice(0, min(results.size() - 1, max_size - 1))


func prev_result(scenario_id: String) -> RankResult:
	if not rank_results.has(scenario_id) or rank_results[scenario_id].empty():
		return null
	return rank_results[scenario_id][0]


"""
Records the current scenario performance to the player's history.

'add' should be followed by 'prune' to ensure the history does not grow too large.
"""
func add(scenario_id: String, rank_result: RankResult) -> void:
	if not scenario_id:
		# can't store history without a scenario id
		return
	
	if not rank_results.has(scenario_id):
		rank_results[scenario_id] = []
	rank_results[scenario_id].push_front(rank_result)
	if rank_result.success and not successful_scenarios.has(scenario_id):
		successful_scenarios[scenario_id] = OS.get_datetime()
	if not rank_result.lost and not successful_scenarios.has(scenario_id):
		finished_scenarios[scenario_id] = OS.get_datetime()


func has(scenario_id: String) -> bool:
	return rank_results.has(scenario_id) and rank_results.get(scenario_id).size() >= 1


"""
Prunes the history down to only the best daily results, best all-time results, and the most recent result.
"""
func prune(scenario_id: String) -> void:
	if not has(scenario_id):
		return
	
	# collect the best scores, but reinsert the newest score at index 0 for prev_result()
	var best: Dictionary = {}
	for result in best_results(scenario_id, false) + best_results(scenario_id, true):
		best[result] = ""
	best.erase(rank_results[scenario_id][0])
	rank_results[scenario_id] = [rank_results[scenario_id][0]] + best.keys()


func _compare_by_low_seconds(a: RankResult, b: RankResult) -> bool:
	# when comparing seconds, dying disqualifies you
	if a.lost and b.lost:
		return a.score > b.score
	if a.lost != b.lost:
		return b.lost
	if a.success != b.success:
		return a.success
	# when comparing seconds, lower is better
	return a.seconds < b.seconds


func _compare_by_high_score(a: RankResult, b: RankResult) -> bool:
	if a.success != b.success:
		# succeeding is more important than getting a high score, especially for survival challenges.
		return a.success
	return a.score > b.score
