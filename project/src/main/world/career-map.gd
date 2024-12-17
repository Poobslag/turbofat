extends Node
## Scene which shows the player's progress through career mode.
##
## Launching this scene also advances the player towards their goal if 'distance earned' is nonzero.

## Number of levels the player can choose between
const SELECTION_COUNT := 3

## Chefs/customers for each level the player can select
var _level_posses := []

## LevelSettings instances for each level the player can select
var _pickable_level_settings := []

## CareerLevel instances for each level the player can select
var _pickable_career_levels := []

## ChatKeyPair instances for cutscenes for each level the player can select.
##
## If there is no cutscene is shown, an empty ChatKeyPair is stored as a placeholder.
var _pickable_chat_key_pairs := []

## PieceSpeed for all levels the player can select.
var _piece_speed: String

var _career_cutscene_librarian := CareerCutsceneLibrarian.new()

onready var _world := $World
onready var _distance_label := $Ui/Control/StatusBar/Distance
onready var _level_select_control := $LevelSelect

func _ready() -> void:
	if not Breadcrumb.trail:
		# For developers accessing the CareerMap scene directly, we initialize a default Breadcrumb trail.
		# For regular players the Breadcrumb trail will already be initialized by the menus.
		Breadcrumb.initialize_trail()
	
	if PlayerData.career.is_boss_level() and PlayerData.career.can_play_more_levels() \
			and (PlayerData.career.show_progress != Careers.ShowProgress.ANIMATED):
		MusicPlayer.play_boss_track()
	else:
		MusicPlayer.play_menu_track()
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	
	var redirected := false
	
	# if they haven't seen this region's prologue, redirect them to the prologue cutscene
	if not redirected and PlayerData.career.should_play_prologue():
		PlayerData.career.push_career_trail()
		redirected = true
	
	if not redirected:
		_refresh_ui()
		if PlayerData.career.show_progress == Careers.ShowProgress.NONE:
			# Ordinarily, we focus the level button after the progress board vanishes. But if the progress board is not
			# being shown, we focus the button right away.
			_after_progress_board()


## When the career map is removed from the tree, we disconnect the 'distance_travelled_changed' listener
##
## If we don't disconnect this listener, we receive errors during scene changes because updating the scene causes us
## to look for creatures in a non-existent scene tree. These errors are caused by Breadcrumb's Godot #85692 workaround
## which delays the freeing of nodes in the previous scene.
func _exit_tree() -> void:
	if PlayerData.career.is_connected("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed"):
		PlayerData.career.disconnect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")


func _refresh_ui() -> void:
	_load_level_settings()
	_refresh_level_select_buttons()


## Loads level settings for three randomly selected levels from the current CareerRegion.
func _load_level_settings() -> void:
	_pickable_level_settings.clear()
	_pickable_career_levels.clear()
	_pickable_chat_key_pairs.clear()
	
	var region: CareerRegion = PlayerData.career.current_region()
	# decide available career levels
	if PlayerData.career.is_boss_level():
		_pickable_career_levels = [region.boss_level]
	elif PlayerData.career.is_intro_level():
		_pickable_career_levels = [region.intro_level]
	else:
		_pickable_career_levels = _random_levels()
	
	# decide available cutscenes
	for pickable_career_level in _pickable_career_levels:
		_pickable_chat_key_pairs.append(_career_cutscene_librarian.chat_key_pair(pickable_career_level))
	
	# decide piece speed
	if PlayerData.career.is_boss_level():
		_piece_speed = ""
	else:
		if region.has_end():
			_piece_speed = CareerLevelLibrary.piece_speed_for_distance(PlayerData.career.distance_travelled)
		else:
			var weight: float = float(PlayerData.career.hours_passed) / (Careers.HOURS_PER_CAREER_DAY - 1)
			_piece_speed = CareerLevelLibrary.piece_speed_between(region.min_piece_speed, region.max_piece_speed,
					weight)
	
	# initialize level settings
	for level in _pickable_career_levels:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level.level_id)
		LevelSpeedAdjuster.new(level_settings).adjust(_piece_speed)
		_pickable_level_settings.append(level_settings)
	
	# twice per career day, we let the player pick a hardcore level
	if PlayerData.career.hours_passed in PlayerData.career.forced_hardcore_level_hours \
			and _pickable_career_levels.size() > 1:
		var level_settings: LevelSettings = _pickable_level_settings.back()
		level_settings.lose_condition.top_out = 1
	
	_level_posses = []
	for i in range(_pickable_career_levels.size()):
		_level_posses.append(_new_level_posse(i))
	_world.refresh_from_career_data(_level_posses)


