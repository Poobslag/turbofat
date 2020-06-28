extends LevelChunkControl
"""
A level editor chunk which contains a vegetable block.
"""

# Increasing this size allows you to draw vegetable blocks as a cluster, instead of one at a time.
export (Vector2) var _veg_size: Vector2 = Vector2(1, 1) setget set_veg_size

func _ready() -> void:
	$"../../Buttons/RotateButton".connect("pressed", self, "_on_RotateButton_pressed")
	$"../../Buttons/ChangeButton".connect("pressed", self, "_on_ChangeButton_pressed")


func set_veg_size(veg_size: Vector2) -> void:
	_veg_size = veg_size
	_refresh_tilemap()
	_refresh_scale()


func _refresh_tilemap() -> void:
	for x in range(_veg_size.x):
		for y in range(_veg_size.y):
			$TileMap.set_block(Vector2(x, y), PuzzleTileMap.TILE_VEG, Vector2(randi() % 18, randi() % 4))


func _on_RotateButton_pressed() -> void:
	_refresh_tilemap()


func _on_ChangeButton_pressed() -> void:
	_refresh_tilemap()
