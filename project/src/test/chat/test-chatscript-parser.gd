extends GutTest

const CUTSCENE_FULL := "res://assets/test/chat/cutscene-full.chat"
const CUTSCENE_META := "res://assets/test/chat/cutscene-meta.chat"

const CHAT_CONDITION := "res://assets/test/chat/chat-condition.chat"
const CHAT_DEFAULT_PHRASE := "res://assets/test/chat/chat-default-phrase.chat"
const CHAT_FULL := "res://assets/test/chat/chat-full.chat"
const CHAT_LINK_MOOD := "res://assets/test/chat/chat-link-mood.chat"
const CHAT_NEWLINES := "res://assets/test/chat/chat-newlines.chat"
const CHAT_SET_PHRASE := "res://assets/test/chat/chat-set-phrase.chat"
const CHAT_SET_FLAG_STRING := "res://assets/test/chat/chat-set-flag-string.chat"
const CHAT_SET_FLAG_BOOL := "res://assets/test/chat/chat-set-flag-bool.chat"
const CHAT_THOUGHT := "res://assets/test/chat/chat-thought.chat"

func before_each() -> void:
	ChatLibrary.chat_key_root_path = "res://assets/test"
	PlayerData.chat_history.reset()


func after_all() -> void:
	ChatLibrary.chat_key_root_path = ChatLibrary.DEFAULT_CHAT_KEY_ROOT_PATH
	PlayerData.chat_history.reset()


func test_cutscene_location() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_eq(chat_tree.location_id, "marsh/walk")


func test_chat_key() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_eq(chat_tree.chat_key, "chat/cutscene_full")


func test_overall_meta() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_eq(chat_tree.meta.get("fixed_zoom"), 1.0)


func test_cutscene_creature_ids() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_has(chat_tree.creature_ids, "#player#")
	assert_has(chat_tree.creature_ids, "#sensei#")
	assert_has(chat_tree.creature_ids, "richie")
	assert_has(chat_tree.creature_ids, "skins")
	assert_has(chat_tree.creature_ids, "bones")


func test_cutscene_spawn_locations() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	
	assert_has(chat_tree.spawn_locations, "#player#", "kitchen_3")
	assert_has(chat_tree.spawn_locations, "#sensei#", "kitchen_5")
	assert_has(chat_tree.spawn_locations, "richie", "kitchen_11")
	assert_has(chat_tree.spawn_locations, "skins", "kitchen_9")
	assert_has(chat_tree.spawn_locations, "bones", "kitchen_7")


func test_cutscene_roles() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	assert_eq(chat_tree.chef_id, "skins")
	assert_eq(chat_tree.customer_ids, ["rhonk", "spood"])
	assert_eq(chat_tree.observer_id, "#sensei#")


func test_cutscene_chat() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	var event := chat_tree.get_event()
	
	assert_eq(event.who, "skins")
	assert_eq(event.text, "So how was that?")
	assert_eq(event.mood, Creatures.Mood.NONE)
	assert_eq(event.links, ["very_good", "good", "bad", "very_bad"])
	assert_eq(event.link_texts, ["I think you killed it!", "That was pretty good!", "...",
			"Well... I wouldn't eat it."])


func test_cutscene_mood_smile1() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	chat_tree.advance(0)
	var event := chat_tree.get_event()
	
	assert_eq(event.mood, Creatures.Mood.SMILE1)
	assert_eq(event.text, "Wow, I think you killed it! You have some real talent.")


func test_cutscene_mood_smile0() -> void:
	var chat_tree := _chat_tree_from_file(CUTSCENE_FULL)
	chat_tree.advance(1)
	var event := chat_tree.get_event()
	
	assert_eq(event.mood, Creatures.Mood.SMILE0)
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
	
	assert_eq(event.link_moods[0], Creatures.Mood.SMILE0)
	assert_eq(event.link_moods[1], Creatures.Mood.RAGE0)
	assert_eq(event.link_moods[2], Creatures.Mood.AWKWARD0)


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


