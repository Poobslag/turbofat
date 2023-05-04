extends Node
## Manipulates Poki Desert's footprints so that they are not visible when the desert is empty.

## Terrain tilemap with footprint tiles to place
@onready var _tile_map := get_parent()

## Limited set of footprint cells visible when the player and sensei are alone in the desert.
var _player_and_sensei_footprint_cells := [
	Vector2i(29, 18),
	Vector2i(27, 19),
	Vector2i(28, 19),
	Vector2i(29, 19),
	Vector2i(25, 20),
	Vector2i(26, 20),
	Vector2i(27, 20),
	Vector2i(18, 21),
	Vector2i(19, 21),
	Vector2i(20, 21),
	Vector2i(21, 21),
	Vector2i(22, 21),
	Vector2i(23, 21),
	Vector2i(24, 21),
	Vector2i(25, 21),
	Vector2i(26, 21),
	Vector2i(18, 22),
	Vector2i(19, 22),
]

## Terrain tilemap's tile ID for footprint tiles
@export var footprint_tile_index: int

func _ready() -> void:
	if not PlayerData.chat_history.is_chat_finished("chat/career/poki/prologue"):
		_erase_all_footprints()
		_add_player_and_sensei_footprints()


func _erase_all_footprints() -> void:
	for cell in _tile_map.get_used_cells(0):
		if _tile_map.get_cell_source_id(0, cell) == footprint_tile_index:
			_tile_map.set_cell(0, cell, -1)


func _add_player_and_sensei_footprints() -> void:
	for cell in _player_and_sensei_footprint_cells:
		_tile_map.set_cell(0, cell, footprint_tile_index)
		_tile_map.update_bitmask_area(cell)
