class_name Playfield
extends Control
"""
Stores information about the game playfield: writing pieces to the playfield, calculating whether a line was cleared
or whether a box was built, pausing and playing sound effects
"""

# emitted when a new box is built
signal box_built(rect, color_int)

# emitted before a 'line clear' where a line is erased and the player is rewarded
signal before_line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted after a 'line clear' where a line is erased and the player is rewarded
signal line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted when a line is erased. this includes line clears but also top outs and non-scoring end game rows.
signal line_erased(y, total_lines, remaining_lines, box_ints)

# emitted when erased lines are deleted, causing the rows above them to drop down
signal lines_deleted(lines)

signal blocks_prepared

# emitted after a piece is written and all boxes are made and all lines are cleared
signal after_piece_written

# food colors for the food which gets hurled into the creature's mouth
const VEGETABLE_COLOR := Color("335320")
const RAINBOW_COLOR := Color.magenta
const FOOD_COLORS: Array = [
	Color("a4470b"), # brown
	Color("ff5d68"), # pink
	Color("ffa357"), # bread
	Color("fff6eb") # white
]

# remaining frames to delay for something besides making boxes/clearing lines
var _remaining_misc_delay_frames := 0

onready var tile_map := $TileMapClip/TileMap

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	Level.connect("settings_changed", self, "_on_Level_settings_changed")
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	_prepare_level_blocks()


func _physics_process(delta: float) -> void:
	if PuzzleScore.game_active:
		PuzzleScore.level_performance.seconds += delta
	
	if $BoxBuilder.remaining_box_build_frames > 0:
		if not $BoxBuilder.is_physics_processing():
			$BoxBuilder.set_physics_process(true)
	elif $LineClearer.remaining_line_erase_frames > 0:
		if not $LineClearer.is_physics_processing():
			$LineClearer.set_physics_process(true)
	elif _remaining_misc_delay_frames > 0:
		_remaining_misc_delay_frames -= 1


func get_remaining_line_erase_frames() -> int:
	return $LineClearer.remaining_line_erase_frames


func get_remaining_box_build_frames() -> int:
	return $BoxBuilder.remaining_box_build_frames


func add_misc_delay_frames(frames: int) -> void:
	_remaining_misc_delay_frames += frames


func schedule_line_clears(lines_to_clear: Array, line_clear_delay: int, award_points: bool = true) -> void:
	$LineClearer.schedule_line_clears(lines_to_clear, line_clear_delay, award_points)


"""
Returns false the playfield is paused for an of animation or delay which should prevent a new piece from appearing.
"""
func ready_for_new_piece() -> bool:
	return $BoxBuilder.remaining_box_build_frames <= 0 \
			and $LineClearer.remaining_line_erase_frames <= 0 \
			and _remaining_misc_delay_frames <= 0


"""
Writes a piece to the playfield, checking whether it builds any boxes or clears any lines.

Returns true if the written piece results in a line clear.
"""
func write_piece(pos: Vector2, orientation: int, type: PieceType, death_piece := false) -> void:
	$BoxBuilder.remaining_box_build_frames = 0
	$LineClearer.remaining_line_erase_frames = 0
	
	tile_map.save_state()
	
	for i in range(type.pos_arr[orientation].size()):
		var block_pos := type.get_cell_position(orientation, i)
		var block_color := type.get_cell_color(orientation, i)
		tile_map.set_block(pos + block_pos, PuzzleTileMap.TILE_PIECE, block_color)
	
	if not death_piece:
		$BoxBuilder.process_boxes()
		$LineClearer.schedule_full_row_line_clears()
	
	PuzzleScore.before_piece_written()
	
	if $BoxBuilder.remaining_box_build_frames == 0 and $LineClearer.remaining_line_erase_frames == 0:
		# If any boxes are being built or lines are being cleared, we emit the
		# signal later. Otherwise we emit it now.
		emit_signal("after_piece_written")
		PuzzleScore.after_piece_written()


func break_combo() -> void:
	$ComboTracker.break_combo()


"""
Resets the playfield to the level's initial state.
"""
func _prepare_level_blocks() -> void:
	$DetailMessageLabel.visible = Level.settings.other.tutorial and not OS.has_touchscreen_ui_hint()
	
	tile_map.clear()
	var blocks_start: BlocksStartRules = Level.settings.blocks_start
	for cell in blocks_start.used_cells:
		tile_map.set_block(cell, blocks_start.tiles[cell], blocks_start.autotile_coords[cell])
	emit_signal("blocks_prepared")


func _on_PuzzleScore_game_prepared() -> void:
	_prepare_level_blocks()


func _on_Level_settings_changed() -> void:
	_prepare_level_blocks()


func _on_BoxBuilder_box_built(rect: Rect2, color_int: int) -> void:
	emit_signal("box_built", rect, color_int)


func _on_BoxBuilder_after_boxes_built() -> void:
	if $LineClearer.remaining_line_erase_frames > 0:
		$LineClearer.set_physics_process(true)
	else:
		emit_signal("after_piece_written")
		PuzzleScore.after_piece_written()


func _on_LineClearer_before_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	emit_signal("before_line_cleared", y, total_lines, remaining_lines, box_ints)


func _on_LineClearer_line_erased(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	emit_signal("line_erased", y, total_lines, remaining_lines, box_ints)


func _on_LineClearer_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	emit_signal("line_cleared", y, total_lines, remaining_lines, box_ints)


func _on_LineClearer_lines_deleted(lines: Array) -> void:
	emit_signal("lines_deleted", lines)
	emit_signal("after_piece_written")
	PuzzleScore.after_piece_written()


func _on_FrostingGlobs_hit_playfield(glob: Node) -> void:
	$BgGlobViewports.add_smear(glob)


func _on_Pauser_paused_changed(value: bool) -> void:
	$TileMapClip.visible = !value
	$ShadowTexture.visible = !value
