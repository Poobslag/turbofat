class_name LevelButtons
extends Control
"""
Creates and arranges level buttons for the level select screen.
"""

enum LevelsToInclude {
	ALL_LEVELS, # show both tutorial levels and regular levels
	TUTORIALS_ONLY, # only show tutorials; hide regular levels
}

# Emitted when the player highlights an unlocked level to show more information.
signal unlocked_level_selected(level_lock, settings)

# Emitted when the player highlights a locked level to show more information.
signal locked_level_selected(level_lock, settings)

# Emitted when the player highlights the 'overall' button.
signal overall_selected(world_id, ranks)

const ALL_LEVELS := LevelsToInclude.ALL_LEVELS
const TUTORIALS_ONLY := LevelsToInclude.TUTORIALS_ONLY

# Levels are arranged into a big rectangle. This is the ratio of the rectangle's width to height.
const BUTTON_ARRANGEMENT_WIDTH_FACTOR := 1.77778

# The width of level buttons when they're small (about 10-20 visible)
const COLUMN_WIDTH_SMALL := 120

# The width of level buttons when they're big (about 30-40 visible)
const COLUMN_WIDTH_LARGE := 180

# The amount of space between level buttons
const VERTICAL_SPACING := LevelSelectButton.VERTICAL_SPACING

export (PackedScene) var LevelSelectButtonScene: PackedScene
export (PackedScene) var WorldSelectButtonScene: PackedScene

# Allows for hiding/showing certain levels
export (LevelsToInclude) var levels_to_include := ALL_LEVELS

# VBoxContainer instances containing columns of level buttons
var _max_row_count
var _columns := []

# current column width; shrinks when zoomed out
var _column_width := COLUMN_WIDTH_SMALL

var _duration_calculator := DurationCalculator.new()

func _ready() -> void:
	_clear_contents()
	_add_buttons()


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
func _add_buttons() -> void:
	# calculate which worlds should be shown
	var included_world_ids: Array
	match levels_to_include:
		ALL_LEVELS: 
			included_world_ids = LevelLibrary.world_ids
		TUTORIALS_ONLY:
			if LevelLibrary.world_ids.has(LevelLibrary.TUTORIAL_WORLD_ID):
				included_world_ids = [LevelLibrary.TUTORIAL_WORLD_ID]
			else:
				included_world_ids = []
	
	# determine how many rows of buttons should be shown
	var total_shown_levels := 0
	for world_id_obj in included_world_ids:
		var shown_level_ids := LevelLibrary.shown_level_ids(world_id_obj)
		total_shown_levels += shown_level_ids.size() + 1 if shown_level_ids else 0
	_max_row_count = max(1, floor(sqrt((total_shown_levels - 1) / BUTTON_ARRANGEMENT_WIDTH_FACTOR)))
	
	# create and add the level/world buttons
	var last_world_button: LevelSelectButton
	for world_id_obj in included_world_ids:
		var world_id: String = world_id_obj
		var shown_level_ids := LevelLibrary.shown_level_ids(world_id)
		
		if not shown_level_ids:
			continue
		
		for i in range(shown_level_ids.size()):
			var level_id: String = shown_level_ids[i]
			var level_lock: LevelLock = LevelLibrary.level_lock(level_id)
			if level_lock.status == LevelLock.STATUS_HARD_LOCK:
				# 'hard lock' levels are hidden from the player
				continue
			_add_node_to_column(_level_select_button(world_id, level_id))
			
			# warning-ignore:integer_division
			if i == (shown_level_ids.size() - 1) / 2:
				last_world_button = _world_button(world_id)
				_add_node_to_column(last_world_button)
	
	if last_world_button:
		last_world_button.grab_focus()


"""
Adds a node to the rightmost column, or creates a new column if the column is full
"""
func _add_node_to_column(node: Node) -> void:
	if not _columns or _columns[_columns.size() - 1].get_child_count() >= _max_row_count:
		# create a new column
		var column := VBoxContainer.new()
		column.alignment = BoxContainer.ALIGN_CENTER
		column.rect_min_size.x = _column_width
		column.set("custom_constants/separation", VERTICAL_SPACING)
		_columns.append(column)
		add_child(column)
	
	# add the node to the rightmost column
	_columns[_columns.size() - 1].add_child(node)


