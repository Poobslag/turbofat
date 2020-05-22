class_name PuzzleTileMap
extends TileMap
"""
TileMap containing puzzle blocks such as pieces, boxes and vegetables.
"""


func _ready() -> void:
	clear()


func clear() -> void:
	.clear()
	$CornerMap.clear()


func set_block(pos: Vector2, tile: int, autotile_coord: Vector2 = Vector2.ZERO) -> void:
	set_cell(pos.x, pos.y, tile, false, false, false, autotile_coord)
	$CornerMap.dirty = true