## Recreates all level select buttons in the scene tree based on the current level settings.
func _refresh_level_select_buttons() -> void:
	_level_select_control.clear_level_select_buttons()
	
	for i in range(_pickable_level_settings.size()):
		var level_settings: LevelSettings = _pickable_level_settings[i]
		var level_select_button: LevelSelectButton = _level_select_control.add_level_select_button(level_settings)
		level_select_button.connect("level_chosen", self, "_on_LevelSelectButton_level_chosen", [i])


## Return a list of random CareerLevels for the player to choose from.
##
## We only select levels appropriate for the current distance, and we exclude levels which have been played in the
## current session.
func _random_levels() -> Array:
	var levels: Array = CareerLevelLibrary.career_levels_for_distance(PlayerData.career.distance_travelled)
	levels = levels.duplicate() # avoid modifying the original list
	
	# We use a seeded shuffle which always gives the player the same random levels. Otherwise they can relaunch career
	# mode over and over until they get the exact levels they want to play.
	var seed_int := 0
	seed_int += PlayerData.career.money
	seed_int += PlayerData.career.hours_passed
	if PlayerData.career.prev_money:
		seed_int += PlayerData.career.prev_money[0]
	Utils.seeded_shuffle(levels, seed_int)
	
	# filter the levels based on which ones the player's unlocked
	levels = CareerLevelLibrary.trim_levels_by_available_if(levels)
	
	if _career_cutscene_librarian.chat_key_pair(null).type == ChatKeyPair.INTERLUDE:
		# filter the levels based on the required chefs/customers for the possible upcoming interludes
		var region := PlayerData.career.current_region()
		var required_cutscene_characters: Dictionary = CareerLevelLibrary.required_cutscene_characters(region)
		levels = CareerLevelLibrary.trim_levels_by_characters(region, levels,
				required_cutscene_characters.chef_ids,
				required_cutscene_characters.customer_ids,
				required_cutscene_characters.observer_ids)
		if not levels:
			push_warning("Can't find any levels for distance=%s, chef_ids=%s, customer_ids=%s observer_ids=%s" %
					[PlayerData.career.distance_travelled,
					required_cutscene_characters.chef_ids,
					required_cutscene_characters.customer_ids,
					required_cutscene_characters.observer_ids])
	
	# calculate a list of levels the player hasn't played in this career session
	var unplayed_levels := []
	for level in levels:
		if not level.level_id in PlayerData.career.level_ids:
			unplayed_levels.append(level)
	
	# calculate a random set of levels for the player, and replace any the player's played if possible
	var random_levels := levels.slice(0, min(SELECTION_COUNT - 1, levels.size() - 1))
	unplayed_levels = Utils.subtract(unplayed_levels, random_levels)
	for random_level_index in range(random_levels.size()):
		if unplayed_levels.empty():
			break
		
		if random_levels[random_level_index].level_id in PlayerData.career.level_ids:
			random_levels[random_level_index] = unplayed_levels.pop_front()
	
	return random_levels


