extends "res://addons/gut/test.gd"
"""
Unit test for the chat library.
"""

var _chat_selectors := [
	{
		"dialog": "level-001",
		"if_conditions": [
			"current_level/level_1"
		]
	},
	{
		"dialog": "level-002",
		"if_conditions": [
			"current_level/level_2"
		]
	},
	{
		"dialog": "greeting-001",
		"repeat": 999999
	},
	{
		"dialog": "notable-001",
		"if_conditions": [
			"notable_chat"
		],
		"repeat": 999999
	},
	{
		"dialog": "notable-002",
		"if_conditions": [
			"notable_chat"
		],
		"repeat": 999999
	},
	{
		"dialog": "filler-001",
		"repeat": 0
	}
]

var _state := {}

func before_each() -> void:
	PlayerData.chat_history.reset()
	
	_state["creature_id"] = "gurus750"
	_state["level_num"] = 1
	_state["notable_chat"] = true
	
	PlayerData.chat_history.add_history_item("dialog/gurus750/level-001")
	PlayerData.chat_history.add_history_item("dialog/gurus750/level-002")
	PlayerData.chat_history.add_history_item("dialog/gurus750/greeting-001")
	PlayerData.chat_history.add_history_item("dialog/gurus750/notable-001")
	PlayerData.chat_history.add_history_item("dialog/gurus750/notable-002")


func test_level_1() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level-001")
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level-002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state), "level-001")


func test_level_2() -> void:
	_state["level_num"] = 2
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level-001")
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level-002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state), "level-002")


func test_greeting() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/greeting-001")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state), "greeting-001")


func test_chat_1() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable-001")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state), "notable-001")


func test_chat_2() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable-002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state), "notable-002")


func test_chat_no_notable_chats_remaining() -> void:
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state), "filler-001")


func test_chat_non_notable() -> void:
	_state["notable_chat"] = false
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable-001")
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable-002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state), "filler-001")
