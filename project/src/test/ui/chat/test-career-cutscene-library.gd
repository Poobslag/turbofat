extends "res://addons/gut/test.gd"

func before_each() -> void:
	ChatLibrary.chat_key_root_path = "res://assets/test"
	PlayerData.chat_history.reset()
	PlayerData.career.reset()


func after_each() -> void:
	ChatLibrary.chat_key_root_path = ChatLibrary.DEFAULT_CHAT_KEY_ROOT_PATH
	CareerCutsceneLibrary.career_cutscene_root_path = CareerCutsceneLibrary.DEFAULT_CAREER_CUTSCENE_ROOT_PATH


func _interlude(preroll: String, postroll: String) -> ChatKeyPair:
	var result := ChatKeyPair.new()
	result.from_json_dict({
		"type": "interlude",
		"preroll": preroll,
		"postroll": postroll,
	})
	return result


## Compares two ChatKeyPair arrays.
func _assert_eq_ckp(actual_chat_key_pairs: Array, expected_chat_key_pairs: Array) -> void:
	var actual_dicts := []
	for actual_pair in actual_chat_key_pairs:
		actual_dicts.append(actual_pair.to_json_dict())
	var expected_dicts := []
	for expected_pair in expected_chat_key_pairs:
		expected_dicts.append(expected_pair.to_json_dict())
	assert_eq_deep(actual_dicts, expected_dicts)


func test_load_all_chat_keys() -> void:
	CareerCutsceneLibrary.career_cutscene_root_path = "res://assets/test/ui/chat/fake-career"
	
	_assert_eq_ckp(CareerCutsceneLibrary.all_chat_key_pairs, [
		_interlude("ui/chat/fake_career/general/00_a", ""),
		_interlude("ui/chat/fake_career/general/00_b", ""),
		_interlude("ui/chat/fake_career/marsh/00", "ui/chat/fake_career/marsh/00_end"),
		_interlude("ui/chat/fake_career/marsh/10_a", ""),
		_interlude("ui/chat/fake_career/marsh/10_b", ""),
		_interlude("", "ui/chat/fake_career/marsh/10_c_end"),
		_interlude("ui/chat/fake_career/marsh/20", ""),
		_interlude("ui/chat/fake_career/marsh/30_a", ""),
		_interlude("ui/chat/fake_career/marsh/30_b", ""),
	])


func test_find_chat_key_pairs() -> void:
	CareerCutsceneLibrary.career_cutscene_root_path = "res://assets/test/ui/chat/fake-career"
	
	var search_flags := CutsceneSearchFlags.new()
	search_flags.include_all_numeric_children = true
	var chat_key_pairs := CareerCutsceneLibrary.find_chat_key_pairs(["ui/chat/fake_career/marsh"], search_flags)
	_assert_eq_ckp(chat_key_pairs, [
		_interlude("ui/chat/fake_career/marsh/00", "ui/chat/fake_career/marsh/00_end"),
		_interlude("ui/chat/fake_career/marsh/10_a", ""),
		_interlude("ui/chat/fake_career/marsh/10_b", ""),
		_interlude("", "ui/chat/fake_career/marsh/10_c_end"),
		_interlude("ui/chat/fake_career/marsh/20", ""),
		_interlude("ui/chat/fake_career/marsh/30_a", ""),
		_interlude("ui/chat/fake_career/marsh/30_b", ""),
	])


func test_potential_chat_keys_letter() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		_interlude("ui/chat/fake_career/general/00_a", ""),
		_interlude("ui/chat/fake_career/general/00_b", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		_interlude("ui/chat/fake_career/general/00_a", ""),
		_interlude("ui/chat/fake_career/general/00_b", ""),
	])


func test_potential_chat_keys_number() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		_interlude("ui/chat/fake_career/general/00_0", ""),
		_interlude("ui/chat/fake_career/general/00_1", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		_interlude("ui/chat/fake_career/general/00_0", ""),
	])


