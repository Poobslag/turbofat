extends "res://addons/gut/test.gd"

func before_each() -> void:
	PuzzleState.reset()


func test_line_cleared_phase_config() -> void:
	var condition: PhaseConditions.LineClearedPhaseCondition
	condition = PhaseConditions.LineClearedPhaseCondition.new({"y": "2"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "2"})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"y": "1,3,5"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "1,3,5"})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"y": "0-3"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "0-3"})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"y": "0,4-6"})
	assert_eq_shallow(condition.get_phase_config(), {"y": "0,4-6"})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"n": "1,2,3..."})
	assert_eq_shallow(condition.get_phase_config(), {"n": "1,2,3..."})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"combo": "1,2,3..."})
	assert_eq_shallow(condition.get_phase_config(), {"combo": "1,2,3..."})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({})
	assert_eq_shallow(condition.get_phase_config(), {})


func test_box_built_phase_condition() -> void:
	var condition: PhaseConditions.BoxBuiltPhaseCondition
	condition = PhaseConditions.BoxBuiltPhaseCondition.new({"0": "snack"})
	assert_eq_shallow(condition.get_phase_config(), {"0": "snack"})
	
	condition = PhaseConditions.BoxBuiltPhaseCondition.new({"0": "cake"})
	assert_eq_shallow(condition.get_phase_config(), {"0": "cake"})
	
	condition = PhaseConditions.BoxBuiltPhaseCondition.new({"0": "any"})
	assert_eq_shallow(condition.get_phase_config(), {})


func test_combo_ended_phase_condition() -> void:
	var condition: PhaseConditions.ComboEndedPhaseCondition
	condition = PhaseConditions.ComboEndedPhaseCondition.new({})
	assert_eq_shallow(condition.get_phase_config(), {})
	
	condition = PhaseConditions.ComboEndedPhaseCondition.new({"combo": "5-10"})
	assert_eq_shallow(condition.get_phase_config(), {"combo": "5-10"})


func test_pickup_collected() -> void:
	var condition: PhaseConditions.PickupCollectedPhaseCondition
	condition = PhaseConditions.PickupCollectedPhaseCondition.new({})
	assert_eq_shallow(condition.get_phase_config(), {})
	
	condition = PhaseConditions.PickupCollectedPhaseCondition.new({"0": "snack"})
	assert_eq_shallow(condition.get_phase_config(), {"0": "snack"})
	
	condition = PhaseConditions.PickupCollectedPhaseCondition.new({"0": "cake"})
	assert_eq_shallow(condition.get_phase_config(), {"0": "cake"})


func test_piece_written_phase_condition() -> void:
	var condition: PhaseConditions.PieceWrittenPhaseCondition
	condition = PhaseConditions.PieceWrittenPhaseCondition.new({"n": "6"})
	assert_eq_shallow(condition.get_phase_config(), {"n": "6"})


func test_piece_written_phase_condition_count_by_sixes() -> void:
	var condition: PhaseConditions.PieceWrittenPhaseCondition
	condition = PhaseConditions.PieceWrittenPhaseCondition.new({"n": "5,11,17..."})
	
	PuzzleState.level_performance.pieces = 1
	assert_eq(condition.should_run({}), false, "5,11,17...: 0")
	
	PuzzleState.level_performance.pieces = 6
	assert_eq(condition.should_run({}), true, "5,11,17...: 5")
	
	PuzzleState.level_performance.pieces = 11
	assert_eq(condition.should_run({}), false, "5,11,17...: 10")
	
	PuzzleState.level_performance.pieces = 12
	assert_eq(condition.should_run({}), true, "5,11,17...: 11")
	
	PuzzleState.level_performance.pieces = 42
	assert_eq(condition.should_run({}), true, "5,11,17...: 41")


func test_piece_written_specific_values() -> void:
	var condition: PhaseConditions.PieceWrittenPhaseCondition
	condition = PhaseConditions.PieceWrittenPhaseCondition.new({"n": "0,1,2"})
	
	PuzzleState.level_performance.pieces = 1
	assert_eq(condition.should_run({}), true, "0,1,2: 0")
	
	PuzzleState.level_performance.pieces = 2
	assert_eq(condition.should_run({}), true, "0,1,2: 1")
	
	PuzzleState.level_performance.pieces = 3
	assert_eq(condition.should_run({}), true, "0,1,2: 2")
	
	PuzzleState.level_performance.pieces = 4
	assert_eq(condition.should_run({}), false, "0,1,2: 3")


func test_piece_written_skip_early_values() -> void:
	var condition: PhaseConditions.PieceWrittenPhaseCondition
	condition = PhaseConditions.PieceWrittenPhaseCondition.new({"n": "10,11,12..."})
	
	PuzzleState.level_performance.pieces = 1
	assert_eq(condition.should_run({}), false, "10,11,12...: 0")
	
	PuzzleState.level_performance.pieces = 11
	assert_eq(condition.should_run({}), true, "10,11,12...: 10")
	
	PuzzleState.level_performance.pieces = 14
	assert_eq(condition.should_run({}), true, "10,11,12...: 13")
