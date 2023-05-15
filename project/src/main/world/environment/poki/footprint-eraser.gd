extends Node
## Manipulates Poki Desert's footprints so that they are not visible when the desert is empty.

## Terrain tilemap with footprint tiles to place
onready var _tile_map := get_parent()

## Limited set of footprint cells visible when the player and sensei are alone in the desert.
var _player_and_sensei_footprint_cells := [
	Vector2(29, 18),
	Vector2(27, 19),
	Vector2(28, 19),
	Vector2(29, 19),
	Vector2(25, 20),
	Vector2(26, 20),
	Vector2(27, 20),
	Vector2(18, 21),
	Vector2(19, 21),
	Vector2(20, 21),
	Vector2(21, 21),
	Vector2(22, 21),
	Vector2(23, 21),
	Vector2(24, 21),
	Vector2(25, 21),
	Vector2(26, 21),
	Vector2(18, 22),
	Vector2(19, 22),
]

## Terrain tilemap's tile ID for footprint tiles
export (int) var footprint_tile_index: int

func _ready() -> void:
	if not PlayerData.chat_history.is_chat_finished("chat/career/poki/prologue"):
		_erase_all_footprints()
		_add_player_and_sensei_footprints()


func _erase_all_footprints() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) == footprint_tile_index:
			_tile_map.set_cellv(cell, TileMap.INVALID_CELL)


func _add_player_and_sensei_footprints() -> void:
	for cell in _player_and_sensei_footprint_cells:
		_tile_map.set_cellv(cell, footprint_tile_index)
		_tile_map.update_bitmask_area(cell)
