class_name EditorPlayfield
extends Control
"""
Playfield for use in the level editor.

This script provides drag/drop logic and other things specific to the level editor.
"""

# emitted when the player changes the tilemap's contents. This signal is not emitted when set_cell is called, to
# prevent infinite recursion when populated by editor-json.gd.
signal tile_map_changed
var dragging_right_mouse := false

func _ready() -> void:
	$Bg/TileMap.clear()
	$Bg/TileMap/CornerMap.dirty = true
	$Bg/TileMapDropPreview.clear()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		dragging_right_mouse = event.button_mask & BUTTON_RIGHT
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if dragging_right_mouse:
			set_block(_cell_pos(event.position), -1)
			emit_signal("tile_map_changed")


func can_drop_data(pos: Vector2, data: LevelChunk) -> bool:
	var can_drop := Rect2(Vector2(0, 0), rect_size).has_point(pos)
	if can_drop:
		# update drop preview
		$Bg/TileMapDropPreview.clear()
		for cell in data.used_cells:
			var target_pos: Vector2 = _cell_pos(pos) + cell
			_set_tilemap_block($Bg/TileMapDropPreview, target_pos,
					data.tiles[cell], data.autotile_coords[cell])
	return can_drop


func drop_data(pos: Vector2, data: LevelChunk) -> void:
	$Bg/TileMapDropPreview.clear()
	for cell in data.used_cells:
		var target_pos: Vector2 = _cell_pos(pos) + cell
		set_block(target_pos, data.tiles[cell], data.autotile_coords[cell])
	emit_signal("tile_map_changed")


func set_block(pos: Vector2, tile: int, autotile_coord: Vector2 = Vector2.ZERO) -> void:
	_set_tilemap_block($Bg/TileMap, pos, tile, autotile_coord)


func get_tile_map() -> TileMap:
	return $Bg/TileMap as TileMap


"""
Converts an x/y control coordinate like '58, 132' into a tilemap coordinate like '3, 2'
"""
func _cell_pos(pos: Vector2) -> Vector2:
	return pos * Vector2(PuzzleTileMap.COL_COUNT, PuzzleTileMap.ROW_COUNT) / rect_size


func _set_tilemap_block(tilemap: TileMap, pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
	if Rect2(0, 0, PuzzleTileMap.COL_COUNT, PuzzleTileMap.ROW_COUNT).has_point(pos):
		tilemap.set_block(pos, tile, autotile_coord)
		tilemap.get_node("CornerMap").dirty = true
