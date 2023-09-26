extends GutTest

func test_rotate_next_pieces_get_config() -> void:
	var effect: LevelTriggerEffects.RotateNextPiecesEffect
	effect = LevelTriggerEffects.create("rotate_next_pieces", {})
	assert_eq_shallow(effect.get_config(), {"0": "none"})
	
	effect = LevelTriggerEffects.create("rotate_next_pieces", {"0": "cw", "1": "0", "2": "0"})
	assert_eq_shallow(effect.get_config(), {"0": "cw", "1": "0", "2": "0"})

	effect = LevelTriggerEffects.create("rotate_next_pieces", {"0": "180"})
	assert_eq_shallow(effect.get_config(), {"0": "180"})


func test_insert_line_get_config() -> void:
	var effect: LevelTriggerEffects.InsertLineEffect
	effect = LevelTriggerEffects.create("insert_line", {})
	assert_eq_shallow(effect.get_config(), {})
	
	effect = LevelTriggerEffects.create("insert_line", {"count": "5"})
	assert_eq_shallow(effect.get_config(), {"count": "5"})
	
	effect = LevelTriggerEffects.create("insert_line", {"tiles_key": "0"})
	assert_eq_shallow(effect.get_config(), {"tiles_key": "0"})
	
	effect = LevelTriggerEffects.create("insert_line", {"tiles_keys": "0,1"})
	assert_eq_shallow(effect.get_config(), {"tiles_keys": "0,1"})
	
	effect = LevelTriggerEffects.create("insert_line", {"y": "5"})
	assert_eq_shallow(effect.get_config(), {"y": "5"})


func test_add_carrots_set_config() -> void:
	var effect: LevelTriggerEffects.AddCarrotsEffect
	
	effect = LevelTriggerEffects.create("add_carrots", {})
	assert_eq(effect.config.columns, [])
	assert_eq(effect.config.count, 1)
	assert_eq(effect.config.duration, 8.0)
	assert_eq(effect.config.size, CarrotConfig.CarrotSize.MEDIUM)
	assert_eq(effect.config.smoke, CarrotConfig.Smoke.SMALL)
	
	effect = LevelTriggerEffects.create("add_carrots", {"x": "0-2", "count": "2", "duration": "12.0", "size": "large",
			"smoke": "none"})
	assert_eq(effect.config.columns, [0, 1, 2])
	assert_eq(effect.config.count, 2)
	assert_eq(effect.config.duration, 12.0)
	assert_eq(effect.config.size, CarrotConfig.CarrotSize.LARGE)
	assert_eq(effect.config.smoke, CarrotConfig.Smoke.NONE)


