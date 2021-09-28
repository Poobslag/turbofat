extends "res://addons/gut/test.gd"
"""
Tests library of phase conditions for level triggers.
"""

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
