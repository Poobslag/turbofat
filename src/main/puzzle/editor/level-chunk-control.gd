class_name LevelChunkControl
extends Control
"""
UI component for a draggable chunk of level editor data.
"""

func _ready() -> void:
	_refresh_tilemap()
	_refresh_scale()


func get_drag_data(_pos: Vector2) -> Object:
	var data: LevelChunk = LevelChunk.new()
	for cell in $TileMap.get_used_cells():
		var tile: int = $TileMap.get_cell(cell.x, cell.y)
		var autotile_coord: Vector2 = $TileMap.get_cell_autotile_coord(cell.x, cell.y)
		data.set_block(cell, tile, autotile_coord)
	_refresh_tilemap()
	return data


func _refresh_tilemap() -> void:
	pass


func _refresh_scale() -> void:
	var extents := Rect2(Vector2.ZERO, Vector2.ZERO)
	if $TileMap.get_used_cells():
		extents.position = $TileMap.get_used_cells()[0]
		for cell in $TileMap.get_used_cells():
			extents = extents.expand(cell)
	$TileMap.scale.x = 0.50 / (1 + max(extents.end.x, extents.end.y))
	$TileMap.scale.y = 0.50 / (1 + max(extents.end.x, extents.end.y))