func test_potential_chat_keys_letter_and_number() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include number/letter keys at same level
		_interlude("ui/chat/fake_career/general/00_a", ""),
		_interlude("ui/chat/fake_career/general/00_0", ""),
		_interlude("ui/chat/fake_career/general/00_1", ""),
		_interlude("ui/chat/fake_career/general/00_b", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# letter keys are intermingled with the lowest number key
		_interlude("ui/chat/fake_career/general/00_0", ""),
		_interlude("ui/chat/fake_career/general/00_a", ""),
		_interlude("ui/chat/fake_career/general/00_b", ""),
	])


func test_potential_chat_keys_ignore_other_numeric_branches() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include two unrelated numeric branches
		_interlude("ui/chat/fake_career/general/00_0", ""),
		_interlude("ui/chat/fake_career/general/00_0_a", ""),
		_interlude("ui/chat/fake_career/general/00_0_b", ""),
		_interlude("ui/chat/fake_career/general/00_1", ""),
		_interlude("ui/chat/fake_career/general/00_1_a", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# only return scenes in first numeric branch
		_interlude("ui/chat/fake_career/general/00_0_a", ""),
		_interlude("ui/chat/fake_career/general/00_0_b", ""),
	])


func test_potential_chat_keys_include_other_letter_branches() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include two unrelated letter branches
		_interlude("ui/chat/fake_career/general/00_a", ""),
		_interlude("ui/chat/fake_career/general/00_a_0", ""),
		_interlude("ui/chat/fake_career/general/00_a_1", ""),
		_interlude("ui/chat/fake_career/general/00_b", ""),
		_interlude("ui/chat/fake_career/general/00_b_0", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# return scenes in both letter branches
		_interlude("ui/chat/fake_career/general/00_a_0", ""),
		_interlude("ui/chat/fake_career/general/00_b_0", ""),
	])


func test_potential_chat_keys_exclude_played_leaf() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		_interlude("ui/chat/fake_career/general/00_0", ""),
		_interlude("ui/chat/fake_career/general/00_1", ""),
	]
	PlayerData.chat_history.add_history_item("ui/chat/fake_career/general/00_0")
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		_interlude("ui/chat/fake_career/general/00_1", ""),
	])


func test_potential_chat_keys_exclude_played_branch() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		_interlude("ui/chat/fake_career/general/00_0_a", ""),
		_interlude("", "ui/chat/fake_career/general/00_0_b_end"),
		_interlude("ui/chat/fake_career/general/00_1_a", ""),
	]
	PlayerData.chat_history.add_history_item("ui/chat/fake_career/general/00_0_a")
	PlayerData.chat_history.add_history_item("ui/chat/fake_career/general/00_0_b_end")
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career/general"
	]), [
		# only return scenes in second numeric branch
		_interlude("ui/chat/fake_career/general/00_1_a", ""),
	])


func test_potential_chat_keys_includes_chef() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		_interlude("ui/chat/fake_career_2/a", ""),
		_interlude("ui/chat/fake_career_2/b", ""),
		_interlude("ui/chat/fake_career_2/c", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career_2"
	], "skins"), [
		# only return scenes with skins as a chef
		_interlude("ui/chat/fake_career_2/a", ""),
	])


func test_potential_chat_keys_includes_customer() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		_interlude("ui/chat/fake_career_2/a", ""),
		_interlude("ui/chat/fake_career_2/b", ""),
		_interlude("ui/chat/fake_career_2/c", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career_2"
	], "", "rhonk"), [
		# only return scenes with rhonk as a customer
		_interlude("ui/chat/fake_career_2/b", ""),
	])


func test_potential_chat_keys_includes_unnamed_customers() -> void:
	# define some quirky creatures to ignore
	var rhonk := Population.CreatureAppearance.new()
	rhonk.from_json_string("(quirky) rhonk")
	PlayerData.career.current_region().population.customers.append(rhonk)
	var skins := Population.CreatureAppearance.new()
	skins.from_json_string("(quirky) skins")
	PlayerData.career.current_region().population.chefs.append(skins)
	
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		_interlude("ui/chat/fake_career_2/a", ""),
		_interlude("ui/chat/fake_career_2/b", ""),
		_interlude("ui/chat/fake_career_2/c", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"ui/chat/fake_career_2"
	], "", CareerLevel.NONQUIRKY_CUSTOMER), [
		# only return scenes with no named chefs/customers
		_interlude("ui/chat/fake_career_2/c", ""),
	])
