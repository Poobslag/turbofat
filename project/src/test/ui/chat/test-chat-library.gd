extends "res://addons/gut/test.gd"
"""
Unit test for the chat library.
"""

var _chat_selectors := [
	{
		"dialog": "level_001",
		"if_conditions": [
			"current_level/level_1"
		]
	},
	{
		"dialog": "level_002",
		"if_conditions": [
			"current_level/level_2"
		]
	},
	{
		"dialog": "greeting_001",
		"repeat": 999999
	},
	{
		"dialog": "notable_001",
		"if_conditions": [
			"notable_chat"
		],
		"repeat": 999999
	},
	{
		"dialog": "notable_002",
		"if_conditions": [
			"notable_chat"
		],
		"repeat": 999999
	}
]

var _state := {}

var _filler_ids := ["filler_000", "filler_001"]

func before_each() -> void:
	PlayerData.chat_history.reset()
	
	_state["creature_id"] = "gurus750"
	_state["level_num"] = 1
	_state["notable_chat"] = true
	
	PlayerData.chat_history.add_history_item("dialog/gurus750/level_001")
	PlayerData.chat_history.add_history_item("dialog/gurus750/level_002")
	PlayerData.chat_history.add_history_item("dialog/gurus750/greeting_001")
	PlayerData.chat_history.add_history_item("dialog/gurus750/notable_001")
	PlayerData.chat_history.add_history_item("dialog/gurus750/notable_002")


func test_level_1() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level_001")
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level_002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "level_001")


func test_level_2() -> void:
	_state["level_num"] = 2
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level_001")
	PlayerData.chat_history.delete_history_item("dialog/gurus750/level_002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "level_002")


func test_greeting() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/greeting_001")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "greeting_001")


func test_chat_1() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable_001")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "notable_001")


func test_chat_2() -> void:
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable_002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "notable_002")


func test_chat_no_notable_chats_remaining() -> void:
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "filler_000")


func test_chat_avoid_repeat_filler() -> void:
	PlayerData.chat_history.add_history_item("dialog/gurus750/filler_000")
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "filler_001")


func test_chat_non_notable() -> void:
	_state["notable_chat"] = false
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable_001")
	PlayerData.chat_history.delete_history_item("dialog/gurus750/notable_002")
	
	assert_eq(ChatLibrary.choose_dialog_from_chat_selectors(_chat_selectors, _state, _filler_ids), "filler_000")
