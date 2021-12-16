extends Node
## Scene which shows the player's progress through career mode.
##
## Launching this scene also advances the player towards their goal if 'distance earned' is nonzero.

## The number of levels the player can choose between
const SELECTION_COUNT := 3

## LevelSettings instances for each level the player can select
var _level_settings_for_levels := []

## PieceSpeed for all levels the player can select.
var _piece_speed: String

var _duration_calculator := DurationCalculator.new()

onready var _world := $World
onready var _grade_labels := $LevelSelect/Control/GradeLabels

## LevelSelectButtons for all levels the player can select.
onready var _level_select_buttons := $LevelSelect/Control/LevelButtons.get_children()

func _ready() -> void:
	ResourceCache.substitute_singletons()
	PlayerData.career.connect("distance_travelled_changed", self, "_on_CareerData_distance_travelled_changed")
	if PlayerData.career.is_day_over():
		PlayerData.career.push_career_trail()
	else:
		for i in range(_level_select_buttons.size()):
			var level_select_button: LevelSelectButton = _level_select_buttons[i]
			level_select_button.connect("level_started", self, "_on_LevelSelectButton_level_started", [i])
			_grade_labels.add_label(level_select_button)
		
		_refresh_ui()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _refresh_ui() -> void:
	_load_level_settings()
	_prepare_level_select_buttons()
	
	# Grab focus to allow keyboard support. Wait a frame for other listeners to fire (specifically listeners which
	# turn the level buttons invisible)
	yield(get_tree(), "idle_frame")
	if _level_select_buttons and not _level_select_buttons[0].get_focus_owner():
		var right_button_index: int = min(_level_select_buttons.size(), _level_settings_for_levels.size()) - 1
		_level_select_buttons[right_button_index].grab_focus()


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
	
	for i in range(_level_select_buttons.size()):
		var level_select_button: LevelSelectButton = _level_select_buttons[i]
		if i >= career_levels.size():
			level_select_button.visible = false
			continue
		var available_level: CareerLevel = career_levels[i]
		
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(available_level.level_id)
		LevelSpeedAdjuster.new(level_settings).adjust(_piece_speed)
		_level_settings_for_levels.append(level_settings)


## Updates the LevelSelectButtons with the appropriate level data, and hooks up their signals.
func _prepare_level_select_buttons() -> void:
	for i in range(_level_select_buttons.size()):
		var level_select_button: LevelSelectButton = _level_select_buttons[i]
		if i >= _level_settings_for_levels.size():
			level_select_button.visible = false
			continue
		var level_settings: LevelSettings = _level_settings_for_levels[i]
		
		# update the button's text and color
		level_select_button.level_title = level_settings.title
		level_select_button.level_id = level_settings.id
		
		var duration := _duration_calculator.duration(level_settings)
		if duration < 100:
			level_select_button.level_duration = LevelSelectButton.SHORT
		elif duration < 200:
			level_select_button.level_duration = LevelSelectButton.MEDIUM
		else:
			level_select_button.level_duration = LevelSelectButton.LONG
		
		level_select_button.emit_signal("level_info_changed")


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
	# apply a distance penalty if they select an earlier level
	var distance_penalty: int = PlayerData.career.distance_penalties()[level_index]
	PlayerData.career.distance_travelled -= distance_penalty
	
	var level_settings: LevelSettings = _level_settings_for_levels[level_index]
	PlayerData.career.daily_level_ids.append(level_settings.id)
	CurrentLevel.set_launched_level(level_settings.id)
	CurrentLevel.piece_speed = _piece_speed
	
	# enqueue customers for the selected levels
	if PlayerData.career.is_boss_level():
		# boss level; enqueue all visible customers
		for customer in _world.customers:
			CurrentLevel.customers.append(customer.creature_def)
			CurrentLevel.customers.shuffle()
	elif level_index < _world.customers.size():
		# regular level; enqueue the selected customer
		CurrentLevel.customers.append(_world.customers[level_index].creature_def)
	
	PlayerData.career.push_career_trail()


func _on_CareerData_distance_travelled_changed() -> void:
	_refresh_ui()
