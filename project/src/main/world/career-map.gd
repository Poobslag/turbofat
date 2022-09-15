extends Node
## Scene which shows the player's progress through career mode.
##
## Launching this scene also advances the player towards their goal if 'distance earned' is nonzero.

## The number of levels the player can choose between
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

onready var _world := $World
onready var _distance_label := $Ui/Control/StatusBar/Distance
onready var _level_select_control := $LevelSelect

func _ready() -> void:
	ResourceCache.substitute_singletons()
	
	if not Breadcrumb.trail:
		# For developers accessing the CareerMap scene directly, we initialize a default Breadcrumb trail.
		# For regular players the Breadcrumb trail will already be initialized by the menus.
		Breadcrumb.initialize_trail()
	
	MusicPlayer.play_chill_bgm()
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	
	var redirected := false
	
	# if they've played eight levels, redirect them to the 'you win' screen
	if not redirected and PlayerData.career.is_day_over():
		PlayerData.career.push_career_trail()
		redirected = true
	
	# if they haven't seen this region's prologue, redirect them to the prologue cutscene
	if not redirected and PlayerData.career.should_play_prologue():
		PlayerData.career.push_career_trail()
		redirected = true
	
	if not redirected:
		_refresh_ui()
		_level_select_control.focus_button()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


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
	for i in range(_pickable_career_levels.size()):
		_pickable_chat_key_pairs.append(_chat_key_pair(_pickable_career_levels[i]))
	
	# decide piece speed
	if PlayerData.career.is_boss_level():
		_piece_speed = ""
	else:
		if region.length == CareerData.MAX_DISTANCE_TRAVELLED:
			var weight: float = float(PlayerData.career.hours_passed) / (CareerData.HOURS_PER_CAREER_DAY - 1)
			_piece_speed = CareerLevelLibrary.piece_speed_between(region.min_piece_speed, region.max_piece_speed, weight)
		else:
			_piece_speed = CareerLevelLibrary.piece_speed_for_distance(PlayerData.career.distance_travelled)
	
	# initialize level settings
	for level in _pickable_career_levels:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level.level_id)
		LevelSpeedAdjuster.new(level_settings).adjust(_piece_speed)
		_pickable_level_settings.append(level_settings)
	
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
	seed_int += PlayerData.career.daily_earnings
	seed_int += PlayerData.career.hours_passed
	if PlayerData.career.prev_daily_earnings:
		seed_int += PlayerData.career.prev_daily_earnings[0]
	Utils.seeded_shuffle(levels, seed_int)
	
	# filter the levels based on which ones the player's unlocked
	levels = CareerLevelLibrary.trim_levels_by_available_if(levels)
	
	if _chat_key_pair(null).type == ChatKeyPair.INTERLUDE:
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
	
	var random_levels := levels.slice(0, min(SELECTION_COUNT - 1, levels.size() - 1))
	var random_level_index := 0
	for level in levels:
		random_levels[random_level_index] = level
		if level.level_id in PlayerData.career.daily_level_ids:
			# this level has been played in the current session; try the next one
			pass
		else:
			# this level hasn't been played in the current session; add it to the list
			random_level_index += 1
		
		if random_level_index >= random_levels.size():
			# we've found enough levels
			break
	
	return random_levels


## Returns a ChatKeyPair with any unplayed intro cutscenes for the current region.
##
## If the region does not have intro cutscenes or the player has already viewed them, this returns an empty
## ChatKeyPair.
func _intro_chat_key_pair() -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()
	
	var region := PlayerData.career.current_region()
	var preroll_key := region.get_intro_level_preroll_chat_key()
	var postroll_key := region.get_intro_level_postroll_chat_key()
	if ChatLibrary.chat_exists(preroll_key) and not PlayerData.chat_history.is_chat_finished(preroll_key):
		result.preroll = preroll_key
	if ChatLibrary.chat_exists(postroll_key) and not PlayerData.chat_history.is_chat_finished(postroll_key):
		result.postroll = postroll_key
	if not result.empty():
		result.type = ChatKeyPair.INTRO_LEVEL
		
	return result


## Returns a ChatKeyPair with any unplayed boss cutscenes for the current region.
##
## If the region does not have boss  cutscenes or the player has already viewed them, this returns an empty
## ChatKeyPair.
func _boss_chat_key_pair() -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()
	
	var region := PlayerData.career.current_region()
	var preroll_key := region.get_boss_level_preroll_chat_key()
	var postroll_key := region.get_boss_level_postroll_chat_key()
	if ChatLibrary.chat_exists(preroll_key) and not PlayerData.chat_history.is_chat_finished(preroll_key):
		result.preroll = preroll_key
	if ChatLibrary.chat_exists(postroll_key) and not PlayerData.chat_history.is_chat_finished(postroll_key):
		result.postroll = postroll_key
	if not result.empty():
		result.type = ChatKeyPair.BOSS_LEVEL
	
	return result


## Returns a ChatKeyPair with an arbitrary interlude cutscene for the current region.
##
## Parameters:
## 	'career_level': (Optional) The level whose chat key pair should be returned. This is specifically used for the
## 		case where the player is viewing an interlude, and we want the interlude to feature the same creatures
## 		shown in the level. For other cases, this parameter can be null.
func _interlude_chat_key_pair(career_level: CareerLevel) -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()
	
	var region := PlayerData.career.current_region()
	
	# calculate the chef id/customer ids/observer id
	var chef_id: String
	var customer_id: String
	var observer_id: String
	if career_level:
		if career_level.chef_id or career_level.customer_ids or career_level.observer_id:
			chef_id = career_level.chef_id
			customer_id = career_level.customer_ids[0] if career_level.customer_ids else ""
			observer_id = career_level.observer_id
		else:
			customer_id = CareerLevel.NONQUIRKY_CUSTOMER
	
	if region.cutscene_path:
		# find a region-specific cutscene
		result = CareerCutsceneLibrary.next_interlude_chat_key_pair(
				[region.cutscene_path], chef_id, customer_id, observer_id)
	if result.empty():
		# no region-specific cutscene available; find a general cutscene
		result = CareerCutsceneLibrary.next_interlude_chat_key_pair(
				[CareerData.GENERAL_CHAT_KEY_ROOT], chef_id, customer_id, observer_id)
	if not result.empty():
		result.type = ChatKeyPair.INTERLUDE
	
	return result


