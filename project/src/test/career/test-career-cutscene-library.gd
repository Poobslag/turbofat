extends GutTest

func before_each() -> void:
	ChatLibrary.chat_key_root_path = "res://assets/test"
	PlayerData.chat_history.reset()
	PlayerData.career.reset()


func after_each() -> void:
	ChatLibrary.chat_key_root_path = ChatLibrary.DEFAULT_CHAT_KEY_ROOT_PATH
	CareerCutsceneLibrary.career_cutscene_root_path = CareerCutsceneLibrary.DEFAULT_CAREER_CUTSCENE_ROOT_PATH


func test_load_all_chat_keys() -> void:
	CareerCutsceneLibrary.career_cutscene_root_path = "res://assets/test/career/fake-career"
	
	_assert_eq_ckp(CareerCutsceneLibrary.all_chat_key_pairs, [
		_interlude("career/fake_career/general/000_a", ""),
		_interlude("career/fake_career/general/000_b", ""),
		_interlude("career/fake_career/marsh/000", "career/fake_career/marsh/000_end"),
		_interlude("career/fake_career/marsh/010_a", ""),
		_interlude("career/fake_career/marsh/010_b", ""),
		_interlude("", "career/fake_career/marsh/010_c_end"),
		_interlude("career/fake_career/marsh/020", ""),
		_interlude("career/fake_career/marsh/030_a", ""),
		_interlude("career/fake_career/marsh/030_b", ""),
	])


func test_find_chat_key_pairs() -> void:
	CareerCutsceneLibrary.career_cutscene_root_path = "res://assets/test/career/fake-career"
	
	var search_flags := CutsceneSearchFlags.new()
	search_flags.include_all_numeric_children = true
	var chat_key_pairs := CareerCutsceneLibrary.find_chat_key_pairs(["career/fake_career/marsh"], search_flags)
	_assert_eq_ckp(chat_key_pairs, [
		_interlude("career/fake_career/marsh/000", "career/fake_career/marsh/000_end"),
		_interlude("career/fake_career/marsh/010_a", ""),
		_interlude("career/fake_career/marsh/010_b", ""),
		_interlude("", "career/fake_career/marsh/010_c_end"),
		_interlude("career/fake_career/marsh/020", ""),
		_interlude("career/fake_career/marsh/030_a", ""),
		_interlude("career/fake_career/marsh/030_b", ""),
	])


func test_potential_chat_keys_letter() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		_interlude("career/fake_career/general/000_a", ""),
		_interlude("career/fake_career/general/000_b", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career/general"
	]), [
		_interlude("career/fake_career/general/000_a", ""),
		_interlude("career/fake_career/general/000_b", ""),
	])


func test_potential_chat_keys_number() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		_interlude("career/fake_career/general/000_0", ""),
		_interlude("career/fake_career/general/000_1", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career/general"
	]), [
		_interlude("career/fake_career/general/000_0", ""),
	])


func test_potential_chat_keys_letter_and_number() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include number/letter keys at same level
		_interlude("career/fake_career/general/000_a", ""),
		_interlude("career/fake_career/general/000_0", ""),
		_interlude("career/fake_career/general/000_1", ""),
		_interlude("career/fake_career/general/000_b", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career/general"
	]), [
		# letter keys are intermingled with the lowest number key
		_interlude("career/fake_career/general/000_0", ""),
		_interlude("career/fake_career/general/000_a", ""),
		_interlude("career/fake_career/general/000_b", ""),
	])


func test_potential_chat_keys_ignore_other_numeric_branches() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include two unrelated numeric branches
		_interlude("career/fake_career/general/000_0", ""),
		_interlude("career/fake_career/general/000_0_a", ""),
		_interlude("career/fake_career/general/000_0_b", ""),
		_interlude("career/fake_career/general/000_1", ""),
		_interlude("career/fake_career/general/000_1_a", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career/general"
	]), [
		# only return scenes in first numeric branch
		_interlude("career/fake_career/general/000_0_a", ""),
		_interlude("career/fake_career/general/000_0_b", ""),
	])


func test_potential_chat_keys_include_other_letter_branches() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include two unrelated letter branches
		_interlude("career/fake_career/general/000_a", ""),
		_interlude("career/fake_career/general/000_a_0", ""),
		_interlude("career/fake_career/general/000_a_1", ""),
		_interlude("career/fake_career/general/000_b", ""),
		_interlude("career/fake_career/general/000_b_0", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career/general"
	]), [
		# return scenes in both letter branches
		_interlude("career/fake_career/general/000_a_0", ""),
		_interlude("career/fake_career/general/000_b_0", ""),
	])


func test_potential_chat_keys_exclude_played_leaf() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		_interlude("career/fake_career/general/000_0", ""),
		_interlude("career/fake_career/general/000_1", ""),
	]
	PlayerData.chat_history.add_history_item("career/fake_career/general/000_0")
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career/general"
	]), [
		_interlude("career/fake_career/general/000_1", ""),
	])


func test_potential_chat_keys_exclude_played_branch() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		_interlude("career/fake_career/general/000_0_a", ""),
		_interlude("", "career/fake_career/general/000_0_b_end"),
		_interlude("career/fake_career/general/000_1_a", ""),
	]
	PlayerData.chat_history.add_history_item("career/fake_career/general/000_0_a")
	PlayerData.chat_history.add_history_item("career/fake_career/general/000_0_b_end")
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career/general"
	]), [
		# only return scenes in second numeric branch
		_interlude("career/fake_career/general/000_1_a", ""),
	])


func test_potential_chat_keys_includes_chef() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		_interlude("career/fake_career_2/a", ""),
		_interlude("career/fake_career_2/b", ""),
		_interlude("career/fake_career_2/c", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career_2"
	], "skins"), [
		# only return scenes with skins as a chef
		_interlude("career/fake_career_2/a", ""),
	])


func test_potential_chat_keys_includes_customer() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# cutscenes include a numeric branch with no remaining cutscenes
		_interlude("career/fake_career_2/a", ""),
		_interlude("career/fake_career_2/b", ""),
		_interlude("career/fake_career_2/c", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career_2"
	], "", "rhonk"), [
		# only return scenes with rhonk as a customer
		_interlude("career/fake_career_2/b", ""),
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
		_interlude("career/fake_career_2/a", ""),
		_interlude("career/fake_career_2/b", ""),
		_interlude("career/fake_career_2/c", ""),
	]
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career_2"
	], "", CareerLevel.NONQUIRKY_CUSTOMER), [
		# only return scenes with no named chefs/customers
		_interlude("career/fake_career_2/c", ""),
	])


func test_potential_chat_keys_excludes_boss_levels() -> void:
	CareerCutsceneLibrary.all_chat_key_pairs = [
		# include post-boss cutscenes, cutscenes numbered 100-199
		_interlude("career/fake_career_2/100_a", ""),
		_interlude("career/fake_career_2/100_b", ""),
	]
	
	PlayerData.career.best_distance_travelled = 100
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career_2"
	]), [
		# player has cleared the boss level, post-boss cutscenes are included
		_interlude("career/fake_career_2/100_a", ""),
		_interlude("career/fake_career_2/100_b", ""),
	])
	
	PlayerData.career.best_distance_travelled = 0
	_assert_eq_ckp(CareerCutsceneLibrary.potential_chat_key_pairs([
		"career/fake_career_2"
	]), [
		# player hasn't cleared the boss level, post-boss cutscenes are excluded
	])


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
