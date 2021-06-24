extends "res://addons/gut/test.gd"
"""
Tests that boolean expressions can be parsed and evaluated correctly.
"""

func before_each() -> void:
	PlayerData.chat_history.reset()
	PlayerData.level_history.reset()
	
	PlayerData.chat_history.add_history_item("chat/gurus750/chat_200")
	PlayerData.chat_history.add_history_item("chat/gurus750/chat_201")
	
	# the player cleared level_200 and level_201, but failed level_400
	add_level_history_item("level_200", true)
	add_level_history_item("level_201", true)
	add_level_history_item("level_400", false)
	
	PlayerData.chat_history.increment_filler_count("creature_200")


func add_level_history_item(level_id: String, cleared: bool) -> void:
	var result := RankResult.new()
	result.lost = not cleared
	PlayerData.level_history.add(level_id, result)


func assert_evaluate(expected: bool, string: String, subject = null) -> void:
	var actual := BoolExpressionEvaluator.evaluate(string, subject)
	assert_true(expected == actual,
			"\"%s\" expected [%s] but was [%s]" % [string, expected, actual])


func test_chat_finished() -> void:
	assert_evaluate(true, "chat_finished chat/gurus750/chat_200")
	assert_evaluate(false, "chat_finished chat/gurus750/chat_404")


func test_level_finished() -> void:
	assert_evaluate(true, "level_finished level_200")
	assert_evaluate(false, "level_finished level_400")
	assert_evaluate(false, "level_finished level_404")


func test_and_expression() -> void:
	assert_evaluate(true, "chat_finished chat/gurus750/chat_200 and level_finished level_200")
	assert_evaluate(false, "chat_finished chat/gurus750/chat_200 and level_finished level_404")
	assert_evaluate(false, "chat_finished chat/gurus750/chat_404 and level_finished level_200")


func test_or_expression() -> void:
	assert_evaluate(true, "chat_finished chat/gurus750/chat_200 or level_finished level_404")
	assert_evaluate(true, "chat_finished chat/gurus750/chat_404 or level_finished level_200")
	assert_evaluate(false, "chat_finished chat/gurus750/chat_404 or level_finished level_404")


func test_not_expression() -> void:
	assert_evaluate(false, "not chat_finished chat/gurus750/chat_200")
	assert_evaluate(true, "not chat_finished chat/gurus750/chat_404")


func test_complex_expression() -> void:
	assert_evaluate(false, "not (chat_finished chat/gurus750/chat_200 or level_finished level_200)")
	assert_evaluate(false, "not (chat_finished chat/gurus750/chat_200 or level_finished level_404)")
	assert_evaluate(false, "not (chat_finished chat/gurus750/chat_404 or level_finished level_200)")
	assert_evaluate(true, "not (chat_finished chat/gurus750/chat_404 or level_finished level_404)")


func test_notable_expression() -> void:
	# creature with a filler chat triggers the 'notable' flag; they're ready for a serious chat
	assert_evaluate(true, "notable", "creature_200")
	
	# creature with no filler chats does not trigger the 'notable' flag; they're not ready for a serious chat
	assert_evaluate(false, "notable", "creature_201")
	
	# null creature doesn't trigger the 'notable' flag
	assert_evaluate(false, "notable", "")