func test_set_flag_bool() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_SET_FLAG_BOOL)
	assert_eq(PlayerData.chat_history.get_flag("bone_practice"), "")
	chat_tree.advance()
	assert_eq(PlayerData.chat_history.get_flag("bone_practice"), "true")


func test_set_flag_string() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_SET_FLAG_STRING)
	assert_eq(PlayerData.chat_history.get_flag("adventurous_classy"), "")
	chat_tree.advance()
	assert_eq(PlayerData.chat_history.get_flag("adventurous_classy"), "capable")


func test_has_flag() -> void:
	var chat_tree: ChatTree
	
	chat_tree = _chat_tree_from_file(CHAT_SET_FLAG_BOOL)
	assert_eq(chat_tree.get_event().text, "Hello!")
	
	PlayerData.chat_history.set_flag("bone_practice")
	
	chat_tree = _chat_tree_from_file(CHAT_SET_FLAG_BOOL)
	assert_eq(chat_tree.get_event().text, "I remember you!")


func test_is_flag() -> void:
	var chat_tree: ChatTree
	
	chat_tree = _chat_tree_from_file(CHAT_SET_FLAG_STRING)
	assert_eq(chat_tree.get_event().text, "Hello!")
	
	PlayerData.chat_history.set_flag("adventurous_classy", "achiever")
	
	chat_tree = _chat_tree_from_file(CHAT_SET_FLAG_STRING)
	assert_eq(chat_tree.get_event().text, "Hello!")

	PlayerData.chat_history.set_flag("adventurous_classy", "capable")
	
	chat_tree = _chat_tree_from_file(CHAT_SET_FLAG_STRING)
	assert_eq(chat_tree.get_event().text, "I remember you!")


func test_unset_flag() -> void:
	var chat_tree: ChatTree
	
	PlayerData.chat_history.set_flag("adventurous_classy", "capable")
	
	chat_tree = _chat_tree_from_file(CHAT_SET_FLAG_STRING)
	assert_eq(PlayerData.chat_history.get_flag("adventurous_classy"), "capable")
	
	# advancing the chat tree hits an 'unset_flag' meta item
	chat_tree.advance()
	assert_eq(PlayerData.chat_history.get_flag("adventurous_classy"), "")


func test_set_phrase() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_SET_PHRASE)
	assert_eq(PlayerData.chat_history.get_phrase("tall_cluttered"), "")
	
	chat_tree.advance()
	assert_eq(PlayerData.chat_history.get_phrase("tall_cluttered"), "Frequent Straw")


func test_has_phrase() -> void:
	var chat_tree: ChatTree
	
	chat_tree = _chat_tree_from_file(CHAT_SET_PHRASE)
	assert_eq(chat_tree.get_event().text, "Hello!")
	
	PlayerData.chat_history.set_phrase("tall_cluttered", "Frequent Straw")
	
	chat_tree = _chat_tree_from_file(CHAT_SET_PHRASE)
	assert_eq(chat_tree.get_event().text, "I remember you!")


func test_default_phrase() -> void:
	var chat_tree := _chat_tree_from_file(CHAT_DEFAULT_PHRASE)
	assert_eq(PlayerData.chat_history.get_phrase("tall_cluttered"), "")
	
	chat_tree.advance()
	assert_eq(PlayerData.chat_history.get_phrase("tall_cluttered"), "Frequent Straw")


func test_default_phrase_doesnt_overwrite() -> void:
	PlayerData.chat_history.set_phrase("tall_cluttered", "Wreck Lean")
	
	var chat_tree := _chat_tree_from_file(CHAT_DEFAULT_PHRASE)
	assert_eq(PlayerData.chat_history.get_phrase("tall_cluttered"), "Wreck Lean")
	
	# the 'default_phrase' meta item should not overwrite a phrase which is already saved
	chat_tree.advance()
	assert_eq(PlayerData.chat_history.get_phrase("tall_cluttered"), "Wreck Lean")


func _chat_tree_from_file(path: String) -> ChatTree:
	var parser := ChatscriptParser.new()
	var chat_tree := parser.chat_tree_from_file(path)
	chat_tree.prepare_first_chat_event()
	return chat_tree