func test_add_carrots_get_config() -> void:
	var effect: LevelTriggerEffects.AddCarrotsEffect
	
	effect = LevelTriggerEffects.create("add_carrots", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("add_carrots", {"x": "0-2", "count": "2", "duration": "12.0", "size": "large",
			"smoke": "none"})
	assert_eq_shallow({"count": "2", "duration": "12", "size": "large", "smoke": "none", "x": "0-2"}, effect.get_config())


func test_add_moles_set_config() -> void:
	var effect: LevelTriggerEffects.AddMolesEffect
	
	effect = LevelTriggerEffects.create("add_moles", {})
	assert_eq(effect.config.count, 1)
	assert_eq(effect.config.home, MoleConfig.Home.ANY)
	assert_eq(effect.config.dig_duration, 3)
	assert_eq(effect.config.reward, MoleConfig.Reward.STAR)
	
	effect = LevelTriggerEffects.create("add_moles", {"count": "2", "home": "veg", "dig_duration": "4",
			"reward": "star"})
	assert_eq(effect.config.count, 2)
	assert_eq(effect.config.home, MoleConfig.Home.VEG)
	assert_eq(effect.config.dig_duration, 4)
	assert_eq(effect.config.reward, MoleConfig.Reward.STAR)
	
	effect = LevelTriggerEffects.create("add_moles", {"x": "3-5"})
	assert_eq(effect.config.columns, [3, 4, 5])
	
	effect = LevelTriggerEffects.create("add_moles", {"y": "0,8"})
	assert_eq(effect.config.lines, [19, 11])


func test_add_moles_get_config() -> void:
	var effect: LevelTriggerEffects.AddMolesEffect
	
	effect = LevelTriggerEffects.create("add_moles", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("add_moles", {"count": "2", "home": "veg", "dig_duration": "4",
			"reward": "seed"})
	assert_eq_shallow({"count": "2", "home": "veg", "dig_duration": "4", "reward": "seed"}, effect.get_config())
	
	effect = LevelTriggerEffects.create("add_moles", {"x": "3-5"})
	assert_eq_shallow({"x": "3-5"}, effect.get_config())
	
	effect = LevelTriggerEffects.create("add_moles", {"y": "0,8"})
	assert_eq_shallow({"y": "0,8"}, effect.get_config())


func test_add_onion_set_config() -> void:
	var effect: LevelTriggerEffects.AddOnionEffect
	
	effect = LevelTriggerEffects.create("add_onion", {"0": "nnndddd"})
	assert_eq_shallow(effect.get_config(), {"0": "nnndddd"})
	
	effect = LevelTriggerEffects.create("add_onion", {})
	assert_eq_shallow(effect.get_config(), {})


func test_add_onion_get_config() -> void:
	var effect: LevelTriggerEffects.AddOnionEffect
	
	effect = LevelTriggerEffects.create("add_onion", {"0": "nnndddd"})
	assert_eq_shallow(effect.get_config(), {"0": "nnndddd"})
	
	effect = LevelTriggerEffects.create("add_onion", {})
	assert_eq_shallow(effect.get_config(), {})


func test_add_sharks_set_config() -> void:
	var effect: LevelTriggerEffects.AddSharksEffect
	
	effect = LevelTriggerEffects.create("add_sharks", {})
	assert_eq(effect.config.count, 1)
	assert_eq(effect.config.home, SharkConfig.Home.ANY)
	assert_eq(effect.config.patience, 0)
	assert_eq(effect.config.size, SharkConfig.SharkSize.MEDIUM)
	
	effect = LevelTriggerEffects.create("add_sharks", {"count": "2", "home": "veg", "patience": "4",
			"size": "small"})
	assert_eq(effect.config.count, 2)
	assert_eq(effect.config.home, SharkConfig.Home.VEG)
	assert_eq(effect.config.patience, 4)
	assert_eq(effect.config.size, SharkConfig.SharkSize.SMALL)
	
	effect = LevelTriggerEffects.create("add_sharks", {"x": "3-5"})
	assert_eq(effect.config.columns, [3, 4, 5])
	
	effect = LevelTriggerEffects.create("add_sharks", {"y": "0,8"})
	assert_eq(effect.config.lines, [19, 11])


func test_add_spears_set_config() -> void:
	var effect: LevelTriggerEffects.AddSpearsEffect
	
	effect = LevelTriggerEffects.create("add_spears", {})
	assert_eq(effect.config.duration, -1)
	assert_eq(effect.config.lines, [])
	assert_eq(effect.config.sizes, ["x4"])
	
	effect = LevelTriggerEffects.create("add_spears", {"count": "5", "duration": "2", "y": "3-5", "sizes": "x2,x4,x6"})
	assert_eq(effect.config.count, 5)
	assert_eq(effect.config.duration, 2)
	assert_eq(effect.config.lines, [16, 15, 14])
	assert_eq(effect.config.sizes, ["x2", "x4", "x6"])


func test_add_spears_get_config() -> void:
	var effect: LevelTriggerEffects.AddSpearsEffect
	
	effect = LevelTriggerEffects.create("add_spears", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("add_spears", {"count": "5", "duration": "2", "y": "3-5", "sizes": "x2,x4,x6"})
	assert_eq_shallow({"count": "5", "duration": "2", "y": "3-5", "sizes": "x2,x4,x6"}, effect.get_config())


func test_remove_carrots_set_config() -> void:
	var effect: LevelTriggerEffects.RemoveCarrotsEffect
	
	effect = LevelTriggerEffects.create("remove_carrots", {})
	assert_eq(effect.count, 1)
	
	effect = LevelTriggerEffects.create("remove_carrots", {"0": "2"})
	assert_eq(effect.count, 2)


func test_remove_carrots_get_config() -> void:
	var effect: LevelTriggerEffects.RemoveCarrotsEffect
	
	effect = LevelTriggerEffects.create("remove_carrots", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("remove_carrots", {"0": "2"})
	assert_eq_shallow({"0": "2"}, effect.get_config())


func test_remove_onion_get_config() -> void:
	var effect: LevelTriggerEffects.RemoveOnionEffect
	
	effect = LevelTriggerEffects.create("remove_onion")
	assert_eq_shallow(effect.get_config(), {})


func test_remove_spears_set_config() -> void:
	var effect: LevelTriggerEffects.RemoveSpearsEffect
	
	effect = LevelTriggerEffects.create("remove_spears", {})
	assert_eq(effect.count, 1)
	
	effect = LevelTriggerEffects.create("remove_spears", {"0": "2"})
	assert_eq(effect.count, 2)


func test_remove_spears_get_config() -> void:
	var effect: LevelTriggerEffects.RemoveSpearsEffect
	
	effect = LevelTriggerEffects.create("remove_spears", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("remove_spears", {"0": "2"})
	assert_eq_shallow({"0": "2"}, effect.get_config())


func test_clear_filled_lines_get_config() -> void:
	var effect: LevelTriggerEffects.ClearFilledLinesEffect
	
	effect = LevelTriggerEffects.create("clear_filled_lines", {})
	assert_eq_shallow({}, effect.get_config())
	
	effect = LevelTriggerEffects.create("clear_filled_lines", {"force": "true"})
	assert_eq_shallow({"force": "true"}, effect.get_config())


func test_effect_key() -> void:
	assert_eq(LevelTriggerEffects.effect_key(LevelTriggerEffects.InsertLineEffect.new()), "insert_line")
	assert_eq(LevelTriggerEffects.effect_key(LevelTriggerEffects.RotateNextPiecesEffect.new()), "rotate_next_pieces")
