extends "res://addons/gut/test.gd"

func before_each() -> void:
	PlayerData.chat_history.reset()
	PlayerData.level_history.reset()
	PlayerData.career.reset()
	
	PlayerData.chat_history.add_history_item("creature/gurus750/chat_200")
	PlayerData.chat_history.add_history_item("creature/gurus750/chat_201")
	
	# the player cleared level_200 and level_201, but failed level_400
	add_level_history_item("level_200", true)
	add_level_history_item("level_201", true)
	add_level_history_item("level_400", false)


func after_all() -> void:
	CareerLevelLibrary.regions_path = CareerLevelLibrary.DEFAULT_REGIONS_PATH


func add_level_history_item(level_id: String, cleared: bool) -> void:
	var result := RankResult.new()
	result.lost = not cleared
	PlayerData.level_history.add_result(level_id, result)


func assert_evaluate(expected: bool, string: String, subject = null) -> void:
	var actual := BoolExpressionEvaluator.evaluate(string, subject)
	assert_true(expected == actual,
			"\"%s\" expected [%s] but was [%s]" % [string, expected, actual])


func test_true() -> void:
	assert_evaluate(true, "true")
	assert_evaluate(true, "TRUE")
	assert_evaluate(true, "True")
	assert_evaluate(true, "1")


func test_false() -> void:
	assert_evaluate(false, "false")
	assert_evaluate(false, "FALSE")
	assert_evaluate(false, "False")
	assert_evaluate(false, "0")
	assert_evaluate(false, "")


func test_chat_finished() -> void:
	assert_evaluate(true, "chat_finished creature/gurus750/chat_200")
	assert_evaluate(false, "chat_finished creature/gurus750/chat_404")


func test_level_finished() -> void:
	assert_evaluate(true, "level_finished level_200")
	assert_evaluate(false, "level_finished level_400")
	assert_evaluate(false, "level_finished level_404")


func test_region_cleared() -> void:
	CareerLevelLibrary.regions_path = "res://assets/test/career/career-regions-simple.json"
	
	PlayerData.career.best_distance_travelled = 9
	assert_evaluate(false, "region_cleared permissible")
	
	PlayerData.career.best_distance_travelled = 10
	assert_evaluate(true, "region_cleared permissible")
	
	PlayerData.career.best_distance_travelled = 11
	assert_evaluate(true, "region_cleared permissible")


func test_region_started() -> void:
	CareerLevelLibrary.regions_path = "res://assets/test/career/career-regions-simple.json"
	
	PlayerData.career.best_distance_travelled = 9
	assert_evaluate(false, "region_started even")
	
	PlayerData.career.best_distance_travelled = 10
	assert_evaluate(false, "region_started even")
	
	PlayerData.career.best_distance_travelled = 11
	assert_evaluate(true, "region_started even")


func test_and_expression() -> void:
	assert_evaluate(true, "chat_finished creature/gurus750/chat_200 and level_finished level_200")
	assert_evaluate(false, "chat_finished creature/gurus750/chat_200 and level_finished level_404")
	assert_evaluate(false, "chat_finished creature/gurus750/chat_404 and level_finished level_200")


func test_or_expression() -> void:
	assert_evaluate(true, "chat_finished creature/gurus750/chat_200 or level_finished level_404")
	assert_evaluate(true, "chat_finished creature/gurus750/chat_404 or level_finished level_200")
	assert_evaluate(false, "chat_finished creature/gurus750/chat_404 or level_finished level_404")


func test_not_expression() -> void:
	assert_evaluate(false, "not chat_finished creature/gurus750/chat_200")
	assert_evaluate(true, "not chat_finished creature/gurus750/chat_404")


func test_complex_expression() -> void:
	assert_evaluate(false, "not (chat_finished creature/gurus750/chat_200 or level_finished level_200)")
	assert_evaluate(false, "not (chat_finished creature/gurus750/chat_200 or level_finished level_404)")
	assert_evaluate(false, "not (chat_finished creature/gurus750/chat_404 or level_finished level_200)")
	assert_evaluate(true, "not (chat_finished creature/gurus750/chat_404 or level_finished level_404)")
