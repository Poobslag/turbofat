extends LevelChunkControl
"""
A level editor chunk which contains a vegetable block.
"""

func _refresh_tilemap() -> void:
	$TileMap.set_block(Vector2.ZERO, Playfield.TILE_VEG, Vector2(randi() % 18, randi() % 4))
