extends "res://addons/gut/test.gd"
"""
Test for the chatscript parser.
"""

const CUTSCENE_FULL := "res://assets/test/ui/chat/cutscene-full.chat"
const CUTSCENE_META := "res://assets/test/ui/chat/cutscene-meta.chat"
const CHAT_FULL := "res://assets/test/ui/chat/chat-full.chat"
const CHAT_THOUGHT := "res://assets/test/ui/chat/chat-thought.chat"

func _chat_tree_from_file(path: String) -> ChatTree:
	var parser := ChatscriptParser.new()
	return parser.chat_tree_from_file(path)


func test_cutscene_location() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_eq(chat_tree.location_id, "indoors")


func test_cutscene_meta() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_META)
	
	assert_eq(chat_tree.meta.get("filler"), false)


func test_cutscene_spawn_locations() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_has(chat_tree.spawn_locations, "#player#", "kitchen-3")
	assert_has(chat_tree.spawn_locations, "#sensei#", "kitchen-5")
	assert_has(chat_tree.spawn_locations, "richie", "kitchen-11")
	assert_has(chat_tree.spawn_locations, "skins", "kitchen-9")
	assert_has(chat_tree.spawn_locations, "bones", "kitchen-7")


func test_cutscene_dialog() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	var event := chat_tree.get_event()
	
	assert_eq(event.who, "skins")
	assert_eq(event.text, "So how was that?")
	assert_eq(event.mood, ChatEvent.Mood.NONE)
	assert_eq(event.links, ["very-good", "good", "bad", "very-bad"])
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


func test_cutscene_metadata() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_META)
	var event := chat_tree.get_event()
	
	assert_eq(event.meta, ["creature-enter john", "creature-enter jane"])


func test_cutscene_self_dialog() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_META)
	chat_tree.advance()
	var event := chat_tree.get_event()
	
	assert_eq(event.who, "")
	assert_eq(event.text, "(John isn't wearing a hat. You're not sure what to say.)")


func test_chat_dialog() -> void:
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
