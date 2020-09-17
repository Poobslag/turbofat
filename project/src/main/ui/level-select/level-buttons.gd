extends Control
"""
Creates and arranges level buttons for the level select screen.
"""

# Emitted when the player highlights a level to show information and statistics.
signal level_selected(settings)

# Emitted when the player highlights the 'overall' button.
signal overall_selected(ranks)

# The width of level buttons when they're small (about 10-20 visible)
const COLUMN_WIDTH_SMALL := 120

# The width of level buttons when they're big (about 30-40 visible)
const COLUMN_WIDTH_LARGE := 180

# The amount of space between level buttons
const VERTICAL_SPACING := LevelSelectButton.VERTICAL_SPACING

export (PackedScene) var LevelSelectButtonScene: PackedScene

# VBoxContainer instances containing columns of level buttons
var _columns := []

# current column width; shrinks when zoomed out
var _column_width := COLUMN_WIDTH_SMALL

# mapping from scenario IDs to ScenarioSettings instances
var _scenario_settings_by_id: Dictionary

var _duration_calculator := DurationCalculator.new()
var _level_ids: Array
var _level_details: Dictionary

func _ready() -> void:
	_add_level("boatricia1", "boatricia", 1)
	_add_level("boatricia2", "boatricia", 2)
	_add_level("five-customers-no-vegetables", "ebe", 1)
	_add_level("placeholder01", "ebe")
	_add_level("placeholder02", "bort")
	_add_level("placeholder03", "bort")
	_add_level("placeholder04", "boatricia")
	_add_level("placeholder05", "boatricia")
	_add_level("placeholder06", "ebe")
	_add_level("placeholder07", "ebe")
	_add_level("placeholder08", "bort")
	_add_level("placeholder09", "bort")
	_add_level("placeholder10", "bort")
	_add_level("placeholder11", "ebe")
	_add_level("placeholder12")
	
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	var column_count := ceil(sqrt(_level_ids.size() + 1))
	for _i in range(column_count):
		var vbox_container := VBoxContainer.new()
		vbox_container.alignment = BoxContainer.ALIGN_END
		vbox_container.rect_min_size.x = _column_width
		vbox_container.set("custom_constants/separation", VERTICAL_SPACING)
		_columns.append(vbox_container)
		add_child(vbox_container)
	
	for level_id in _level_ids:
		var scenario_settings := ScenarioSettings.new()
		scenario_settings.load_from_resource(level_id)
		_scenario_settings_by_id[level_id] = scenario_settings
	
	for i in range(_level_ids.size()):
		var level_id: String = _level_ids[i]
		var column: VBoxContainer = _columns[(i + 1) % _columns.size()]
		column.add_child(_level_select_button(level_id))
	
	_add_overall_button()
	
	for i in range(_columns.size()):
		if i % 2 == 0:
			var spacer := Control.new()
			spacer.rect_min_size.y = _column_width * 0.25 - VERTICAL_SPACING * 0.5
			_columns[i].add_child(spacer)


"""
Adds the 'overall' button which shows the player's progress for all puzzles.
"""
func _add_overall_button() -> void:
	var level_select_button: LevelSelectButton = LevelSelectButtonScene.instance()
	level_select_button.level_column_width = _column_width
	level_select_button.level_duration = LevelSelectButton.LONG
	level_select_button.text = "(overall)"
	level_select_button.connect("focus_entered", self, "_on_OverallButton_focus_entered")
	
	_columns[0].add_child(level_select_button)
	level_select_button.grab_focus()


"""
Creates a level select button for the specified level.
"""
func _level_select_button(level_id: String) -> LevelSelectButton:
	var scenario_settings: ScenarioSettings = _scenario_settings_by_id[level_id]
	var level_select_button: LevelSelectButton = LevelSelectButtonScene.instance()
	level_select_button.level_column_width = _column_width
	
	var duration := _duration_calculator.duration(scenario_settings)
	if duration < 100:
		level_select_button.level_duration = LevelSelectButton.SHORT
	elif duration < 200:
		level_select_button.level_duration = LevelSelectButton.MEDIUM
	else:
		level_select_button.level_duration = LevelSelectButton.LONG
	
	level_select_button.text = scenario_settings.title
	level_select_button.connect("scenario_started", self,
			"_on_LevelSelectButton_scenario_started", [scenario_settings])
	level_select_button.connect("focus_entered", self, "_on_LevelSelectButton_focus_entered", [scenario_settings])
	return level_select_button


func _add_level(level_id: String, creature_id: String = "", level_num: int = -1) -> void:
	_level_ids.append(level_id)
	_level_details[level_id] = {"creature_id": creature_id, "level_num": level_num}


func _on_LevelSelectButton_scenario_started(settings: ScenarioSettings) -> void:
	var creature_id := ""
	if _level_details.has(settings.id):
		creature_id = _level_details[settings.id].get("creature_id", "")
	
	var level_num := -1
	if _level_details.has(settings.id):
		level_num = _level_details[settings.id].get("level_num", -1)
	
	Scenario.set_launched_scenario(settings.id, creature_id, level_num)
	
	if creature_id and level_num >= 1:
		Breadcrumb.push_trail(Global.SCENE_OVERWORLD)
	else:
		Scenario.push_scenario_trail()


func _on_LevelSelectButton_focus_entered(settings: ScenarioSettings) -> void:
	emit_signal("level_selected", settings)


func _on_OverallButton_focus_entered() -> void:
	# populate an array of level ranks. incomplete levels are treated as rank 999
	var ranks := []
	for settings_obj in _scenario_settings_by_id.values():
		var settings: ScenarioSettings = settings_obj
		var best_result := PlayerData.scenario_history.best_result(settings.id)
		var rank := 999.0
		if best_result:
			rank = best_result.seconds_rank if best_result.compare == "-seconds" else best_result.score_rank
		ranks.append(rank)
	
	emit_signal("overall_selected", ranks)
