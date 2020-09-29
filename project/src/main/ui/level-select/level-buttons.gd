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

# Emitted when a new level select button or world select button is added.
signal button_added(button)

# The width of level buttons when they're small (about 10-20 visible)
const COLUMN_WIDTH_SMALL := 120

# The width of level buttons when they're big (about 30-40 visible)
const COLUMN_WIDTH_LARGE := 180

# The amount of space between level buttons
const VERTICAL_SPACING := LevelSelectButton.VERTICAL_SPACING

export (PackedScene) var LevelSelectButtonScene: PackedScene

export (PackedScene) var WorldSelectButtonScene: PackedScene

# VBoxContainer instances containing columns of level buttons
var _columns := []

# current column width; shrinks when zoomed out
var _column_width := COLUMN_WIDTH_SMALL

var _duration_calculator := DurationCalculator.new()

# keeps track of which worlds and levels are available to the player and how to unlock them.
var _level_select_model := LevelSelectModel.new()

func _ready() -> void:
	_level_select_model.initialize()
	_clear_contents()
	_add_buttons()
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
func _add_buttons() -> void:
	var last_world_button: LevelSelectButton
	for world_id_obj in _level_select_model.world_ids:
		var world_id: String = world_id_obj
		var shown_level_ids := _level_select_model.shown_level_ids(world_id)
		
		if not shown_level_ids:
			continue
		
		var column_count := ceil(sqrt(shown_level_ids.size() + 1))
		for _i in range(column_count):
			var vbox_container := VBoxContainer.new()
			vbox_container.alignment = BoxContainer.ALIGN_END
			vbox_container.rect_min_size.x = _column_width
			vbox_container.set("custom_constants/separation", VERTICAL_SPACING)
			_columns.append(vbox_container)
			add_child(vbox_container)
		
		for i in range(shown_level_ids.size()):
			var level_id: String = shown_level_ids[i]
			var level_lock: LevelLock =  _level_select_model.level_lock(level_id)
			if level_lock.status == LevelLock.STATUS_HARD_LOCK:
				# 'hard lock' levels are hidden from the player
				continue
			var column: VBoxContainer = _columns[(i + 1) % _columns.size()]
			column.add_child(_level_select_button(world_id, level_id))
		
		last_world_button = _add_world_button(world_id)
	last_world_button.grab_focus()


"""
Adds the world button which show the player's progress for a world.
"""
func _add_world_button(world_id: String) -> WorldSelectButton:
	var world_select_button: WorldSelectButton = WorldSelectButtonScene.instance()
	world_select_button.world_id = world_id
	world_select_button.level_column_width = _column_width
	world_select_button.level_duration = WorldSelectButton.LONG
	var world_lock: WorldLock = _level_select_model.world_lock(world_id)
	world_select_button.level_title = "(%s)" % [world_lock.world_name]
	world_select_button.connect("focus_entered", self, "_on_WorldButton_focus_entered", [world_select_button])
	
	# populate an array of level ranks. incomplete levels are treated as rank 999
	var ranks := []
	for level_id in world_lock.level_ids:
		var settings: LevelSettings = _level_select_model.level_settings(level_id)
		var best_result := PlayerData.level_history.best_result(settings.id)
		var rank := 999.0
		if best_result:
			rank = best_result.seconds_rank if best_result.compare == "-seconds" else best_result.score_rank
		ranks.append(rank)
	world_select_button.ranks = ranks
	
	_columns[0].add_child(world_select_button)
	emit_signal("button_added", world_select_button)
	return world_select_button


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
func _level_select_button(world_id: String, level_id: String) -> LevelSelectButton:
	var level_settings: LevelSettings = _level_select_model.level_settings(level_id)
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
	
	var level_lock: LevelLock = _level_select_model.level_lock(level_id)
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
	var level_lock: LevelLock = _level_select_model.level_lock(settings.id)
	Level.set_launched_level(settings.id, level_lock.creature_id, level_lock.level_num)
	if level_lock.creature_id and level_lock.level_num >= 1:
		Breadcrumb.push_trail(Global.SCENE_OVERWORLD)
	else:
		Level.push_level_trail()


"""
When the player clicks a level button once, we emit a signal to show more information.
"""
func _on_LevelSelectButton_focus_entered(settings: LevelSettings) -> void:
	var world_lock: WorldLock = _level_select_model.world_lock_for_level(settings.id)
	_lowlight_unrelated_buttons(world_lock.world_id)
	if _level_select_model.is_locked(settings.id):
		emit_signal("locked_level_selected", _level_select_model.level_lock(settings.id))
	else:
		emit_signal("unlocked_level_selected", settings)


"""
When the player clicks the 'overall' button once, we emit a signal to show more information.
"""
func _on_WorldButton_focus_entered(world_select_button: WorldSelectButton) -> void:
	_lowlight_unrelated_buttons(world_select_button.world_id)
	var world_lock: WorldLock = _level_select_model.world_lock(world_select_button.world_id)
	emit_signal("overall_selected", world_select_button.ranks)
