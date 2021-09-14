class_name Playfield
extends Control
"""
Stores information about the game playfield: writing pieces to the playfield, calculating whether a line was cleared
or whether a box was built, pausing and playing sound effects
"""

# emitted when a new box is built
signal box_built(rect, box_type)

# emitted shortly before a set of lines are cleared
signal line_clears_scheduled(ys)

# emitted before a 'line clear' where a line is erased and the player is rewarded
signal before_line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted after a 'line clear' where a line is erased and the player is rewarded
signal line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted when a line is erased. this includes line clears but also top outs and non-scoring end game rows.
signal line_erased(y, total_lines, remaining_lines, box_ints)

# emitted when erased lines are deleted, causing the rows above them to drop down
signal lines_deleted(lines)

signal lines_inserted(lines)

signal blocks_prepared

# remaining frames to delay for something besides making boxes/clearing lines
var _remaining_misc_delay_frames := 0

onready var tile_map := $TileMapClip/TileMap
onready var line_inserter := $LineInserter

onready var _bg_glob_viewports: FrostingViewports = $BgGlobViewports
onready var _box_builder: BoxBuilder = $BoxBuilder
onready var _combo_tracker: ComboTracker = $ComboTracker
onready var _line_clearer: LineClearer = $LineClearer

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	_prepare_tileset()
	_prepare_level_blocks()


func _physics_process(delta: float) -> void:
	if PuzzleState.game_active:
		PuzzleState.level_performance.seconds += delta
	
	if _box_builder.remaining_box_build_frames > 0:
		if not _box_builder.is_physics_processing():
			_box_builder.set_physics_process(true)
	elif _line_clearer.remaining_line_erase_frames > 0:
		if not _line_clearer.is_physics_processing():
			_line_clearer.set_physics_process(true)
	elif _remaining_misc_delay_frames > 0:
		_remaining_misc_delay_frames -= 1


func get_remaining_line_erase_frames() -> int:
	return _line_clearer.remaining_line_erase_frames


func get_remaining_box_build_frames() -> int:
	return _box_builder.remaining_box_build_frames


func add_misc_delay_frames(frames: int) -> void:
	_remaining_misc_delay_frames += frames


func schedule_line_clears(lines_to_clear: Array, line_clear_delay: int, award_points: bool = true) -> void:
	_line_clearer.schedule_line_clears(lines_to_clear, line_clear_delay, award_points)


"""
Returns false the playfield is paused for an of animation or delay which should prevent a new piece from appearing.
"""
func ready_for_new_piece() -> bool:
	return _box_builder.remaining_box_build_frames <= 0 \
			and _line_clearer.remaining_line_erase_frames <= 0 \
			and _remaining_misc_delay_frames <= 0


"""
Writes a piece to the playfield, checking whether it builds any boxes or clears any lines.

Returns true if the written piece results in a line clear.
"""
func write_piece(pos: Vector2, orientation: int, type: PieceType, death_piece := false) -> void:
	_box_builder.remaining_box_build_frames = 0
	_line_clearer.remaining_line_erase_frames = 0
	
	tile_map.save_state()
	
	for i in range(type.pos_arr[orientation].size()):
		var block_pos := type.get_cell_position(orientation, i)
		var block_color := type.get_cell_color(orientation, i)
		tile_map.set_block(pos + block_pos, PuzzleTileMap.TILE_PIECE, block_color)
	
	if not death_piece:
		_box_builder.process_boxes()
		_line_clearer.schedule_full_row_line_clears()
	
	PuzzleState.before_piece_written()
	
	if _box_builder.remaining_box_build_frames == 0 and _line_clearer.remaining_line_erase_frames == 0:
		# If any boxes are being built or lines are being cleared, we emit the
		# signal later. Otherwise we emit it now.
		PuzzleState.after_piece_written()


func break_combo() -> void:
	_combo_tracker.break_combo()


func _prepare_tileset() -> void:
	tile_map.puzzle_tile_set_type = CurrentLevel.settings.other.tile_set


"""
Resets the playfield to the level's initial state.
"""
func _prepare_level_blocks() -> void:
	$TutorialKeybindsLabel.visible = CurrentLevel.settings.other.tutorial and not OS.has_touchscreen_ui_hint()
	
	tile_map.clear()
	var blocks_start: LevelTiles.BlockBunch = CurrentLevel.settings.tiles.blocks_start()
	for cell in blocks_start.used_cells:
		tile_map.set_block(cell, blocks_start.tiles[cell], blocks_start.autotile_coords[cell])
	emit_signal("blocks_prepared")


func _on_PuzzleState_game_prepared() -> void:
	_prepare_level_blocks()


func _on_Level_settings_changed() -> void:
	_prepare_tileset()
	_prepare_level_blocks()


func _on_BoxBuilder_box_built(rect: Rect2, box_type: int) -> void:
	emit_signal("box_built", rect, box_type)


func _on_BoxBuilder_after_boxes_built() -> void:
	if _line_clearer.remaining_line_erase_frames > 0:
		_line_clearer.set_physics_process(true)
	else:
		PuzzleState.after_piece_written()


func _on_LineClearer_line_clears_scheduled(ys: Array) -> void:
	emit_signal("line_clears_scheduled", ys)


func _on_LineClearer_before_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	emit_signal("before_line_cleared", y, total_lines, remaining_lines, box_ints)


func _on_LineClearer_line_erased(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	emit_signal("line_erased", y, total_lines, remaining_lines, box_ints)


func _on_LineClearer_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	emit_signal("line_cleared", y, total_lines, remaining_lines, box_ints)


func _on_LineClearer_lines_deleted(lines: Array) -> void:
	emit_signal("lines_deleted", lines)
	PuzzleState.after_piece_written()


func _on_FrostingGlobs_hit_playfield(glob: Node) -> void:
	_bg_glob_viewports.add_smear(glob)


"""
When the player pauses, we hide the playfield so they can't cheat.
"""
func _on_Pauser_paused_changed(value: bool) -> void:
	$TileMapClip.visible = not value
	$ShadowTexture.visible = not value


func _on_LineInserter_lines_inserted(lines: Array) -> void:
	emit_signal("lines_inserted", lines)
