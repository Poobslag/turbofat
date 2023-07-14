extends BlockLevelChunkControl
## Level editor chunk which contains a vegetable block.

## Increasing this size allows you to draw vegetable blocks as a cluster, instead of one at a time.
export (Vector2) var veg_size: Vector2 = Vector2.ONE setget set_veg_size

func set_veg_size(new_veg_size: Vector2) -> void:
	veg_size = new_veg_size
	_refresh_tile_map()
	_refresh_scale()


func _refresh_tile_map() -> void:
	for x in range(veg_size.x):
		for y in range(veg_size.y):
			$TileMap.set_block(Vector2(x, y), PuzzleTileMap.TILE_VEG, PuzzleTileMap.random_veg_autotile_coord())


func _on_RotateButton_pressed() -> void:
	_refresh_tile_map()


func _on_ChangeButton_pressed() -> void:
	_refresh_tile_map()
