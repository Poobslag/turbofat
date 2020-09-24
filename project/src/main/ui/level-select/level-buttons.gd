extends Control
"""
Creates and arranges level buttons for the level select screen.
"""

# Emitted when the player highlights an unlocked level to show more information.
signal unlocked_level_selected(settings)

# Emitted when the player highlights a locked level to show more information.
signal locked_level_selected(level_lock)

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

# mapping from level IDs to LevelSettings instances
var _level_settings_by_id: Dictionary

var _duration_calculator := DurationCalculator.new()

# tracks which levels unlock other levels
var _world_locks := WorldLocks.new()

func _ready() -> void:
	_world_locks.initialize()
	_clear_contents()
	_add_level_buttons()
	_add_overall_button()
	_misalign_columns()


"""
Removes all buttons/placeholders in preparation for loading a new set of levels.
"""
func _clear_contents() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


"""
Adds buttons representing levels the player can choose.
"""
func _add_level_buttons() -> void:
	var column_count := ceil(sqrt(_world_locks.level_ids.size() + 1))
	for _i in range(column_count):
		var vbox_container := VBoxContainer.new()
		vbox_container.alignment = BoxContainer.ALIGN_END
		vbox_container.rect_min_size.x = _column_width
		vbox_container.set("custom_constants/separation", VERTICAL_SPACING)
		_columns.append(vbox_container)
		add_child(vbox_container)
	
	for level_id in _world_locks.level_ids:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		_level_settings_by_id[level_id] = level_settings
	
	for i in range(_world_locks.level_ids.size()):
		var level_id: String = _world_locks.level_ids[i]
		var column: VBoxContainer = _columns[(i + 1) % _columns.size()]
		column.add_child(_level_select_button(level_id))


"""
Adds the 'overall' button which shows the player's progress for all puzzles.
"""
func _add_overall_button() -> void:
	var level_select_button: LevelSelectButton = LevelSelectButtonScene.instance()
	level_select_button.level_column_width = _column_width
	level_select_button.level_duration = LevelSelectButton.LONG
	level_select_button.level_title = "(overall)"
	level_select_button.connect("focus_entered", self, "_on_OverallButton_focus_entered")
	
	_columns[0].add_child(level_select_button)
	level_select_button.grab_focus()


"""
Adds spacers so that the columns aren't perfectly aligned.
"""
func _misalign_columns() -> void:
	for i in range(_columns.size()):
		if i % 2 == 0:
			var spacer := Control.new()
			spacer.rect_min_size.y = _column_width * 0.25 - VERTICAL_SPACING * 0.5
			_columns[i].add_child(spacer)


"""
Creates a level select button for the specified level.
"""
func _level_select_button(level_id: String) -> LevelSelectButton:
	var level_settings: LevelSettings = _level_settings_by_id[level_id]
	var level_select_button: LevelSelectButton = LevelSelectButtonScene.instance()
	level_select_button.level_column_width = _column_width
	
	var duration := _duration_calculator.duration(level_settings)
	if duration < 100:
		level_select_button.level_duration = LevelSelectButton.SHORT
	elif duration < 200:
		level_select_button.level_duration = LevelSelectButton.MEDIUM
	else:
		level_select_button.level_duration = LevelSelectButton.LONG
	
	var level_lock: LevelLock = _world_locks.level_locks[level_id]
	level_select_button.lock_status = level_lock.status
	level_select_button.keys_needed = level_lock.keys_needed
	level_select_button.level_title = level_settings.title
	level_select_button.connect("level_started", self,
			"_on_LevelSelectButton_level_started", [level_settings])
	level_select_button.connect("focus_entered", self, "_on_LevelSelectButton_focus_entered", [level_settings])
	return level_select_button


"""
When the player clicks a level button twice, we launch the selected level
"""
func _on_LevelSelectButton_level_started(settings: LevelSettings) -> void:
	var creature_id := ""
	if _world_locks.level_locks.has(settings.id):
		var level_lock: LevelLock = _world_locks.level_locks.get(settings.id)
		creature_id = level_lock.creature_id
	
	var level_num := -1
	if _world_locks.level_locks.has(settings.id):
		var level_lock: LevelLock = _world_locks.level_locks.get(settings.id)
		level_num = level_lock.level_num
	
	Level.set_launched_level(settings.id, creature_id, level_num)
	
	if creature_id and level_num >= 1:
		Breadcrumb.push_trail(Global.SCENE_OVERWORLD)
	else:
		Level.push_level_trail()


"""
When the player clicks a level button once, we emit a signal to show more information.
"""
func _on_LevelSelectButton_focus_entered(settings: LevelSettings) -> void:
	if _world_locks.is_locked(settings.id):
		emit_signal("locked_level_selected", _world_locks.level_locks[settings.id])
	else:
		emit_signal("unlocked_level_selected", settings)


"""
When the player clicks the 'overall' button once, we emit a signal to show more information.
"""
func _on_OverallButton_focus_entered() -> void:
	# populate an array of level ranks. incomplete levels are treated as rank 999
	var ranks := []
	for settings_obj in _level_settings_by_id.values():
		var settings: LevelSettings = settings_obj
		var best_result := PlayerData.level_history.best_result(settings.id)
		var rank := 999.0
		if best_result:
			rank = best_result.seconds_rank if best_result.compare == "-seconds" else best_result.score_rank
		ranks.append(rank)
	
	emit_signal("overall_selected", ranks)
