extends "res://addons/gut/test.gd"

var triggers: LevelTriggers

func before_each() -> void:
	triggers = LevelTriggers.new()


func test_is_default() -> void:
	assert_eq(triggers.is_default(), true)
	triggers.from_json_array(
			[{"phases": ["line_cleared y=0-5"], "effect": "insert_line tiles_key=0"}])
	assert_eq(triggers.is_default(), false)


func test_to_json_empty() -> void:
	assert_eq(triggers.to_json_array(), [])


func test_convert_to_json_and_back_complex() -> void:
	triggers.from_json_array(
			[{"phases": ["line_cleared y=0-5"], "effect": "insert_line tiles_key=0"}])
	_convert_to_json_and_back()
	
	assert_eq(triggers.triggers.keys(), [LevelTrigger.LINE_CLEARED])
	assert_eq(triggers.triggers[LevelTrigger.LINE_CLEARED].size(), 1)
	var trigger: LevelTrigger = triggers.triggers[LevelTrigger.LINE_CLEARED][0]
	assert_eq(trigger.phases.size(), 1)
	assert_eq(trigger.phases[LevelTrigger.LINE_CLEARED].size(), 1)
	assert_is(trigger.phases[LevelTrigger.LINE_CLEARED][0], PhaseConditions.LineClearedPhaseCondition)
	assert_eq(trigger.phases[LevelTrigger.LINE_CLEARED][0].which_lines.keys(), [19, 18, 17, 16, 15, 14])
	assert_is(trigger.effect, LevelTriggerEffects.InsertLineEffect)
	assert_eq(trigger.effect.tiles_keys, ["0"])


func test_convert_to_json_and_back_simple() -> void:
	triggers.from_json_array(
			[{"phases": ["rotated_cw", "initial_rotated_cw"], "effect": "rotate_next_pieces cw"}])
	_convert_to_json_and_back()
	
	assert_eq(triggers.triggers.keys(), [LevelTrigger.ROTATED_CW, LevelTrigger.INITIAL_ROTATED_CW])
	assert_eq(triggers.triggers[LevelTrigger.ROTATED_CW].size(), 1)
	assert_eq(triggers.triggers[LevelTrigger.INITIAL_ROTATED_CW].size(), 1)
	var trigger: LevelTrigger = triggers.triggers[LevelTrigger.ROTATED_CW][0]
	assert_eq(trigger.phases.size(), 2)
	assert_eq(trigger.phases.keys(), [LevelTrigger.ROTATED_CW, LevelTrigger.INITIAL_ROTATED_CW])
	assert_is(trigger.effect, LevelTriggerEffects.RotateNextPiecesEffect)
	assert_eq(trigger.effect.rotate_dir, LevelTriggerEffects.RotateNextPiecesEffect.Rotation.CW)


func _convert_to_json_and_back() -> void:
	var json := triggers.to_json_array()
	triggers = LevelTriggers.new()
	triggers.from_json_array(json)