## Calculates which creatures should appear for a career level.
##
## This can potentially include creatures which are important to a level, creatures which appear in a cutscene, or
## creatures which randomly show up sometimes in a region.
##
## This can also include special characters like the player or Fat Sensei.
func _new_level_posse(level_index: int) -> LevelPosse:
	var career_level: CareerLevel = _pickable_career_levels[level_index]
	var chat_key_pair: ChatKeyPair = _pickable_chat_key_pairs[level_index]
	
	var level_posse := LevelPosse.new()
	
	# add customers/chefs from the cutscene
	for chat_key in chat_key_pair.chat_keys():
		var chat_tree: ChatTree = ChatLibrary.chat_tree_for_key(chat_key)
		if chat_tree.chef_id:
			level_posse.chef_id = chat_tree.chef_id
		if chat_tree.customer_ids:
			level_posse.customer_ids = chat_tree.customer_ids.duplicate()
		if chat_tree.observer_id:
			level_posse.observer_id = chat_tree.observer_id
		if chat_tree.puzzle_environment_id:
			level_posse.puzzle_environment_id = chat_tree.puzzle_environment_id
	
	# add customers/chefs from the level if the cutscene doesn't define any
	if not level_posse.chef_id:
		level_posse.chef_id = career_level.chef_id
	if not level_posse.customer_ids:
		level_posse.customer_ids = career_level.customer_ids.duplicate()
	if not level_posse.observer_id:
		level_posse.observer_id = career_level.observer_id
	if not level_posse.puzzle_environment_id:
		level_posse.puzzle_environment_id = career_level.puzzle_environment_id
	
	# add customers/chefs from the region if the level doesn't define any
	var region := PlayerData.career.current_region()
	if not level_posse.customer_ids:
		var customer: Population.CreatureAppearance = region.population.random_customer()
		if customer:
			level_posse.customer_ids = [customer.id]
	if not level_posse.chef_id:
		var chef: Population.CreatureAppearance = region.population.random_chef()
		if chef:
			level_posse.chef_id = chef.id
	if not level_posse.observer_id:
		var observer: Population.CreatureAppearance = region.population.random_observer()
		if observer:
			level_posse.observer_id = observer.id
	if not level_posse.puzzle_environment_id:
		level_posse.puzzle_environment_id = region.puzzle_environment_id
	
	return level_posse


func _should_play_epilogue(chat_key_pair: ChatKeyPair) -> bool:
	var result := true
	var region := PlayerData.career.current_region()
	
	if not region.cutscene_path:
		# no cutscenes for region; do not play epilogue
		result = false
	
	if result and not ChatLibrary.chat_exists(region.get_epilogue_chat_key()):
		# no epilogue for region; do not play epilogue
		result = false
	
	if result and PlayerData.chat_history.is_chat_finished(region.get_epilogue_chat_key()):
		# player has already seen epilogue; do not play epilogue
		result = false
	
	if result:
		# derive the preroll key from the chat_key_pair
		var preroll_key: String = chat_key_pair.preroll
		if not preroll_key: preroll_key = chat_key_pair.postroll.trim_suffix("_end")
		
		# determine if any cutscenes will remain after this cutscene was played
		var search_flags := CutsceneSearchFlags.new()
		search_flags.include_all_numeric_children = true
		search_flags.max_chat_key = 199 # exclude post-epilogue cutscenes
		search_flags.excluded_chat_keys = CareerCutsceneLibrary.exhausted_chat_keys([region.cutscene_path])
		search_flags.exclude_chat_key(preroll_key)
		var remaining_chat_key_pairs: Array = CareerCutsceneLibrary.find_chat_key_pairs([region.cutscene_path],
				search_flags)
		
		if remaining_chat_key_pairs:
			# this is not the last cutscene; do not play epilogue
			result = false
	
	return result


## After the progress board is shown, the player is either redirected to the career win screen, or we focus one of the
## level buttons.
##
## If the progress board is not being shown, this happens at the start of the level.
func _after_progress_board() -> void:
	if not PlayerData.career.can_play_more_levels():
		# After the final level, we show a 'you win' screen.
		SceneTransition.replace_trail(Global.SCENE_CAREER_WIN)
	else:
		_level_select_control.focus_button()