## Returns an intro, boss, or interlude chat key pair for the current region.
##
## Parameters:
## 	'career_level': (Optional) The level whose chat key pair should be returned. This is specifically used for the
## 		case where the player is viewing an interlude, and we want the interlude to feature the same creatures
## 		shown in the level. For most cases, this parameter can be omitted.
func _chat_key_pair(career_level: CareerLevel) -> ChatKeyPair:
	var result: ChatKeyPair = ChatKeyPair.new()

	# if it's an intro level, return any intro level cutscenes
	if result.empty() and PlayerData.career.is_intro_level():
		result = _intro_chat_key_pair()
	
	# if it's a boss level, return any boss level cutscenes
	if result.empty() and PlayerData.career.is_boss_level():
		result = _boss_chat_key_pair()
	
	# if it's the 3rd or 6th level, return any interludes
	if result.empty() and PlayerData.career.hours_passed in PlayerData.career.career_interlude_hours() \
			and not PlayerData.career.skipped_previous_level:
		result = _interlude_chat_key_pair(career_level)
	
	return result


## Calculates which creatures should appear for a career level.
##
## This can potentially include creatures which are important to a level, creatures which appear in a cutscene, or
## creatures which randomly show up sometimes in a region.
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
	
	# add customers/chefs from the level if the cutscene doesn't define any
	if not level_posse.chef_id:
		level_posse.chef_id = career_level.chef_id
	if not level_posse.customer_ids:
		level_posse.customer_ids = career_level.customer_ids.duplicate()
	if not level_posse.observer_id:
		level_posse.observer_id = career_level.observer_id
	
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
		search_flags.excluded_chat_keys = CareerCutsceneLibrary.exhausted_chat_keys([region.cutscene_path])
		search_flags.exclude_chat_key(preroll_key)
		var remaining_chat_key_pairs: Array = CareerCutsceneLibrary.find_chat_key_pairs([region.cutscene_path], search_flags)
		
		if remaining_chat_key_pairs:
			# this is not the last cutscene; do not play epilogue
			result = false
	
	return result


## When the player clicks a level button twice, we launch the selected level
func _on_LevelSelectButton_level_chosen(level_index: int) -> void:
	if PlayerData.career.is_connected("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed"):
		# avoid changing the level button names when you pick an earlier level
		PlayerData.career.disconnect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	
	# apply a distance penalty if they select an earlier level
	var distance_penalty: int = PlayerData.career.distance_penalties()[level_index]
	PlayerData.career.distance_travelled -= distance_penalty
	PlayerData.career.daily_steps -= distance_penalty
	_distance_label.suppress_distance_penalty()
	
	var level_settings: LevelSettings = _pickable_level_settings[level_index]
	var chat_key_pair: ChatKeyPair = _pickable_chat_key_pairs[level_index]
	
	PlayerData.career.daily_level_ids.append(level_settings.id)
	CurrentLevel.set_launched_level(level_settings.id)
	CurrentLevel.puzzle_environment_name = PlayerData.career.current_region().puzzle_environment_name
	CurrentLevel.piece_speed = _piece_speed
	
	var level_posse: LevelPosse = _level_posses[level_index]
	CurrentLevel.customers = level_posse.customer_ids
	CurrentLevel.chef_id = level_posse.chef_id
	
	# enqueue customers/chefs from the overworld if the level doesn't define any
	if not CurrentLevel.customers:
		for customer in _world.get_visible_customers(level_index):
			CurrentLevel.customers.append(customer.creature_def)
		CurrentLevel.customers.shuffle()
	
	var preroll_key: String = chat_key_pair.preroll
	var postroll_key: String = chat_key_pair.postroll
	
	CutsceneQueue.reset()
	
	if preroll_key:
		CutsceneQueue.enqueue_cutscene(ChatLibrary.chat_tree_for_key(preroll_key))
	
	CutsceneQueue.enqueue_level({
		"level_id": level_settings.id,
		"piece_speed": _piece_speed,
		"chef_id": CurrentLevel.chef_id,
		"customers": CurrentLevel.customers,
		"puzzle_environment_name": CurrentLevel.puzzle_environment_name,
	})
	
	if postroll_key:
		CutsceneQueue.enqueue_cutscene(ChatLibrary.chat_tree_for_key(postroll_key))
	
	if preroll_key or postroll_key:
		match chat_key_pair.type:
			ChatKeyPair.INTRO_LEVEL:
				CutsceneQueue.set_cutscene_flag("intro_level")
			ChatKeyPair.BOSS_LEVEL:
				CutsceneQueue.set_cutscene_flag("boss_level")
	
	if _should_play_epilogue(chat_key_pair):
		var region := PlayerData.career.current_region()
		CutsceneQueue.enqueue_cutscene(ChatLibrary.chat_tree_for_key(region.get_epilogue_chat_key()))
	
	PlayerData.career.push_career_trail()


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_ui()
	
	# restore focus to the level select buttons for controller players
	_level_select_control.focus_button()
