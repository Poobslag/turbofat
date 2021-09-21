class_name EditorPlayfield
extends Control
"""
Playfield for use in the level editor.

This script provides drag/drop logic and other things specific to the level editor.
"""

# emitted when the player changes the tilemap's contents. This signal is not emitted when set_cell is called to
# prevent infinite recursion when populated by editor-json.gd.
signal tile_map_changed
var dragging_right_mouse := false

onready var _tile_map := $Bg/TileMap
onready var _tile_map_drop_preview := $Bg/TileMapDropPreview

func _ready() -> void:
	_tile_map.clear()
	_tile_map.get_node("CornerMap").dirty = true
	_clear_previews()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		dragging_right_mouse = event.button_mask & BUTTON_RIGHT
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		# click/drag the right mouse to erase parts of the tilemap
		if dragging_right_mouse:
			set_block(_cell_pos(event.position), -1)
			emit_signal("tile_map_changed")


func can_drop_data(pos: Vector2, data: BlockLevelChunk) -> bool:
	var can_drop := Rect2(Vector2(0, 0), rect_size).has_point(pos)
	if can_drop:
		# update drop preview
		_clear_previews()
		for cell in data.used_cells:
			var target_pos: Vector2 = _cell_pos(pos) + cell
			_set_tile_map_block($Bg/TileMapDropPreview, target_pos,
					data.tiles[cell], data.autotile_coords[cell])
	return can_drop


func drop_data(pos: Vector2, data: BlockLevelChunk) -> void:
	_clear_previews()
	for cell in data.used_cells:
		var target_pos: Vector2 = _cell_pos(pos) + cell
		set_block(target_pos, data.tiles[cell], data.autotile_coords[cell])
	emit_signal("tile_map_changed")


"""
Clears all of the drop previews.

When dragging/dropping items in the editor, we show translucent previews where the items will drop. These previews are
cleared following a successful drop, or if the mouse exits the control.
"""
func _clear_previews() -> void:
	_tile_map_drop_preview.clear()


func set_block(pos: Vector2, tile: int, autotile_coord: Vector2 = Vector2.ZERO) -> void:
	_set_tile_map_block($Bg/TileMap, pos, tile, autotile_coord)


func get_tile_map() -> TileMap:
	return $Bg/TileMap as TileMap


"""
Converts an x/y control coordinate like '58, 132' into a tile_map coordinate like '3, 2'
"""
func _cell_pos(pos: Vector2) -> Vector2:
	return pos * Vector2(PuzzleTileMap.COL_COUNT, PuzzleTileMap.ROW_COUNT) / rect_size


func _set_tile_map_block(tile_map: TileMap, pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
	if Rect2(0, 0, PuzzleTileMap.COL_COUNT, PuzzleTileMap.ROW_COUNT).has_point(pos):
		tile_map.set_block(pos, tile, autotile_coord)
		tile_map.get_node("CornerMap").dirty = true


func _on_mouse_exited() -> void:
	_clear_previews()
