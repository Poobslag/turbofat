extends GutTest

var _level_history := LevelHistory.new()

func before_each() -> void:
	_level_history.reset()


static func rank_result(score: int = 7890) -> RankResult:
	var result := RankResult.new()
	result.seconds = 600.0
	result.lines = 300
	result.box_score_per_line = 9.3
	result.combo_score_per_line = 17.0
	result.score = score
	return result


func test_prune_one() -> void:
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(7890))
	_level_history.prune("level_895")
	
	assert_eq(_level_history.get_results("level_895")[0].score, 7890)


func test_prune_two() -> void:
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(7890))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(6780))
	_level_history.prune("level_895")
	
	assert_eq(_level_history.get_results("level_895")[0].score, 6780)
	assert_eq(_level_history.get_results("level_895")[1].score, 7890)


func test_prune_many() -> void:
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(500))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(700))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(30))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(10))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(600))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(20))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(40))
	assert_eq(_level_history.get_results("level_895").size(), 7)
	
	_level_history.prune("level_895")
	assert_eq(_level_history.get_results("level_895").size(), 4)


func test_prev_after_prune() -> void:
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(500))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(700))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(30))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(10))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(600))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(20))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(40))
	_level_history.prune("level_895")
	
	assert_eq(_level_history.get_prev_result("level_895").score, 40)


func test_no_level_name() -> void:
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("", rank_result())
	assert_false(_level_history.get_level_names().has(""))


func test_daily_best_no_duplicates() -> void:
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(1285))
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	_level_history.add_result("level_895", rank_result(1230))
	
	var best_results := _level_history.get_best_results("level_895", true)
	assert_eq(best_results.size(), 2)


func test_finished_successful() -> void:
	# Workaround for Godot #69282; calling static function from within a class generates a warning
	# https://github.com/godotengine/godot/issues/69282
	@warning_ignore("static_called_on_instance")
	var result := rank_result()
	result.lost = false
	result.success = true
	_level_history.add_result("level_895", result)
	assert_eq(_level_history.finished_levels.keys(), ["level_895"])
	assert_eq(_level_history.successful_levels.keys(), ["level_895"])
