extends "res://addons/gut/test.gd"
"""
Unit test for the chat history.
"""

func test_history_key_from_path() -> void:
	assert_eq(ChatHistory.history_key_from_path("res://assets/main/creatures/primary/bones/filler-001.chat"),
			"chat/bones/filler_001")
	assert_eq(ChatHistory.history_key_from_path("res://assets/main/puzzle/levels/cutscenes/marsh/hello-everyone-000.chat"),
			"puzzle/levels/cutscenes/marsh/hello_everyone_000")
	assert_eq(ChatHistory.history_key_from_path("res://assets/main/chat/marsh-crystal.chat"),
			"chat/marsh_crystal")


func test_path_from_history_key() -> void:
	assert_eq(ChatHistory.path_from_history_key("chat/bones/filler_001", true),
			"res://assets/main/creatures/primary/bones/filler-001.chat")
	assert_eq(ChatHistory.path_from_history_key("puzzle/levels/cutscenes/marsh/hello_everyone_000"),
			"res://assets/main/puzzle/levels/cutscenes/marsh/hello-everyone-000.chat")
	assert_eq(ChatHistory.path_from_history_key("chat/marsh_crystal"),
			"res://assets/main/chat/marsh-crystal.chat")
