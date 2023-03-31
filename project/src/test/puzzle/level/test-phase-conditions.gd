extends GutTest

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
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"n": "1..."})
	assert_eq_shallow(condition.get_phase_config(), {"n": "1..."})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"combo": "1..."})
	assert_eq_shallow(condition.get_phase_config(), {"combo": "1..."})
	
	condition = PhaseConditions.LineClearedPhaseCondition.new({"score": "200,500"})
	assert_eq_shallow(condition.get_phase_config(), {"score": "200,500"})
	
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
	condition = PhaseConditions.PieceWrittenPhaseCondition.new({"n": "6,12,18..."})
	
	PuzzleState.level_performance.pieces = 1
	assert_eq(condition.should_run({}), false, "6,12,18...: 1")
	
	PuzzleState.level_performance.pieces = 6
	assert_eq(condition.should_run({}), true, "6,12,18...: 6")
	
	PuzzleState.level_performance.pieces = 11
	assert_eq(condition.should_run({}), false, "6,12,18...: 11")
	
	PuzzleState.level_performance.pieces = 12
	assert_eq(condition.should_run({}), true, "6,12,18...: 12")
	
	PuzzleState.level_performance.pieces = 42
	assert_eq(condition.should_run({}), true, "6,12,18...: 42")


func test_piece_written_specific_values() -> void:
	var condition: PhaseConditions.PieceWrittenPhaseCondition
	condition = PhaseConditions.PieceWrittenPhaseCondition.new({"n": "1,2,3"})
	
	PuzzleState.level_performance.pieces = 1
	assert_eq(condition.should_run({}), true, "1,2,3: 1")
	
	PuzzleState.level_performance.pieces = 2
	assert_eq(condition.should_run({}), true, "1,2,3: 2")
	
	PuzzleState.level_performance.pieces = 3
	assert_eq(condition.should_run({}), true, "1,2,3: 3")
	
	PuzzleState.level_performance.pieces = 4
	assert_eq(condition.should_run({}), false, "1,2,3: 4")


func test_piece_written_skip_early_values() -> void:
	var condition: PhaseConditions.PieceWrittenPhaseCondition
	condition = PhaseConditions.PieceWrittenPhaseCondition.new({"n": "11,12,13..."})
	
	PuzzleState.level_performance.pieces = 1
	assert_eq(condition.should_run({}), false, "11,12,13...: 1")
	
	PuzzleState.level_performance.pieces = 11
	assert_eq(condition.should_run({}), true, "11,12,13...: 11")
	
	PuzzleState.level_performance.pieces = 14
	assert_eq(condition.should_run({}), true, "11,12,13...: 14")
