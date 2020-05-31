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
func results(scenario: String) -> Array:
	return rank_results.get(scenario, [])


"""
Returns a player's best performances for a specific scenario.

Parameters:
	'scenario': The name of the scenario to evaluate
	
	'daily': If true, only performances with today's date are included
	
	'property': (Optional) The property evaluated to determine which of the player's RankResults was the best, such
		as 'score' or 'seconds'. Defaults to 'score'.
"""
func best_results(scenario: String, daily: bool) -> Array:
	if not rank_results.has(scenario):
		return []
	
	var results: Array = rank_results[scenario].duplicate()
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
	return results.slice(0, max_size - 1)


func prev_result(scenario: String) -> RankResult:
	if not rank_results.has(scenario) or rank_results[scenario].empty():
		return null
	return rank_results[scenario][0]


"""
Records the current scenario performance to the player's history.

'add' should be followed by 'prune' to ensure the history does not grow too large.
"""
func add(scenario: String, rank_result: RankResult) -> void:
	if not scenario:
		# can't store history without a scenario name
		return
	
	if not rank_results.has(scenario):
		rank_results[scenario] = []
	rank_results[scenario].push_front(rank_result)


func has(scenario: String) -> bool:
	return rank_results.has(scenario) and rank_results.get(scenario).size() >= 1


"""
Prunes the history down to only the best daily results, best all-time results, and the most recent result.
"""
func prune(scenario: String) -> void:
	if not has(scenario):
		return
	
	# collect the best scores, but reinsert the newest score at index 0 for prev_result()
	var best: Dictionary = {}
	for result in best_results(scenario, false) + best_results(scenario, true):
		best[result] = ""
	best.erase(rank_results[scenario][0])
	rank_results[scenario] = [rank_results[scenario][0]] + best.keys()


func _compare_by_low_seconds(a: RankResult, b: RankResult) -> bool:
	# when comparing seconds, dying disqualifies you
	if a.lost and b.lost:
		return a.score > b.score
	if a.lost != b.lost:
		return b.lost
	# when comparing seconds, lower is better
	return a.seconds < b.seconds


func _compare_by_high_score(a: RankResult, b: RankResult) -> bool:
	return a.score > b.score
