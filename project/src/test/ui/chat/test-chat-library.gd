extends "res://addons/gut/test.gd"

var _chat_selectors := [
	{
		"chat": "greeting_001",
		"repeat": 999999
	},
	{
		"chat": "notable_001",
		"available_if": "notable",
		"repeat": 999999
	},
	{
		"chat": "notable_002",
		"available_if": "notable",
		"repeat": 999999
	},
	{
		"chat": "priority_001",
		"available_if": "chat_finished creature/gurus750/trigger_001",
		"prioritized_if": "chat_finished creature/gurus750/trigger_002"
	},
	{
		"chat": "priority_002",
		"available_if": "chat_finished creature/gurus750/trigger_002",
		"prioritized_if": "chat_finished creature/gurus750/trigger_002"
	},
]

var _creature_id := "gurus750"

var _filler_ids := ["filler_000", "filler_001"]

func before_each() -> void:
	PlayerData.chat_history.reset()
	
	PlayerData.chat_history.add_history_item("creature/gurus750/level_001")
	PlayerData.chat_history.add_history_item("creature/gurus750/level_002")
	PlayerData.chat_history.add_history_item("creature/gurus750/greeting_001")
	PlayerData.chat_history.add_history_item("creature/gurus750/notable_001")
	PlayerData.chat_history.add_history_item("creature/gurus750/notable_002")
	
	PlayerData.chat_history.increment_filler_count(_creature_id)


func _select_from_chat_selectors() -> String:
	return ChatLibrary.select_from_chat_selectors(_chat_selectors, _creature_id, _filler_ids)


func test_greeting() -> void:
	PlayerData.chat_history.delete_history_item("creature/gurus750/greeting_001")
	
	assert_eq(_select_from_chat_selectors(), "greeting_001")


func test_chat_1() -> void:
	PlayerData.chat_history.delete_history_item("creature/gurus750/notable_001")
	
	assert_eq(_select_from_chat_selectors(), "notable_001")


func test_chat_2() -> void:
	PlayerData.chat_history.delete_history_item("creature/gurus750/notable_002")
	
	assert_eq(_select_from_chat_selectors(), "notable_002")


func test_chat_no_notable_chats_remaining() -> void:
	assert_eq(_select_from_chat_selectors(), "filler_000")


func test_chat_avoid_repeat_filler() -> void:
	PlayerData.chat_history.add_history_item("creature/gurus750/filler_000")
	assert_eq(_select_from_chat_selectors(), "filler_001")


func test_chat_non_notable() -> void:
	# creature is not ready for a notable chat
	PlayerData.chat_history.filler_counts["gurus750"] = 0
	
	PlayerData.chat_history.delete_history_item("creature/gurus750/notable_001")
	PlayerData.chat_history.delete_history_item("creature/gurus750/notable_002")
	
	assert_eq(_select_from_chat_selectors(), "filler_000")


func test_chat_prioritized() -> void:
	# priority_001 is skipped because its 'available_if' condition is not met
	PlayerData.chat_history.add_history_item("creature/gurus750/trigger_002")
	assert_eq(_select_from_chat_selectors(), "priority_002")
	
	# priority_001 and priority_002 are both available, so the earlier chat is prioritized
	PlayerData.chat_history.add_history_item("creature/gurus750/trigger_001")
	assert_eq(_select_from_chat_selectors(), "priority_001")


func test_add_lull_characters_no_effect() -> void:
	assert_eq(ChatLibrary.add_lull_characters(""), "")
	assert_eq(ChatLibrary.add_lull_characters("One"), "One")
	assert_eq(ChatLibrary.add_lull_characters("One two"), "One two")
	assert_eq(ChatLibrary.add_lull_characters("One two."), "One two.")


func test_add_lull_characters_punctuation() -> void:
	assert_eq(ChatLibrary.add_lull_characters("One two, three four!"), "One two,/ three four!")
	assert_eq(ChatLibrary.add_lull_characters("One? Two!"), "One?/ Two!")
	assert_eq(ChatLibrary.add_lull_characters("One! Two! Three."), "One!/ Two!/ Three.")
	
	assert_eq(ChatLibrary.add_lull_characters("One - two."), "One -/ two.")
	assert_eq(ChatLibrary.add_lull_characters("One -- two."), "One -/-/ two.")
	assert_eq(ChatLibrary.add_lull_characters("That's a half-baked idea."), "That's a half-baked idea.")
	
	# Don't add lull characters if there are already lull characters.
	assert_eq(ChatLibrary.add_lull_characters("One -///-/// two."), "One -///-/// two.")
	assert_eq(ChatLibrary.add_lull_characters("O//n//e//.////// Two, three!"), "O//n//e//.////// Two, three!")


func test_add_lull_characters_ellipses() -> void:
	assert_eq(ChatLibrary.add_lull_characters("..."), "././.")
	assert_eq(ChatLibrary.add_lull_characters("...One"), "./././One")
	assert_eq(ChatLibrary.add_lull_characters("One..."), "One...")
	assert_eq(ChatLibrary.add_lull_characters("One... two. ...Three four."), "One./././ two./ ./././Three four.")


func test_add_mega_lull_characters() -> void:
	assert_eq(ChatLibrary.add_mega_lull_characters("OH, MY!!!"), "O/H/,/// M/Y/!/!/!")
	assert_eq(ChatLibrary.add_mega_lull_characters("¡¡¡OH, MI!!!"), "¡/¡/¡/O/H/,/// M/I/!/!/!")
	assert_eq(ChatLibrary.add_mega_lull_characters("О, МОЙ!"), "О/,/// М/О/Й/!")


func test_chat_key_from_path() -> void:
	assert_eq(ChatLibrary.chat_key_from_path("res://assets/main/creatures/primary/bones/filler-001.chat"),
			"creature/bones/filler_001")
	assert_eq(ChatLibrary.chat_key_from_path(
				"res://assets/main/puzzle/levels/cutscenes/marsh/hello-everyone-000.chat"),
			"level/marsh/hello_everyone_000")
	assert_eq(ChatLibrary.chat_key_from_path("res://assets/main/chat/marsh-crystal.chat"),
			"chat/marsh_crystal")


func test_path_from_chat_key() -> void:
	assert_eq(ChatLibrary.path_from_chat_key("creature/bones/filler_001"),
			"res://assets/main/creatures/primary/bones/filler-001.chat")
	assert_eq(ChatLibrary.path_from_chat_key("level/marsh/hello_everyone_000"),
			"res://assets/main/puzzle/levels/cutscenes/marsh/hello-everyone-000.chat")
	assert_eq(ChatLibrary.path_from_chat_key("chat/marsh_crystal"),
			"res://assets/main/chat/marsh-crystal.chat")
