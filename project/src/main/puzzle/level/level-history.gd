class_name LevelHistory
## Stores the best results the player has achieved for different levels. This is currently used for calculating high
## scores, but could eventually be used for displaying statistics or calculating rewards.

## how many daily and all-time records we can store before we start deleting old ones
var max_size := 3

## key: level name
## value: array of RankResults for the specified level
var rank_results := {}

## key: level name
## value: date when the player was first successful at the level
var successful_levels := {}

## key: level name
## value: Date when the player first finished the level. Losing or quitting does not count as finishing.
var finished_levels := {}

func level_names() -> Array:
	return rank_results.keys()


## Resets the level history to its default empty state.
func reset() -> void:
	rank_results.clear()
	successful_levels.clear()
	finished_levels.clear()


## Returns a player's performances for a specific level.
func results(level_id: String) -> Array:
	return rank_results.get(level_id, [])


## Returns a player's best performance for a specific level.
##
## Parameters:
## 	'level_id': The id of the level to evaluate
##
## 	'daily': (Optional) If true, only performances with today's date are included
func best_result(level_id: String, daily: bool = false) -> RankResult:
	var best_result: RankResult
	var best_results := best_results(level_id, daily)
	if best_results:
		best_result = best_results[0]
	return best_result


## Returns a player's best performances for a specific level.
##
## Parameters:
## 	'level_id': The id of the level to evaluate
##
## 	'daily': (Optional) If true, only performances with today's date are included
func best_results(level_id: String, daily: bool = false) -> Array:
	if not rank_results.has(level_id):
		return []
	
	var results: Array = rank_results[level_id].duplicate()
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


func prev_result(level_id: String) -> RankResult:
	if not rank_results.has(level_id) or rank_results[level_id].empty():
		return null
	return rank_results[level_id][0]


## Records the current level performance to the player's history.
##
## 'add' should be followed by 'prune' to ensure the history does not grow too large.
func add(level_id: String, rank_result: RankResult) -> void:
	if not level_id:
		# can't store history without a level id
		return
	
	if not rank_results.has(level_id):
		rank_results[level_id] = []
	rank_results[level_id].push_front(rank_result)
	if rank_result.success and not successful_levels.has(level_id):
		successful_levels[level_id] = OS.get_datetime()
	if not rank_result.lost and not successful_levels.has(level_id):
		finished_levels[level_id] = OS.get_datetime()


## Deletes all records of the specified level from the player's history.
##
## Returns:
## 	'true' if the key was present in the player's history, false otherwise.
func delete(level_id: String) -> bool:
	var success := rank_results.erase(level_id)
	successful_levels.erase(level_id)
	finished_levels.erase(level_id)
	return success


func has(level_id: String) -> bool:
	return rank_results.has(level_id) and rank_results.get(level_id).size() >= 1


## Prunes the history down to only the best daily results, best all-time results, and the most recent result.
func prune(level_id: String) -> void:
	if not has(level_id):
		return
	
	# collect the best scores, but reinsert the newest score at index 0 for prev_result()
	var best := {}
	for result in best_results(level_id, false) + best_results(level_id, true):
		best[result] = ""
	best.erase(rank_results[level_id][0])
	rank_results[level_id] = [rank_results[level_id][0]] + best.keys()


## Returns 'true' if the level has been finished. Losing or quitting does not count as finishing.
func is_level_finished(level_id: String) -> bool:
	return finished_levels.has(level_id)


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
		# succeeding is more important than getting a high score, especially for marathon challenges.
		return a.success
	return a.score > b.score