## When the player clicks a level button twice, we launch the selected level
func _on_LevelSelectButton_level_chosen(level_index: int) -> void:
	if PlayerData.career.is_connected("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed"):
		# avoid changing the level button names when you pick an earlier level
		PlayerData.career.disconnect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	
	# apply a distance penalty if they select an earlier level
	var distance_penalty: int = PlayerData.career.distance_penalties()[level_index]
	PlayerData.career.distance_travelled -= distance_penalty
	PlayerData.career.steps -= distance_penalty
	PlayerData.career.progress_board_start_distance_travelled = PlayerData.career.distance_travelled
	_distance_label.suppress_distance_penalty()
	
	var level_settings: LevelSettings = _pickable_level_settings[level_index]
	var chat_key_pair: ChatKeyPair = _pickable_chat_key_pairs[level_index]
	
	PlayerData.career.level_ids.append(level_settings.id)
	CurrentLevel.set_launched_level(level_settings.id)
	CurrentLevel.piece_speed = _piece_speed
	CurrentLevel.hardcore = level_settings.lose_condition.top_out == 1
	CurrentLevel.boss_level = PlayerData.career.is_boss_level()
	
	var level_posse: LevelPosse = _level_posses[level_index]
	CurrentLevel.customers = level_posse.customer_ids
	CurrentLevel.chef_id = level_posse.chef_id
	CurrentLevel.puzzle_environment_id = level_posse.puzzle_environment_id
	
	if _pickable_career_levels.size() == 1 or not CurrentLevel.customers:
		# Append filler customers for the selected level.
		#
		# For boss/intro levels, this appends the 1-2 extra filler customers who appear alongside the main creature.
		#
		# For regular levels, this appends the one randomly generated customer.
		var other_customers := []
		for customer in _world.get_visible_customers(level_index):
			if CurrentLevel.has_customer(customer):
				continue
			
			other_customers.append(customer.creature_def)
		other_customers.shuffle()
		
		CurrentLevel.customers.append_array(other_customers)
	
	var preroll_key: String = chat_key_pair.preroll
	var postroll_key: String = chat_key_pair.postroll
	
	PlayerData.cutscene_queue.reset()
	
	if preroll_key:
		PlayerData.cutscene_queue.enqueue_cutscene(ChatLibrary.chat_tree_for_key(preroll_key))
	
	PlayerData.cutscene_queue.enqueue_level({
		"level_id": level_settings.id,
		"piece_speed": _piece_speed,
		"chef_id": CurrentLevel.chef_id,
		"customers": CurrentLevel.customers,
		"hardcore": CurrentLevel.hardcore,
		"boss_level": CurrentLevel.boss_level,
		"puzzle_environment_id": CurrentLevel.puzzle_environment_id,
	})
	
	if postroll_key:
		PlayerData.cutscene_queue.enqueue_cutscene(ChatLibrary.chat_tree_for_key(postroll_key))
	
	if preroll_key or postroll_key:
		match chat_key_pair.type:
			ChatKeyPair.INTRO_LEVEL:
				PlayerData.cutscene_queue.set_cutscene_flag("intro_level")
			ChatKeyPair.BOSS_LEVEL:
				PlayerData.cutscene_queue.set_cutscene_flag("boss_level")
	
	if _should_play_epilogue(chat_key_pair):
		var region := PlayerData.career.current_region()
		PlayerData.cutscene_queue.enqueue_cutscene(ChatLibrary.chat_tree_for_key(region.get_epilogue_chat_key()))
	
	PlayerData.career.push_career_trail()


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_ui()
	
	# Restore focus to the level select buttons for controller players. This is necessary for the 'MOVEME' cheat which
	# regenerates these buttons.
	_level_select_control.focus_button()


func _on_ProgressBoardHolder_progress_board_hidden() -> void:
	_after_progress_board()