"""
Adds the world button which show the player's progress for a world.
"""
func _world_button(world_id: String) -> WorldSelectButton:
	var world_select_button: WorldSelectButton = WorldSelectButtonScene.instance()
	world_select_button.world_id = world_id
	world_select_button.level_column_width = _column_width
	world_select_button.level_duration = WorldSelectButton.LONG
	var world_lock: WorldLock = LevelLibrary.world_lock(world_id)
	world_select_button.level_title = "(%s)" % [world_lock.world_name]
	world_select_button.lock_status = world_lock.status
	world_select_button.set_bg_color(Color.white)
	world_select_button.connect("focus_entered", self, "_on_WorldButton_focus_entered", [world_select_button])
	
	# populate an array of level ranks. incomplete levels are treated as rank 999
	var ranks := []
	for level_id in world_lock.level_ids:
		var settings: LevelSettings = LevelLibrary.level_settings(level_id)
		var best_result := PlayerData.level_history.best_result(settings.id)
		var rank := 999.0
		if best_result:
			rank = best_result.seconds_rank if best_result.compare == "-seconds" else best_result.score_rank
		ranks.append(rank)
	world_select_button.ranks = ranks
	return world_select_button


"""
Creates a level select button for the specified level.
"""
func _level_select_button(world_id: String, level_id: String) -> LevelSelectButton:
	var level_settings: LevelSettings = LevelLibrary.level_settings(level_id)
	var level_select_button: LevelSelectButton = LevelSelectButtonScene.instance()
	level_select_button.world_id = world_id
	level_select_button.level_id = level_id
	level_select_button.level_column_width = _column_width
	
	var duration := _duration_calculator.duration(level_settings)
	if duration < 100:
		level_select_button.level_duration = LevelSelectButton.SHORT
	elif duration < 200:
		level_select_button.level_duration = LevelSelectButton.MEDIUM
	else:
		level_select_button.level_duration = LevelSelectButton.LONG
	
	var level_lock: LevelLock = LevelLibrary.level_lock(level_id)
	level_select_button.lock_status = level_lock.status
	level_select_button.keys_needed = level_lock.keys_needed
	level_select_button.level_title = level_settings.title
	level_select_button.connect("level_started", self,
			"_on_LevelSelectButton_level_started", [level_settings])
	level_select_button.connect("focus_entered", self, "_on_LevelSelectButton_focus_entered", [level_settings])
	return level_select_button


func _lowlight_unrelated_buttons(world_id: String) -> void:
	for button in get_tree().get_nodes_in_group("level_select_buttons"):
		var level_select_button: LevelSelectButton = button
		if world_id == level_select_button.world_id:
			level_select_button.lowlight = false
		else:
			level_select_button.lowlight = true

"""
When the player clicks a level button twice, we launch the selected level
"""
func _on_LevelSelectButton_level_started(settings: LevelSettings) -> void:
	CurrentLevel.set_launched_level(settings.id)
	
	var chat_tree: ChatTree = ChatLibrary.chat_tree_for_creature_id(CurrentLevel.creature_id, settings.id)
	if ChatLibrary.is_chat_skipped(chat_tree):
		CurrentLevel.push_level_trail()
	else:
		if not CurrentLevel.push_cutscene_trail(true):
			CurrentLevel.push_level_trail()


"""
When the player clicks a level button once, we emit a signal to show more information.
"""
func _on_LevelSelectButton_focus_entered(settings: LevelSettings) -> void:
	var world_lock: WorldLock = LevelLibrary.world_lock_for_level(settings.id)
	_lowlight_unrelated_buttons(world_lock.world_id)
	if LevelLibrary.is_level_locked(settings.id):
		emit_signal("locked_level_selected", LevelLibrary.level_lock(settings.id), settings)
	else:
		emit_signal("unlocked_level_selected", LevelLibrary.level_lock(settings.id), settings)


"""
When the player clicks the 'overall' button once, we emit a signal to show more information.
"""
func _on_WorldButton_focus_entered(world_select_button: WorldSelectButton) -> void:
	_lowlight_unrelated_buttons(world_select_button.world_id)
	emit_signal("overall_selected", world_select_button.world_id, world_select_button.ranks)
