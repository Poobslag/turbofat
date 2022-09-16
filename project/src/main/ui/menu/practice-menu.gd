extends Control
## Scene which lets the player repeatedly play a set of levels.

export (NodePath) var _high_scores_path: NodePath
export (NodePath) var _level_button_path: NodePath
export (NodePath) var _level_description_label_path: NodePath
export (NodePath) var _speed_selector_path: NodePath
export (NodePath) var _start_button_path: NodePath

## A CareerRegion or OtherRegion instance for the currently selected region
var _region: Object

## The currently selected level
var _level_settings: LevelSettings = LevelSettings.new()

## The currently selected piece speed
var _piece_speed: String

onready var _high_scores: Panel = get_node(_high_scores_path)
onready var _level_button: Button = get_node(_level_button_path)
onready var _level_description_label: Label = get_node(_level_description_label_path)
onready var _speed_selector: PracticeSpeedSelector = get_node(_speed_selector_path)
onready var _start_button: Button = get_node(_start_button_path)

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_chill_bgm()
	
	_assign_default_recent_data()
	_load_recent_data()
	
	_refresh_level_button()
	_refresh_speed_selector()
	_refresh_high_scores()
	
	if PlayerData.practice.piece_speed:
		_speed_selector.set_selected_speed(PlayerData.practice.piece_speed)
	
	_start_button.grab_focus()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


## Assign a region/level if this is the first time launching the practice menu
func _assign_default_recent_data() -> void:
	if PlayerData.practice.region_id and PlayerData.practice.level_id:
		# player has already launched the practice menu
		return
	
	PlayerData.practice.region_id = OtherRegion.ID_MARATHON
	PlayerData.practice.level_id = "practice/marathon_normal"


## Load the most recently played region and level.
##
## This browses the game files for the region and level corresponding to the player's save data, storing the result
## in the '_region' and '_level_settings' fields
func _load_recent_data() -> void:
	# find the player's previously played non-career region
	if not _region:
		if PlayerData.practice.region_id:
			_region = OtherLevelLibrary.region_for_id(PlayerData.practice.region_id)
	
	# find the player's previously played career region
	if not _region:
		if PlayerData.practice.region_id:
			_region = CareerLevelLibrary.region_for_id(PlayerData.practice.region_id)
	
	# load the player's previously played level
	_level_settings.load_from_resource(PlayerData.practice.level_id)


## Enables/disables focus for inputs as submenus are shown and hidden.
##
## When submenus appear over top of the main menu, we temporarily disable focus for all sliders/buttons/etc on the
## main menu to avoid them from grabbing keyboard focus.
func _refresh_input_focus_mode() -> void:
	var submenu_visible: bool = $LevelSubmenu.visible or $RegionSubmenu.visible
	for node in get_tree().get_nodes_in_group("main_practice_inputs"):
		node.focus_mode = FOCUS_NONE if submenu_visible else FOCUS_ALL


## Updates the level button to show the current level's name.
func _refresh_level_button() -> void:
	if _region is CareerRegion:
		_level_button.text = "%s: %s" % [_region.name, _level_settings.name]
	else:
		if _region.has_flag(OtherRegion.FLAG_TRAINING):
			_level_button.text = _level_settings.name
		else:
			_level_button.text = "%s: %s" % [_region.branch_name, _level_settings.name]
	_level_description_label.text = _level_settings.description


## Updates the speed slider with a list of available speeds.
##
## For career regions, the player is constrained by the speeds of that particular region.
##
## For non-career region, the player can only speed levels up. They cannot slow them down.
##
## For rank regions, the player can not make any changes at all.
func _refresh_speed_selector() -> void:
	var speed_editable := true
	var speed_names: Array = []
	var selected_speed := _level_settings.speed.get_start_speed()
	
	if _region is CareerRegion:
		# Constrain the speed selector to region's min/max speeds
		var min_index := PieceSpeeds.speed_ids.find(_region.min_piece_speed)
		var max_index := PieceSpeeds.speed_ids.find(_region.max_piece_speed)
		speed_names = PieceSpeeds.speed_ids.slice(min_index, max_index)
	else:
		# Constrain the speed selector. We default to the level's speed, but usually allow faster speeds within a
		# threshold.
		for next_speed_matrix_row in PieceSpeeds.speed_id_matrix:
			if next_speed_matrix_row.has(selected_speed):
				speed_names = next_speed_matrix_row.duplicate()
				break
		
		if _region.id == OtherRegion.ID_SANDBOX:
			# Players can play sandbox modes at whatever speed they like.
			pass
		else:
			# Player can't slow down training modes, they can only speed them up. This prevents them from clearing
			# hard training levels by slowing them down
			speed_names = speed_names.slice(speed_names.find(selected_speed), speed_names.size() - 1)
		
		if _region.id == OtherRegion.ID_RANK:
			# Players can't change the speed in rank mode.
			speed_editable = false
	
	_speed_selector.set_editable(speed_editable)
	_speed_selector.set_speed_names(speed_names)
	_speed_selector.set_selected_speed(selected_speed)


func _refresh_high_scores() -> void:
	_high_scores.set_level(_level_settings)


# When the player picks the big 'Start' button we launch the level
func _on_Start_pressed() -> void:
	CurrentLevel.set_launched_level(_level_settings.id)
	CurrentLevel.piece_speed = _piece_speed
	# upon completion, practice levels default to 'retry'
	CurrentLevel.keep_retrying = true
	CurrentLevel.push_level_trail()


# When the player clicks the 'Level Selection' button up top, we launch a series of submenus
func _on_LevelButton_pressed() -> void:
	$RegionSubmenu.popup(_region.id)


# When the player selects their region from the region submenu, we launch the level submenu
func _on_RegionSubmenu_region_chosen(region: Object) -> void:
	$RegionSubmenu.hide()
	$LevelSubmenu.popup(region, _level_settings.id)


func _on_RegionSubmenu_visibility_changed() -> void:
	_refresh_input_focus_mode()
	if not $RegionSubmenu.visible:
		_level_button.grab_focus()


func _on_LevelSelect_level_chosen(region: Object, settings: LevelSettings) -> void:
	_region = region
	PlayerData.practice.region_id = _region.id
	_level_settings = settings
	PlayerData.practice.level_id = settings.id
	$LevelSubmenu.hide()
	_refresh_level_button()
	_refresh_speed_selector()
	_refresh_high_scores()
	_level_button.grab_focus()


func _on_LevelSubmenu_visibility_changed() -> void:
	_refresh_input_focus_mode()
	if not $LevelSubmenu.visible:
		_level_button.grab_focus()


func _on_SpeedSelector_speed_changed(value: String) -> void:
	_piece_speed = value
	PlayerData.practice.piece_speed = value
