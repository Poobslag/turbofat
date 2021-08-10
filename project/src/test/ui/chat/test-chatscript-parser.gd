extends "res://addons/gut/test.gd"
"""
Test for the chatscript parser.
"""

const CUTSCENE_FULL := "res://assets/test/ui/chat/cutscene-full.chat"
const CUTSCENE_META := "res://assets/test/ui/chat/cutscene-meta.chat"
const CHAT_CONDITION := "res://assets/test/ui/chat/chat-condition.chat"
const CHAT_FULL := "res://assets/test/ui/chat/chat-full.chat"
const CHAT_LINK_MOOD := "res://assets/test/ui/chat/chat-link-mood.chat"
const CHAT_NEWLINES := "res://assets/test/ui/chat/chat-newlines.chat"
const CHAT_THOUGHT := "res://assets/test/ui/chat/chat-thought.chat"

func _chat_tree_from_file(path: String) -> ChatTree:
	var parser := ChatscriptParser.new()
	var chat_tree := parser.chat_tree_from_file(path)
	chat_tree.prepare_first_chat_event()
	return chat_tree


func test_cutscene_location() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_eq(chat_tree.location_id, "outdoors_walk")
	assert_eq(chat_tree.destination_id, "outdoors")


func test_overall_meta() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_META)
	
	assert_eq(chat_tree.meta.get("filler"), false)


func test_cutscene_spawn_locations() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_has(chat_tree.spawn_locations, "#player#", "kitchen_3")
	assert_has(chat_tree.spawn_locations, "#sensei#", "kitchen_5")
	assert_has(chat_tree.spawn_locations, "richie", "kitchen_11")
	assert_has(chat_tree.spawn_locations, "skins", "kitchen_9")
	assert_has(chat_tree.spawn_locations, "bones", "kitchen_7")


func test_cutscene_chat() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	var event := chat_tree.get_event()
	
	assert_eq(event.who, "skins")
	assert_eq(event.text, "So how was that?")
	assert_eq(event.mood, ChatEvent.Mood.NONE)
	assert_eq(event.links, ["very_good", "good", "bad", "very_bad"])
	assert_eq(event.link_texts, ["I think you killed it!", "That was pretty good!", "...",
			"Well... I wouldn't eat it."])


func test_cutscene_mood_smile1() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	chat_tree.advance(0)
	var event := chat_tree.get_event()
	
	assert_eq(event.mood, ChatEvent.Mood.SMILE1)
	assert_eq(event.text, "Wow, I think you killed it! You have some real talent.")


func test_cutscene_mood_smile0() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	chat_tree.advance(1)
	var event := chat_tree.get_event()
	
	assert_eq(event.mood, ChatEvent.Mood.SMILE0)
	assert_eq(event.text, "Hey, that was pretty good! And y'know, with a little more training you'll get even better.")


func test_chatevent_meta() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_META)
	
	# multiple metadata events on one line
	assert_eq(chat_tree.get_event().meta, ["creature_enter john", "creature_enter jane"])
	
	# multiple metadata events on different lines
	chat_tree.advance()
	chat_tree.advance()
	assert_eq(chat_tree.get_event().meta, ["creature_exit john", "creature_exit jane"])


func test_chatevent_meta_orientation() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_META)
	chat_tree.advance()
	chat_tree.advance()
	chat_tree.advance()
	var event := chat_tree.get_event()
	
	assert_eq(event.text, "Oh? Is someone there?")
	assert_eq(event.meta, ["creature_orientation john 1"])


func test_cutscene_thought() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_META)
	chat_tree.advance()
	var event := chat_tree.get_event()
	
	assert_eq(event.who, "")
	assert_eq(event.text, "(John isn't wearing a hat. You're not sure what to say.)")


func test_chat_chat() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_FULL)
	var event := chat_tree.get_event()
	
	assert_eq(event.who, "boatricia")
	assert_eq(event.text, "Oh! I remember you from before. I'm Boatricia, I'm sort of new here and trying to make" \
			+ " some friends.")


func test_chat_thought() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_THOUGHT)
	var event := chat_tree.get_event()
	
	assert_eq(event.who, "")
	assert_eq(event.text, "(A crystalline marshmallow has sprouted from the soil. The five-second rule precludes" \
			+ " me from eating it.)")


func test_chat_choice_mood() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_LINK_MOOD)
	var event := chat_tree.get_event()
	
	assert_eq(event.link_moods[0], ChatEvent.Mood.SMILE0)
	assert_eq(event.link_moods[1], ChatEvent.Mood.RAGE0)
	assert_eq(event.link_moods[2], ChatEvent.Mood.AWKWARD0)


func test_chat_say_if() -> void:
	PlayerData.chat_history.reset()
	var chat_tree: ChatTree
	
	chat_tree = _chat_tree_from_file(CHAT_CONDITION)
	assert_eq(chat_tree.get_event().text, "Hello, nice to meet you!")
	chat_tree.advance()
	assert_eq(chat_tree.get_event().text, "Nice to meet you, too!")
	
	PlayerData.chat_history.add_history_item("creature/boatricia/hi")
	
	chat_tree = _chat_tree_from_file(CHAT_CONDITION)
	assert_eq(chat_tree.get_event().text, "Oh, I remember you!")
	chat_tree.advance()
	assert_eq(chat_tree.get_event().text, "I remember you too!")


func test_chat_link_if() -> void:
	PlayerData.chat_history.reset()
	var chat_tree: ChatTree
	
	chat_tree = _chat_tree_from_file(CHAT_CONDITION)
	chat_tree.advance()
	chat_tree.advance()
	assert_eq(chat_tree.get_event().links, ["first_time", "not_first_time", "other"])
	assert_eq(chat_tree.get_event().enabled_link_indexes(), [0, 2])
	
	PlayerData.chat_history.add_history_item("creature/boatricia/hi")
	
	chat_tree = _chat_tree_from_file(CHAT_CONDITION)
	chat_tree.advance()
	chat_tree.advance()
	assert_eq(chat_tree.get_event().links, ["first_time", "not_first_time", "other"])
	assert_eq(chat_tree.get_event().enabled_link_indexes(), [1, 2])


func test_chat_start_if() -> void:
	PlayerData.chat_history.reset()
	var chat_tree: ChatTree
	
	chat_tree = _chat_tree_from_file(CHAT_CONDITION)
	assert_eq(chat_tree.get_event().text, "Hello, nice to meet you!")
	
	PlayerData.chat_history.add_history_item("creature/boatricia/fire")
	
	chat_tree = _chat_tree_from_file(CHAT_CONDITION)
	assert_eq(chat_tree.get_event().text, "My kitchen is on fire!")


func test_newlines() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_NEWLINES)
	chat_tree.advance()
	assert_eq(chat_tree.get_event().text, "(Hmm...\nYou're not sure.)")
	chat_tree.advance()
	assert_eq(chat_tree.get_event().text, "Anyway!\nUmm, it's nice to meet you.")
	assert_eq(chat_tree.get_event().link_texts[0], "Oh!\nHi!")
