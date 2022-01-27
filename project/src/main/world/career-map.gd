extends Node
## Scene which shows the player's progress through career mode.
##
## Launching this scene also advances the player towards their goal if 'distance earned' is nonzero.

## Chat key root for non-region-specific cutscenes
const GENERAL_CHAT_KEY_ROOT := "chat/career/general"

## The number of levels the player can choose between
const SELECTION_COUNT := 3

## LevelSettings instances for each level the player can select
var _level_settings_for_levels := []

## PieceSpeed for all levels the player can select.
var _piece_speed: String

onready var _world := $World
onready var _distance_label := $Ui/Control/StatusBar/Distance
onready var _level_select_control := $LevelSelect

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	if PlayerData.career.is_day_over():
		PlayerData.career.push_career_trail()
	else:
		_refresh_ui()
		_level_select_control.focus_button()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _refresh_ui() -> void:
	_load_level_settings()
	_refresh_level_select_buttons()


## Loads level settings for three randomly selected levels from the current CareerRegion.
func _load_level_settings() -> void:
	_level_settings_for_levels.clear()
	
	var career_levels: Array
	var region: CareerRegion = CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	if PlayerData.career.is_boss_level():
		# player must pick the boss level
		career_levels = [region.boss_level]
		_piece_speed = ""
	else:
		# player can choose from many levels
		career_levels = _random_levels()
		
		if region.length == CareerData.MAX_DISTANCE_TRAVELLED:
			var weight: float = float(PlayerData.career.hours_passed) / (CareerData.HOURS_PER_CAREER_DAY - 1)
			_piece_speed = CareerLevelLibrary.piece_speed_between(region.min_piece_speed, region.max_piece_speed, weight)
		else:
			_piece_speed = CareerLevelLibrary.piece_speed_for_distance(PlayerData.career.distance_travelled)
	
	for level in career_levels:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level.level_id)
		LevelSpeedAdjuster.new(level_settings).adjust(_piece_speed)
		_level_settings_for_levels.append(level_settings)


## Recreates all level select buttons in the scene tree based on the current level settings.
func _refresh_level_select_buttons() -> void:
	_level_select_control.clear_level_select_buttons()
	
	for i in range(_level_settings_for_levels.size()):
		var level_settings: LevelSettings = _level_settings_for_levels[i]
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
	
	var level_settings: LevelSettings = _level_settings_for_levels[level_index]
	PlayerData.career.daily_level_ids.append(level_settings.id)
	CurrentLevel.set_launched_level(level_settings.id)
	CurrentLevel.piece_speed = _piece_speed
	
	var customers := []
	
	# enqueue customers for the selected levels
	if PlayerData.career.is_boss_level():
		# boss level; enqueue all visible customers
		for customer in _world.customers:
			customers.append(customer.creature_def)
			customers.shuffle()
	elif level_index < _world.customers.size():
		# regular level; enqueue the selected customer
		customers.append(_world.customers[level_index].creature_def)
	CurrentLevel.customers = customers
	
	var chat_key_pair := {}
	
	if (PlayerData.career.hours_passed == 2 or PlayerData.career.hours_passed == 5) \
			and not PlayerData.career.skipped_previous_level:
		var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
		if region.cutscene_path:
			# find a region-specific cutscene
			chat_key_pair = CareerCutsceneLibrary.next_chat_key_pair([region.cutscene_path])
		if not chat_key_pair:
			# no region-specific cutscene available; find a general cutscene
			chat_key_pair = CareerCutsceneLibrary.next_chat_key_pair([GENERAL_CHAT_KEY_ROOT])
	
	var preroll_key: String = chat_key_pair.get("preroll", "")
	var postroll_key: String = chat_key_pair.get("postroll", "")
	
	if preroll_key:
		CutsceneManager.enqueue_cutscene(ChatLibrary.chat_tree_for_key(preroll_key))
	
	CutsceneManager.enqueue_level({
		"level_id": level_settings.id,
		"piece_speed": _piece_speed,
		"customers": customers,
	})
	
	if postroll_key:
		CutsceneManager.enqueue_cutscene(ChatLibrary.chat_tree_for_key(postroll_key))
	
	PlayerData.career.push_career_trail()


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_ui()
	
	# restore focus to the level select buttons for controller players
	_level_select_control.focus_button()
