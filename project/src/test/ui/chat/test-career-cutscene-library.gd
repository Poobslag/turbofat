extends "res://addons/gut/test.gd"

func before_each() -> void:
	PlayerData.chat_history.reset()


func after_each() -> void:
	CareerCutsceneLibrary.career_cutscene_root_path = CareerCutsceneLibrary.DEFAULT_CAREER_CUTSCENE_ROOT_PATH


func test_load_all_chat_keys() -> void:
	CareerCutsceneLibrary.career_cutscene_root_path = "res://assets/test/ui/chat/fake-career"
	
	assert_eq_deep(CareerCutsceneLibrary.all_chat_key_pairs, [
		{"preroll": "ui/chat/fake_career/general/00_a"},
		{"preroll": "ui/chat/fake_career/general/00_b"},
		{"preroll": "ui/chat/fake_career/marsh/00", "postroll": "ui/chat/fake_career/marsh/00_end"},
		{"preroll": "ui/chat/fake_career/marsh/10_a"},
		{"preroll": "ui/chat/fake_career/marsh/10_b"},
		{"postroll": "ui/chat/fake_career/marsh/10_c_end"},
	])


func test_potential_chat_keys_letter() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		{"preroll": "ui/chat/fake_career/general/00_a"},
		{"preroll": "ui/chat/fake_career/general/00_b"},
	]
	assert_eq_deep(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		{"preroll": "ui/chat/fake_career/general/00_a"},
		{"preroll": "ui/chat/fake_career/general/00_b"},
	])


func test_potential_chat_keys_number() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		{"preroll": "ui/chat/fake_career/general/00_0"},
		{"preroll": "ui/chat/fake_career/general/00_1"},
	]
	assert_eq_deep(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		{"preroll": "ui/chat/fake_career/general/00_0"},
	])


func test_potential_chat_keys_letter_and_number() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include number/letter keys at same level
		{"preroll": "ui/chat/fake_career/general/00_a"},
		{"preroll": "ui/chat/fake_career/general/00_0"},
		{"preroll": "ui/chat/fake_career/general/00_1"},
		{"preroll": "ui/chat/fake_career/general/00_b"},
	]
	assert_eq_deep(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# letter keys are intermingled with the lowest number key
		{"preroll": "ui/chat/fake_career/general/00_0"},
		{"preroll": "ui/chat/fake_career/general/00_a"},
		{"preroll": "ui/chat/fake_career/general/00_b"},
	])


func test_potential_chat_keys_ignore_other_numeric_branches() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include two unrelated numeric branches
		{"preroll": "ui/chat/fake_career/general/00_0"},
		{"preroll": "ui/chat/fake_career/general/00_0_a"},
		{"preroll": "ui/chat/fake_career/general/00_0_b"},
		{"preroll": "ui/chat/fake_career/general/00_1"},
		{"preroll": "ui/chat/fake_career/general/00_1_a"},
	]
	assert_eq_deep(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# only return scenes in first numeric branch
		{"preroll": "ui/chat/fake_career/general/00_0_a"},
		{"preroll": "ui/chat/fake_career/general/00_0_b"},
	])


func test_potential_chat_keys_include_other_letter_branches() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include two unrelated letter branches
		{"preroll": "ui/chat/fake_career/general/00_a"},
		{"preroll": "ui/chat/fake_career/general/00_a_0"},
		{"preroll": "ui/chat/fake_career/general/00_a_1"},
		{"preroll": "ui/chat/fake_career/general/00_b"},
		{"preroll": "ui/chat/fake_career/general/00_b_0"},
	]
	assert_eq_deep(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# return scenes in both letter branches
		{"preroll": "ui/chat/fake_career/general/00_a_0"},
		{"preroll": "ui/chat/fake_career/general/00_b_0"},
	])


func test_potential_chat_keys_exclude_played_leaf() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		{"preroll": "ui/chat/fake_career/general/00_0"},
		{"preroll": "ui/chat/fake_career/general/00_1"},
	]
	PlayerData.chat_history.add_history_item("ui/chat/fake_career/general/00_0")
	assert_eq_deep(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		{"preroll": "ui/chat/fake_career/general/00_1"},
	])


func test_potential_chat_keys_exclude_played_branch() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		{"preroll": "ui/chat/fake_career/general/00_0_a"},
		{"postroll": "ui/chat/fake_career/general/00_0_b_end"},
		{"preroll": "ui/chat/fake_career/general/00_1_a"},
	]
	PlayerData.chat_history.add_history_item("ui/chat/fake_career/general/00_0_a")
	PlayerData.chat_history.add_history_item("ui/chat/fake_career/general/00_0_b_end")
	assert_eq_deep(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# only return scenes in second numeric branch
		{"preroll": "ui/chat/fake_career/general/00_1_a"},
	])
