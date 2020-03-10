extends "res://addons/gut/test.gd"

var RankCalculator = preload("res://scenes/RankCalculator.gd").new()

var rank_result

func before_each():
	ScenarioHistory.scenario_history_filename = "user://scenario_history_365.save"
	ScenarioHistory.scenario_history.clear()
	rank_result = RankCalculator.RankResult.new()
	rank_result.seconds = 600.0
	rank_result.lines = 300
	rank_result.box_score = 9.3
	rank_result.combo_score = 17.0
	rank_result.score = 7890

func after_each():
	ScenarioHistory.history_size = 1000

func test_one_history_entry():
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	assert_eq(ScenarioHistory.scenario_history["scenario-895"][0].score, 7890)

func test_two_history_entries():
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	rank_result = RankCalculator.RankResult.new()
	rank_result.score = 6780
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	assert_eq(ScenarioHistory.scenario_history["scenario-895"][0].score, 6780)
	assert_eq(ScenarioHistory.scenario_history["scenario-895"][1].score, 7890)

func test_too_many_history_entries():
	ScenarioHistory.history_size = 3
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	rank_result = RankCalculator.RankResult.new()
	rank_result.score = 6780
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	assert_eq(ScenarioHistory.scenario_history["scenario-895"].size(), 3)
	assert_eq(ScenarioHistory.scenario_history["scenario-895"][0].score, 6780)

func test_no_scenario_name():
	ScenarioHistory.add_scenario_history("", rank_result)
	assert_false(ScenarioHistory.scenario_history.has(""))

func test_save_and_load():
	ScenarioHistory.add_scenario_history("scenario-895", rank_result)
	ScenarioHistory.save_scenario_history()
	ScenarioHistory.scenario_history.clear()
	ScenarioHistory.load_scenario_history()
	assert_true(ScenarioHistory.scenario_history.has("scenario-895"))
	assert_eq(ScenarioHistory.scenario_history["scenario-895"][0].score, 7890)
