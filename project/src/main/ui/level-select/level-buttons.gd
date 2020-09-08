extends Control
"""
Creates and arranges level buttons for the level select screen.
"""

# Emitted when the player highlights a level to show information and statistics.
signal level_selected(settings)

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

func _ready() -> void:
	var level_ids := [
		"boatricia1", "boatricia2", "five-customers-no-vegetables", "placeholder01", "placeholder02", "placeholder03",
		"placeholder04", "placeholder05", "placeholder06", "placeholder07", "placeholder08", "placeholder09",
		"placeholder10", "placeholder11",
	]
	
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	var column_count := ceil(sqrt(level_ids.size() + 1))
	for _i in range(column_count):
		var vbox_container := VBoxContainer.new()
		vbox_container.alignment = BoxContainer.ALIGN_END
		vbox_container.rect_min_size.x = _column_width
		vbox_container.set("custom_constants/separation", VERTICAL_SPACING)
		_columns.append(vbox_container)
		add_child(vbox_container)
	
	for level_id in level_ids:
		var scenario_settings := ScenarioSettings.new()
		scenario_settings.load_from_resource(level_id)
		_scenario_settings_by_id[level_id] = scenario_settings
	
	for i in range(level_ids.size()):
		var level_id: String = level_ids[i]
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
	
	_columns[0].add_child(level_select_button)


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


func _on_LevelSelectButton_scenario_started(settings: ScenarioSettings) -> void:
	Scenario.overworld_puzzle = false
	Scenario.push_scenario_trail(settings)


func _on_LevelSelectButton_focus_entered(settings: ScenarioSettings) -> void:
	emit_signal("level_selected", settings)
