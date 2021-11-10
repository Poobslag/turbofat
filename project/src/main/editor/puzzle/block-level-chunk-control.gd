class_name BlockLevelChunkControl
extends Control
## UI component for a draggable chunk of level editor data made up of playfield blocks.

func _ready() -> void:
	_refresh_tile_map()
	_refresh_scale()


func get_drag_data(_pos: Vector2) -> Object:
	var data: BlockLevelChunk = BlockLevelChunk.new()
	for cell in $TileMap.get_used_cells():
		var tile: int = $TileMap.get_cellv(cell)
		var autotile_coord: Vector2 = $TileMap.get_cell_autotile_coord(cell.x, cell.y)
		data.set_block(cell, tile, autotile_coord)
	_refresh_tile_map()
	return data


## Calculates the extents of the tilemap's used cells.
func _tile_map_extents() -> Rect2:
	var extents := Rect2(Vector2.ZERO, Vector2.ZERO)
	if $TileMap.get_used_cells():
		extents.position = $TileMap.get_used_cells()[0]
		for cell in $TileMap.get_used_cells():
			extents = extents.expand(cell)
	return extents


## Overridden by child classes, which use this method to populate the contents of the tilemap.
func _refresh_tile_map() -> void:
	pass


## Refreshes the scale to ensure the contents of the tilemap fit inside an item in the palette.
func _refresh_scale() -> void:
	var extents := _tile_map_extents()
	$TileMap.scale.x = 1.00 / (1 + max(extents.end.x, extents.end.y))
	$TileMap.scale.y = 1.00 / (1 + max(extents.end.x, extents.end.y))
