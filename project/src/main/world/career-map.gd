extends Node
## Scene which shows the player's progress through career mode.
##
## Launching this scene also advances the player towards their goal if 'distance earned' is nonzero.

## The number of levels the player can choose between
const SELECTION_COUNT := 3

## LevelSettings instances for each level the player can select
var _pickable_level_settings := []

## CareerLevel instances for each level the player can select
var _pickable_career_levels := []

## PieceSpeed for all levels the player can select.
var _piece_speed: String

onready var _world := $World
onready var _distance_label := $Ui/Control/StatusBar/Distance
onready var _level_select_control := $LevelSelect

func _ready() -> void:
	ResourceCache.substitute_singletons()
	
	if not Breadcrumb.trail:
		# For developers accessing the Overworld scene directly, we initialize a default Breadcrumb trail.
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
	
	var region: CareerRegion = CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	# decide available career levels
	if PlayerData.career.is_boss_level():
		_pickable_career_levels = [region.boss_level]
	elif PlayerData.career.is_intro_level():
		_pickable_career_levels = [region.intro_level]
	else:
		_pickable_career_levels = _random_levels()
	
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
	
	_world.refresh_creatures(_pickable_career_levels)


## Recreates all level select buttons in the scene tree based on the current level settings.
func _refresh_level_select_buttons() -> void:
	_level_select_control.clear_level_select_buttons()
	
	for i in range(_pickable_level_settings.size()):
		var level_settings: LevelSettings = _pickable_level_settings[i]
		var level_select_button: LevelSelectButton = _level_select_control.add_level_select_button(level_settings)
		level_select_button.connect("level_started", self, "_on_LevelSelectButton_level_started", [i])


## Return a list of random CareerLevels for the player to choose from.
##
## We only select levels appropriate for the current distance, and we exclude levels which have been played in the
## current session.
func _random_levels() -> Array:
	var levels := CareerLevelLibrary.career_levels_for_distance(PlayerData.career.distance_travelled)
	levels = levels.duplicate() # avoid modifying the original list
	
	# We use a seeded shuffle which always gives the player the same random levels. Otherwise they can relaunch career
	# mode over and over until they get the exact levels they want to play.
	var seed_int := 0
	seed_int += PlayerData.career.daily_earnings
	if PlayerData.career.prev_daily_earnings:
		seed_int += PlayerData.career.prev_daily_earnings[0]
	Utils.seeded_shuffle(levels, seed_int)
	
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


