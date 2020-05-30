extends "res://addons/gut/test.gd"
"""
Unit test demonstrating the reading/writing/pruning of history data.
"""

var _scenario_history := ScenarioHistory.new()

func before_each() -> void:
	_scenario_history.reset()


static func rank_result(score: int = 7890) -> RankResult:
	var result := RankResult.new()
	result.seconds = 600.0
	result.lines = 300
	result.box_score_per_line = 9.3
	result.combo_score_per_line = 17.0
	result.score = score
	return result


func test_prune_one() -> void:
	_scenario_history.add("scenario-895", rank_result(7890))
	_scenario_history.prune("scenario-895")
	
	assert_eq(_scenario_history.results("scenario-895")[0].score, 7890)


func test_prune_two() -> void:
	_scenario_history.add("scenario-895", rank_result(7890))
	_scenario_history.add("scenario-895", rank_result(6780))
	_scenario_history.prune("scenario-895")
	
	assert_eq(_scenario_history.results("scenario-895")[0].score, 6780)
	assert_eq(_scenario_history.results("scenario-895")[1].score, 7890)


func test_prune_many() -> void:
	_scenario_history.add("scenario-895", rank_result(500))
	_scenario_history.add("scenario-895", rank_result(700))
	_scenario_history.add("scenario-895", rank_result(30))
	_scenario_history.add("scenario-895", rank_result(10))
	_scenario_history.add("scenario-895", rank_result(600))
	_scenario_history.add("scenario-895", rank_result(20))
	_scenario_history.add("scenario-895", rank_result(40))
	assert_eq(_scenario_history.results("scenario-895").size(), 7)
	
	_scenario_history.prune("scenario-895")
	assert_eq(_scenario_history.results("scenario-895").size(), 4)


func test_prev_after_prune() -> void:
	_scenario_history.add("scenario-895", rank_result(500))
	_scenario_history.add("scenario-895", rank_result(700))
	_scenario_history.add("scenario-895", rank_result(30))
	_scenario_history.add("scenario-895", rank_result(10))
	_scenario_history.add("scenario-895", rank_result(600))
	_scenario_history.add("scenario-895", rank_result(20))
	_scenario_history.add("scenario-895", rank_result(40))
	_scenario_history.prune("scenario-895")
	
	assert_eq(_scenario_history.prev_result("scenario-895").score, 40)


func test_no_scenario_name() -> void:
	_scenario_history.add("", rank_result())
	assert_false(_scenario_history.scenario_names().has(""))
