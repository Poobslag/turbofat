extends "res://addons/gut/test.gd"

func before_each() -> void:
	PuzzleState.reset()


func test_after_lines_cleared_phase_config() -> void:
	var condition: PhaseConditions.AfterLinesClearedPhaseCondition
	condition = PhaseConditions.AfterLinesClearedPhaseCondition.new({"y": "2"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "2"})
	
	condition = PhaseConditions.AfterLinesClearedPhaseCondition.new({"y": "1,3,5"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "1,3,5"})
	
	condition = PhaseConditions.AfterLinesClearedPhaseCondition.new({"y": "0-3"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "0-3"})
	
	condition = PhaseConditions.AfterLinesClearedPhaseCondition.new({"y": "0,4-6"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "0,4-6"})


func test_after_piece_written_phase_condition() -> void:
	var condition: PhaseConditions.AfterPieceWrittenPhaseCondition
	condition = PhaseConditions.AfterPieceWrittenPhaseCondition.new({"n": "6"})
	assert_eq_shallow(condition.get_phase_config(), {"n": "6"})


func test_after_piece_written_phase_condition_count_by_sixes() -> void:
	var condition: PhaseConditions.AfterPieceWrittenPhaseCondition
	condition = PhaseConditions.AfterPieceWrittenPhaseCondition.new({"n": "5,11,17..."})
	
	PuzzleState.level_performance.pieces = 0
	assert_eq(condition.should_run({}), false, "5,11,17...: 0")
	
	PuzzleState.level_performance.pieces = 5
	assert_eq(condition.should_run({}), true, "5,11,17...: 5")
	
	PuzzleState.level_performance.pieces = 10
	assert_eq(condition.should_run({}), false, "5,11,17...: 10")
	
	PuzzleState.level_performance.pieces = 11
	assert_eq(condition.should_run({}), true, "5,11,17...: 11")
	
	PuzzleState.level_performance.pieces = 41
	assert_eq(condition.should_run({}), true, "5,11,17...: 41")


func test_after_piece_written_specific_values() -> void:
	var condition: PhaseConditions.AfterPieceWrittenPhaseCondition
	condition = PhaseConditions.AfterPieceWrittenPhaseCondition.new({"n": "0,1,2"})
	
	PuzzleState.level_performance.pieces = 0
	assert_eq(condition.should_run({}), true, "0,1,2: 0")
	
	PuzzleState.level_performance.pieces = 1
	assert_eq(condition.should_run({}), true, "0,1,2: 1")
	
	PuzzleState.level_performance.pieces = 2
	assert_eq(condition.should_run({}), true, "0,1,2: 2")
	
	PuzzleState.level_performance.pieces = 3
	assert_eq(condition.should_run({}), false, "0,1,2: 3")


func test_after_piece_written_skip_early_values() -> void:
	var condition: PhaseConditions.AfterPieceWrittenPhaseCondition
	condition = PhaseConditions.AfterPieceWrittenPhaseCondition.new({"n": "10,11,12..."})
	
	PuzzleState.level_performance.pieces = 0
	assert_eq(condition.should_run({}), false, "10,11,12...: 0")
	
	PuzzleState.level_performance.pieces = 10
	assert_eq(condition.should_run({}), true, "10,11,12...: 10")
	
	PuzzleState.level_performance.pieces = 13
	assert_eq(condition.should_run({}), true, "10,11,12...: 13")
