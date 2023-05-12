extends GutTest

var tiles: LevelTiles

func before_each() -> void:
	tiles = LevelTiles.new()


func test_is_default() -> void:
	assert_eq(tiles.is_default(), true)
	tiles.bunches["start"] = LevelTiles.BlockBunch.new()
	tiles.bunches["start"].set_block(Vector2i(1, 2), 3, Vector2i(4, 5))
	assert_eq(tiles.is_default(), false)


func test_to_json_empty() -> void:
	assert_eq(tiles.to_json_dict(), {})


func test_convert_to_json_and_back() -> void:
	tiles.bunches["start"] = LevelTiles.BlockBunch.new()
	tiles.bunches["start"].set_block(Vector2i(1, 2), 3, Vector2i(4, 5))
	tiles.bunches["1"] = LevelTiles.BlockBunch.new()
	tiles.bunches["1"].set_pickup(Vector2i(2, 3), 4)
	_convert_to_json_and_back()
	
	assert_eq(tiles.bunches.keys(), ["start", "1"])
	assert_eq(tiles.bunches["start"].block_tiles[Vector2i(1, 2)], 3)
	assert_eq(tiles.bunches["start"].block_autotile_coords[Vector2i(1, 2)], Vector2i(4, 5))
	assert_eq(tiles.bunches["1"].pickups[Vector2i(2, 3)], 4)


func _convert_to_json_and_back() -> void:
	var json := tiles.to_json_dict()
	tiles = LevelTiles.new()
	tiles.from_json_dict(json)
