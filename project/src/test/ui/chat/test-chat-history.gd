extends "res://addons/gut/test.gd"

var history := ChatHistory.new()

func before_each() -> void:
	history.reset()


func test_chat_age() -> void:
	history.add_history_item("chat/item_200")
	history.add_history_item("chat/item_100")
	
	assert_eq(history.chat_age("chat/item_100"), 0)
	assert_eq(history.chat_age("chat/item_200"), 1)
	assert_eq(history.chat_age("chat/item_300"), ChatHistory.CHAT_AGE_NEVER)


func test_from_json_dict_chat_age() -> void:
	history.from_json_dict({
		"history_items": {
			"chat/item_100": 1,
			"chat/item_200": 4,
			"chat/item_300": 0,
		}
	})
	history.add_history_item("chat/item_100")
	
	assert_eq(history.chat_age("chat/item_100"), 0)
	assert_eq(history.chat_age("chat/item_200"), 1)