## When the player clicks a level button twice, we launch the selected level
func _on_LevelSelectButton_level_started(level_index: int) -> void:
	if PlayerData.career.is_connected("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed"):
		# avoid changing the level button titles when you pick an earlier level
		PlayerData.career.disconnect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	
	# apply a distance penalty if they select an earlier level
	var distance_penalty: int = PlayerData.career.distance_penalties()[level_index]
	PlayerData.career.distance_travelled -= distance_penalty
	PlayerData.career.daily_steps -= distance_penalty
	_distance_label.suppress_distance_penalty()
	
	var level_settings: LevelSettings = _pickable_level_settings[level_index]
	var career_level: CareerLevel = _pickable_career_levels[level_index]
	
	PlayerData.career.daily_level_ids.append(level_settings.id)
	CurrentLevel.set_launched_level(level_settings.id)
	CurrentLevel.piece_speed = _piece_speed
	
	CurrentLevel.customers = career_level.customer_ids.duplicate()
	CurrentLevel.chef_id = career_level.chef_id
	
	if not CurrentLevel.customers:
		# enqueue customers from the overworld if the CareerLevel doesn't define one
		for customer in _world.get_visible_customers(level_index):
			CurrentLevel.customers.append(customer.creature_def)
		CurrentLevel.customers.shuffle()
	
	var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	var chat_key_pair := {}
	
	# if it's an intro level, enqueue any intro level cutscenes
	if not chat_key_pair and PlayerData.career.is_intro_level():
		var preroll_key := region.get_intro_level_preroll_chat_key()
		var postroll_key := region.get_intro_level_postroll_chat_key()
		if ChatLibrary.chat_exists(preroll_key) and not PlayerData.chat_history.is_chat_finished(preroll_key):
			chat_key_pair["preroll"] = preroll_key
		if ChatLibrary.chat_exists(postroll_key) and not PlayerData.chat_history.is_chat_finished(postroll_key):
			chat_key_pair["postroll"] = postroll_key
	
	# if it's a boss level, enqueue any boss level cutscenes
	if not chat_key_pair and PlayerData.career.is_boss_level():
		var preroll_key := region.get_boss_level_preroll_chat_key()
		var postroll_key := region.get_boss_level_postroll_chat_key()
		if ChatLibrary.chat_exists(preroll_key) and not PlayerData.chat_history.is_chat_finished(preroll_key):
			chat_key_pair["preroll"] = preroll_key
		if ChatLibrary.chat_exists(postroll_key) and not PlayerData.chat_history.is_chat_finished(postroll_key):
			chat_key_pair["postroll"] = postroll_key
	
	# if it's the 3rd or 6th level, enqueue a cutscene
	if not chat_key_pair and PlayerData.career.hours_passed in CareerData.CAREER_INTERLUDE_HOURS \
			and not PlayerData.career.skipped_previous_level:
		if region.cutscene_path:
			# find a region-specific cutscene
			chat_key_pair = CareerCutsceneLibrary.next_interlude_chat_key_pair([region.cutscene_path])
		if not chat_key_pair:
			# no region-specific cutscene available; find a general cutscene
			chat_key_pair = CareerCutsceneLibrary.next_interlude_chat_key_pair([CareerData.GENERAL_CHAT_KEY_ROOT])
	
	var preroll_key: String = chat_key_pair.get("preroll", "")
	var postroll_key: String = chat_key_pair.get("postroll", "")
	
	if preroll_key:
		CutsceneManager.enqueue_cutscene(ChatLibrary.chat_tree_for_key(preroll_key))
	
	CutsceneManager.enqueue_level({
		"level_id": level_settings.id,
		"piece_speed": _piece_speed,
		"chef_id": CurrentLevel.chef_id,
		"customers": CurrentLevel.customers,
	})
	
	if postroll_key:
		CutsceneManager.enqueue_cutscene(ChatLibrary.chat_tree_for_key(postroll_key))
	
	if _should_play_epilogue(chat_key_pair):
		CutsceneManager.enqueue_cutscene(ChatLibrary.chat_tree_for_key(region.get_epilogue_chat_key()))
	
	PlayerData.career.push_career_trail()


func _should_play_epilogue(chat_key_pair: Dictionary) -> bool:
	var result := true
	var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	
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
		# derive the prerolly key from the chat_key_pair
		var preroll_key: String = chat_key_pair.get("preroll", "")
		if not preroll_key: preroll_key = chat_key_pair.get("postroll", "").trim_suffix("_end")
		
		# determine if any cutscenes will remain after this cutscene was played
		var search_flags := {}
		search_flags[CareerCutsceneLibrary.INCLUDE_ALL_NUMERIC_CHILDREN] = true
		search_flags[CareerCutsceneLibrary.EXCLUDED_CHAT_KEYS] = \
				CareerCutsceneLibrary.exhausted_chat_keys([region.cutscene_path])
		search_flags[CareerCutsceneLibrary.EXCLUDED_CHAT_KEYS][preroll_key] = true
		var remaining_chat_key_pairs := CareerCutsceneLibrary.find_chat_key_pairs([region.cutscene_path], search_flags)
		
		if remaining_chat_key_pairs:
			# this is not the last cutscene; do not play epilogue
			result = false
	
	return result


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_ui()
	
	# restore focus to the level select buttons for controller players
	_level_select_control.focus_button()
