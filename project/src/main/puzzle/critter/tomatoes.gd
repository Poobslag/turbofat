class_name Tomatoes
extends Node2D
## Handles tomatoes, puzzle critters which indicate lines which can't be cleared.
##
## Tomatoes show up when there are full lines which can't be cleared because of level rules. They hold up fingers
## counting down '3, 2, 1' so players can anticipate when lines will clear.

export (PackedScene) var TomatoScene: PackedScene
export (NodePath) var critter_manager_path: NodePath

## Timer which suppresses tomato voice sound effects when the scene is first loaded.
onready var _suppress_sfx_timer := $SuppressSfxTimer

## node which contains all of the Tomato child nodes
onready var _tomato_holder := $TomatoHolder

var playfield_path: NodePath setget set_playfield_path

var _playfield: Playfield

## key: (Vector2) row containing a tomato
## value: (Node2D) tomato at that row
var _tomatoes_by_cell_y: Dictionary = {}

## shuffled queue of columns where tomatoes can appear
var _tomato_columns := [0, 1, 2, 6, 7, 8]

func set_playfield_path(new_playfield_path: NodePath) -> void:
	PuzzleState.connect("after_piece_written", self, "_on_PuzzleState_after_piece_written")
	playfield_path = new_playfield_path
	_tomato_columns.shuffle()
	_refresh_playfield_path()


## Adds a tomato to the playfield.
##
## Parameters:
## 	'tomato_y': The playfield cell y coordinate where this tomato should appear.
func add_tomato(tomato_y: int) -> void:
	if _tomatoes_by_cell_y.has(tomato_y):
		# row already contains a tomato
		return
	
	var tomato: Tomato = TomatoScene.instance()
	
	tomato.z_index = 5
	tomato.scale = _playfield.tile_map.scale
	tomato.column = _pop_tomato_column()
	
	var cell := Vector2(0, tomato_y)
	tomato.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	tomato.position += _playfield.tile_map.cell_size * Vector2(0.0, 0.5)
	tomato.position *= _playfield.tile_map.scale
	
	_tomatoes_by_cell_y[tomato_y] = tomato
	tomato.set_state(Tomato.IDLE_1)
	tomato.visible = tomato_y >= PuzzleTileMap.FIRST_VISIBLE_ROW
	
	if not _suppress_sfx_timer.is_stopped():
		# suppress tomato voice sound effects when the scene is first loaded
		tomato.suppress_voice = true
	
	_tomato_holder.add_child(tomato)


## Pop the next tomato column from the queue
func _pop_tomato_column() -> int:
	var tomato_column: int = _tomato_columns.pop_front()
	
	# randomly reinsert the popped column near the end of the queue
	_tomato_columns.insert(Utils.randi_range(_tomato_columns.size() - 2, _tomato_columns.size()), tomato_column)
	
	return tomato_column


## Removes a tomato from the playfield.
##
## Parameters:
## 	'tomato_y': The playfield cell y coordinate for the tomato to remove.
func remove_tomato(tomato_y: int) -> void:
	if not _tomatoes_by_cell_y.has(tomato_y):
		return
	
	var tomato: Tomato = _tomatoes_by_cell_y[tomato_y]
	tomato.poof_and_free()
	_tomatoes_by_cell_y.erase(tomato_y)


## Immediately clears all tomatoes from the playfield without any animation.
func _clear_tomatoes() -> void:
	_tomatoes_by_cell_y.clear()
	for tomato in _tomato_holder.get_children():
		tomato.queue_free()


## Connects playfield listeners.
func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	if _playfield:
		_playfield.disconnect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.disconnect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.disconnect("line_inserted", self, "_on_Playfield_line_inserted")
		_playfield.disconnect("line_deleted", self, "_on_Playfield_line_deleted")
	
	_playfield = get_node(playfield_path) if playfield_path else null
	
	if _playfield:
		_playfield.connect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.connect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.connect("line_inserted", self, "_on_Playfield_line_inserted")
		_playfield.connect("line_deleted", self, "_on_Playfield_line_deleted")


