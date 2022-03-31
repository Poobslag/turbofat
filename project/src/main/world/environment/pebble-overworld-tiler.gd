tool
extends Node
## Adds pebble tiles to an overworld terrain map.
##
## Pebble tiles are added to a random selection of frosted/unfrosted cake tiles.

export (NodePath) var ground_map_path: NodePath

## A number in the range [0.0, 1.0] describing what percent of cake tiles should have pebbles
export (float) var pebble_density := 0.03

## The ground tilemap's tile ID for unfrosted blocks
export (int) var ground_block_tile_index: int

## The ground tilemap's tile ID for frosted blocks
export (int) var ground_frost_tile_index: int

## The terrain tilemap's tile ID for pebble tiles
export (int) var pebble_tile_index: int

## An editor toggle which adds pebbles to a random selection of frosted/unfrosted cake tiles
export (bool) var _autotile: bool setget autotile

## Terrain tilemap with pebble tiles to place
onready var _tile_map := get_parent()

## Ground tilemap containing data on which cells should have pebbles on top of them
onready var _ground_map: TileMap = get_node(ground_map_path)

## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Refreshes the position of pebble tiles.
##
## Pebble tiles are added to a random selection of frosted/unfrosted cake tiles.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_erase_all_pebbles()
	_add_random_pebbles()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
	_ground_map = get_node(ground_map_path)


func _erase_all_pebbles() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) == pebble_tile_index:
			_tile_map.set_cell(cell.x, cell.y, TileMap.INVALID_CELL)


func _add_random_pebbles() -> void:
	for cell in _ground_map.get_used_cells():
		var ground_cell_id := _ground_map.get_cellv(cell)
		if not ground_cell_id in [ground_block_tile_index, ground_frost_tile_index]:
			# only add pebbles to frosted/unfrosted cake tiles
			continue
		if _tile_map.get_cell(cell.x, cell.y) != TileMap.INVALID_CELL:
			continue
		if randf() >= pebble_density:
			# only add pebbles to a random selection of tiles
			continue
		var autotile_coord := Vector2(randi() % 4, randi() % 3)
		_tile_map.set_cell(cell.x, cell.y, pebble_tile_index, false, false, false, autotile_coord)
