extends "res://addons/gut/test.gd"

func test_rotate_next_pieces_get_config() -> void:
	var effect: LevelTriggerEffects.RotateNextPiecesEffect
	effect = LevelTriggerEffects.RotateNextPiecesEffect.new()
	assert_eq_shallow(effect.get_config(), {"0": "none"})
	
	effect = LevelTriggerEffects.RotateNextPiecesEffect.new()
	effect.set_config({"0": "cw", "1": "0", "2": "0"})
	assert_eq_shallow(effect.get_config(), {"0": "cw", "1": "0", "2": "0"})

	effect = LevelTriggerEffects.RotateNextPiecesEffect.new()
	effect.set_config({"0": "180"})
	assert_eq_shallow(effect.get_config(), {"0": "180"})


func test_insert_line_get_config() -> void:
	var effect: LevelTriggerEffects.InsertLineEffect
	effect = LevelTriggerEffects.InsertLineEffect.new()
	assert_eq_shallow(effect.get_config(), {})
	
	effect = LevelTriggerEffects.InsertLineEffect.new()
	effect.set_config({"count": "5"})
	assert_eq_shallow(effect.get_config(), {"count": "5"})
	
	effect = LevelTriggerEffects.InsertLineEffect.new()
	effect.set_config({"tiles_key": "0"})
	assert_eq_shallow(effect.get_config(), {"tiles_key": "0"})
	
	effect = LevelTriggerEffects.InsertLineEffect.new()
	effect.set_config({"tiles_keys": "0,1"})
	assert_eq_shallow(effect.get_config(), {"tiles_keys": "0,1"})
	
	effect = LevelTriggerEffects.InsertLineEffect.new()
	effect.set_config({"y": "5"})
	assert_eq_shallow(effect.get_config(), {"y": "5"})


func test_add_moles_set_config() -> void:
	var effect: LevelTriggerEffects.AddMolesEffect
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({})
	assert_eq(effect.config.count, 1)
	assert_eq(effect.config.home, MoleConfig.Home.ANY)
	assert_eq(effect.config.dig_duration, 3)
	assert_eq(effect.config.reward, MoleConfig.Reward.STAR)
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({"count": "2", "home": "veg", "dig_duration": "4", "reward": "star"})
	assert_eq(effect.config.count, 2)
	assert_eq(effect.config.home, MoleConfig.Home.VEG)
	assert_eq(effect.config.dig_duration, 4)
	assert_eq(effect.config.reward, MoleConfig.Reward.STAR)
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({"x": "3-5"})
	assert_eq(effect.config.columns, [3, 4, 5])
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({"y": "0,8"})
	assert_eq(effect.config.lines, [19, 11])


func test_add_moles_get_config() -> void:
	var effect: LevelTriggerEffects.AddMolesEffect
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({"count": "2", "home": "veg", "dig_duration": "4", "reward": "seed"})
	assert_eq_shallow({"count": "2", "home": "veg", "dig_duration": "4", "reward": "seed"}, effect.get_config())
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({"x": "3-5"})
	assert_eq_shallow({"x": "3-5"}, effect.get_config())
	
	effect = LevelTriggerEffects.AddMolesEffect.new()
	effect.set_config({"y": "0,8"})
	assert_eq_shallow({"y": "0,8"}, effect.get_config())


func test_add_moles_to_json() -> void:
	var effect: LevelTriggerEffects.AddMolesEffect
	
	effect = LevelTriggerEffects.create("add_moles", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("add_moles", {"count": "2", "home": "veg", "dig_duration": "4", "reward": "seed"})
	assert_eq_shallow({"count": "2", "home": "veg", "dig_duration": "4", "reward": "seed"}, effect.get_config())


func test_add_carrots_set_config() -> void:
	var effect: LevelTriggerEffects.AddCarrotsEffect
	
	effect = LevelTriggerEffects.AddCarrotsEffect.new()
	effect.set_config({})
	assert_eq(effect.config.columns, [])
	assert_eq(effect.config.count, 1)
	assert_eq(effect.config.duration, 8.0)
	assert_eq(effect.config.size, CarrotConfig.CarrotSize.MEDIUM)
	assert_eq(effect.config.smoke, CarrotConfig.Smoke.SMALL)
	
	effect = LevelTriggerEffects.AddCarrotsEffect.new()
	effect.set_config({"x": "0-2", "count": "2", "duration": "12.0", "size": "large", "smoke": "none"})
	assert_eq(effect.config.columns, [0, 1, 2])
	assert_eq(effect.config.count, 2)
	assert_eq(effect.config.duration, 12.0)
	assert_eq(effect.config.size, CarrotConfig.CarrotSize.LARGE)
	assert_eq(effect.config.smoke, CarrotConfig.Smoke.NONE)


func test_add_carrots_get_config() -> void:
	var effect: LevelTriggerEffects.AddCarrotsEffect
	
	effect = LevelTriggerEffects.AddCarrotsEffect.new()
	effect.set_config({})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.AddCarrotsEffect.new()
	effect.set_config({"count": "2", "duration": "12.0", "size": "large", "smoke": "none", "x": "0-2"})
	assert_eq_shallow({"count": "2", "duration": "12", "size": "large", "smoke": "none", "x": "0-2"}, effect.get_config())


func test_remove_carrots_set_config() -> void:
	var effect: LevelTriggerEffects.RemoveCarrotsEffect
	
	effect = LevelTriggerEffects.RemoveCarrotsEffect.new()
	effect.set_config({})
	assert_eq(effect.count, 1)
	
	effect = LevelTriggerEffects.RemoveCarrotsEffect.new()
	effect.set_config({"0": "2"})
	assert_eq(effect.count, 2)


func test_remove_carrots_get_config() -> void:
	var effect: LevelTriggerEffects.RemoveCarrotsEffect
	
	effect = LevelTriggerEffects.RemoveCarrotsEffect.new()
	effect.set_config({})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.RemoveCarrotsEffect.new()
	effect.set_config({"0": "2"})
	assert_eq_shallow({"0": "2"}, effect.get_config())


func test_clear_filled_lines_to_json() -> void:
	var effect: LevelTriggerEffects.ClearFilledLinesEffect
	
	effect = LevelTriggerEffects.create("clear_filled_lines", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("clear_filled_lines", {"force": "true"})
	assert_eq_shallow({"force": "true"}, effect.get_config())


func test_effect_key() -> void:
	assert_eq(LevelTriggerEffects.effect_key(LevelTriggerEffects.InsertLineEffect.new()), "insert_line")
	assert_eq(LevelTriggerEffects.effect_key(LevelTriggerEffects.RotateNextPiecesEffect.new()), "rotate_next_pieces")