## Adds any missing tomatoes and updates their states.
func _refresh_tomatoes() -> void:
	for y in range(PuzzleTileMap.ROW_COUNT):
		if _playfield.tile_map.row_is_full(y) and not _tomatoes_by_cell_y.has(y):
			add_tomato(y)
	
	if CurrentLevel.settings.blocks_during.filled_line_clear_delay > 0:
		# For 'line clear delay' levels, the tomatoes hold up fingers for the time until each line will be cleared.
		# We obtain this information from the line clearer.
		for y in _tomatoes_by_cell_y.keys():
			var line_time_needed: int = CurrentLevel.settings.blocks_during.filled_line_clear_delay \
					- _playfield.line_clearer.line_filled_age.get(y, 0)
			match line_time_needed:
				0, 1:
					_tomatoes_by_cell_y[y].state = Tomato.IDLE_1
				2:
					_tomatoes_by_cell_y[y].state = Tomato.IDLE_2
				_:
					_tomatoes_by_cell_y[y].state = Tomato.IDLE_3
	elif CurrentLevel.settings.blocks_during.filled_line_clear_max < 999999:
		# For 'filled line clear max' levels, the tomatoes hold up fingers for the time until each line will be
		# cleared. We sort the filled lines by the line clear criteria and group them based on the maximum number of
		# cleared lines.
		var ordered_rows := _playfield.line_clearer.sort_lines_to_clear(_tomatoes_by_cell_y.keys())
		for line_index in range(ordered_rows.size()):
			var y: int = ordered_rows[line_index]
			# warning-ignore:integer_division
			match line_index / CurrentLevel.settings.blocks_during.filled_line_clear_max:
				0:
					_tomatoes_by_cell_y[y].state = Tomato.IDLE_1
				1:
					_tomatoes_by_cell_y[y].state = Tomato.IDLE_2
				2, _:
					_tomatoes_by_cell_y[y].state = Tomato.IDLE_3
	elif CurrentLevel.settings.blocks_during.filled_line_clear_min > 0:
		# For 'filled line clear min' levels, the tomatoes hold up fingers for the number of additional filled lines
		# needed to trigger line clears.
		var filled_lines_needed: int = CurrentLevel.settings.blocks_during.filled_line_clear_min \
				- _tomatoes_by_cell_y.size()
		
		var tomato_state: int
		if filled_lines_needed <= 1:
			tomato_state = Tomato.IDLE_1
		elif filled_lines_needed == 2:
			tomato_state = Tomato.IDLE_2
		else:
			tomato_state = Tomato.IDLE_3
		
		for y in _tomatoes_by_cell_y:
			_tomatoes_by_cell_y[y].state = tomato_state


## Shifts a group of tomatoes up or down.
##
## Parameters:
## 	'bottom_y': The lowest row to shift. All tomatoes at or above this row will be shifted.
##
## 	'direction': The direction to shift the tomatoes, such as Vector2.UP or Vector2.DOWN.
func _shift_rows(bottom_y: int, direction: Vector2) -> void:
	# First, erase and store all the old tomatoes which are shifting
	var new_tomatoes_by_cell_y: Dictionary = {}
	
	for old_cell_y in _tomatoes_by_cell_y.keys():
		var tomato: Tomato = _tomatoes_by_cell_y[old_cell_y]
		var new_cell_y: int = old_cell_y
		
		if old_cell_y <= bottom_y:
			# tomatoes above the specified bottom_y are shifted
			new_cell_y += direction.y
		
		# copy the tomato into its new location in 'new_tomatoes_by_cell_y'
		new_tomatoes_by_cell_y[new_cell_y] = _tomatoes_by_cell_y[old_cell_y]
		
		if new_cell_y != old_cell_y:
			# shift the visuals, and make the tomato visible/invisible if it scrolls off the top of the screen
			tomato.position += direction * _playfield.tile_map.cell_size * _playfield.tile_map.scale
			tomato.visible = new_cell_y >= PuzzleTileMap.FIRST_VISIBLE_ROW
	
	_tomatoes_by_cell_y = new_tomatoes_by_cell_y


func _on_Playfield_blocks_prepared() -> void:
	_clear_tomatoes()
	_refresh_tomatoes()


func _on_Playfield_line_erased(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	if _tomatoes_by_cell_y.has(y):
		remove_tomato(y)


func _on_Playfield_line_inserted(y: int, _tiles_key: String, _src_y: int) -> void:
	# raise all tomatoes at or above the specified row
	_shift_rows(y, Vector2.UP)


func _on_Playfield_line_deleted(y: int) -> void:
	# drop all tomatoes above the specified row to fill the gap
	_shift_rows(y - 1, Vector2.DOWN)


func _on_PuzzleState_after_piece_written() -> void:
	_refresh_tomatoes()
