extends "res://addons/gut/test.gd"

func test_rotate_next_pieces_to_json_string() -> void:
	var effect: LevelTriggerEffects.RotateNextPiecesEffect
	effect = LevelTriggerEffects.RotateNextPiecesEffect.new()
	assert_eq_shallow(effect.get_config(), {"0": "none"})
	
	effect = LevelTriggerEffects.RotateNextPiecesEffect.new()
	effect.set_config({"0": "cw", "1": "0", "2": "0"})
	assert_eq_shallow(effect.get_config(), {"0": "cw", "1": "0", "2": "0"})

	effect = LevelTriggerEffects.RotateNextPiecesEffect.new()
	effect.set_config({"0": "180"})
	assert_eq_shallow(effect.get_config(), {"0": "180"})


func test_insert_line_to_json_string_0() -> void:
	var effect: LevelTriggerEffects.InsertLineEffect
	effect = LevelTriggerEffects.InsertLineEffect.new()
	assert_eq_shallow(effect.get_config(), {})
	
	effect = LevelTriggerEffects.InsertLineEffect.new()
	effect.set_config({"tiles_key": "0"})
	assert_eq_shallow(effect.get_config(), {"tiles_key": "0"})


func test_insert_line_to_json_string_1() -> void:
	var effect: LevelTriggerEffects.InsertLineEffect
	effect = LevelTriggerEffects.InsertLineEffect.new()
	assert_eq_shallow(effect.get_config(), {})
	
	effect = LevelTriggerEffects.InsertLineEffect.new()
	effect.set_config({"tiles_keys": "0,1"})
	assert_eq_shallow(effect.get_config(), {"tiles_keys": "0,1"})


func test_effect_key() -> void:
	assert_eq(LevelTriggerEffects.effect_key(LevelTriggerEffects.InsertLineEffect.new()), "insert_line")
	assert_eq(LevelTriggerEffects.effect_key(LevelTriggerEffects.RotateNextPiecesEffect.new()), "rotate_next_pieces")
