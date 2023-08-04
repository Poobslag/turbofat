tool
extends Node
## Adds water ripples to an overworld terrain map.
##
## Ripples are added to a random selection of water cells, with some restrictions.

## Cell coordinate offsets which could potentially obstruct a water cell.
const OBSTRUCTION_DIRS := [
	Vector2( 1,  0), Vector2( 1,  1), Vector2( 0,  1),
]

export (NodePath) var ground_map_path: NodePath

## Indexes of water tiles in the ground tilemap
export (Array, int) var water_tile_indexes := []

## Indexes of ripple tiles in the parent tilemap
export (Array, int) var ripple_tile_indexes := []

## Percent of water tiles which should have ripples
export (float, 0.0, 1.0) var ripple_density := 0.15

## Editor toggle which adds ripples to a random selection of water tiles
export (bool) var _autotile: bool setget autotile

## Terrain tilemap with ripple tiles to place
onready var _tile_map := get_parent()

## Ground tilemap containing data on which cells should have water ripples on top of them
onready var _ground_map: TileMap = get_node(ground_map_path)

## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Refreshes the position of ripple tiles.
##
## Ripple tiles are added to a random selection of water tiles. This only includes water tiles which are surrounded by
## other water tiles, as water tiles can overlay neighboring non-water ground tiles in an ugly way.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_erase_all_ripples()
	_add_random_ripples()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
	_ground_map = get_node(ground_map_path) if ground_map_path else null


func _erase_all_ripples() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) in ripple_tile_indexes:
			_tile_map.set_cellv(cell, TileMap.INVALID_CELL)


func _add_random_ripples() -> void:
	for cell in _ground_map.get_used_cells():
		if not _ground_map.get_cellv(cell) in water_tile_indexes:
			# only add ripples to water tiles
			continue
		if not randf() < ripple_density:
			# only add ripples to a random selection of tiles
			continue
		if _visually_obstructed_by_non_water_cell(cell):
			# avoid adding ripples to water tiles with non-water cells in front of them. Water tiles can overlay
			# neighboring non-water ground tiles in an ugly way.
			continue
		_tile_map.set_cellv(cell, Utils.rand_value(ripple_tile_indexes), randf() < 0.5)


## Returns 'true' if the specified ground cell is has a non-empty non-water cell in front of it.
func _visually_obstructed_by_non_water_cell(cell: Vector2) -> bool:
	var result := false
	for neighbor_dir in OBSTRUCTION_DIRS:
		var neighbor_tile_index := _ground_map.get_cellv(cell + neighbor_dir)
		if neighbor_tile_index in water_tile_indexes:
			continue
		if neighbor_tile_index == TileMap.INVALID_CELL:
			continue
		result = true
		break
	return result
