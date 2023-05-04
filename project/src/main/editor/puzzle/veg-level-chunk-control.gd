extends BlockLevelChunkControl
## Level editor chunk which contains a vegetable block.

## Increasing this size allows you to draw vegetable blocks as a cluster, instead of one at a time.
@export var veg_size: Vector2i = Vector2i.ONE: set = set_veg_size

func _ready() -> void:
	$"../../Buttons/RotateButton".pressed.connect(_on_RotateButton_pressed)
	$"../../Buttons/ChangeButton".pressed.connect(_on_ChangeButton_pressed)


func set_veg_size(new_veg_size: Vector2i) -> void:
	veg_size = new_veg_size
	_refresh_tile_map()
	_refresh_scale()


func _refresh_tile_map() -> void:
	for x in range(veg_size.x):
		for y in range(veg_size.y):
			$TileMap.set_block(Vector2i(x, y), PuzzleTileMap.TILE_VEG, PuzzleTileMap.random_veg_autotile_coord())


func _on_RotateButton_pressed() -> void:
	_refresh_tile_map()


func _on_ChangeButton_pressed() -> void:
	_refresh_tile_map()
