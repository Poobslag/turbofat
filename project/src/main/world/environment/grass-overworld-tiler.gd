tool
extends Node
## Adds grass tiles to an overworld obstacle map.
##
## Grass tiles are added to a random selection of goopy/goopless cake tiles.

## Autotile coordinates for goopless grass tiles in the grass tile obstacle texture
const AUTOTILE_COORDS_GOOPLESS_GRASS := [
	Vector2(0, 0), Vector2(1, 0), Vector2(2, 0),
	Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
]

## Autotile coordinates for goopy grass tiles in the grass tile obstacle texture
const AUTOTILE_COORDS_GOOPY_GRASS := [
	Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
	Vector2(0, 3), Vector2(1, 3), Vector2(2, 3),
]

export (NodePath) var ground_map_path: NodePath

## Percent of cake tiles which should have grass
export (float, 0.0, 1.0) var grass_density := 0.03

## Ground tilemap's tile ID for goopless cells
export (int) var ground_no_goop_tile_index: int

## Ground tilemap's tile ID for goopy cells
export (int) var ground_all_goop_tile_index: int

## Obstacle tilemap's tile ID for grass tiles
export (int) var grass_tile_index: int

## Editor toggle which adds grass to a random selection of goopy/goopless cake tiles
export (bool) var _autotile: bool setget autotile

## Obstacle tilemap with grass tiles to place
onready var _tile_map := get_parent()

## Ground tilemap containing data on which cells should have grass on top of them
onready var _ground_map: TileMap = get_node(ground_map_path)

## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Refreshes the position of grass tiles.
##
## Grass tiles are added to a random selection of goopy/goopless cake tiles.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_erase_all_grass()
	_add_random_grass()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
	_ground_map = get_node(ground_map_path) if ground_map_path else null


func _erase_all_grass() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) == grass_tile_index:
			_tile_map.set_cellv(cell, TileMap.INVALID_CELL)


func _add_random_grass() -> void:
	for cell in _ground_map.get_used_cells():
		var ground_cell_id := _ground_map.get_cellv(cell)
		if not ground_cell_id in [ground_no_goop_tile_index, ground_all_goop_tile_index]:
			# only add grass to goopy/goopless cake tiles
			continue
		if _tile_map.get_cellv(cell) != TileMap.INVALID_CELL:
			continue
		if randf() >= grass_density:
			# only add grass to a random selection of tiles
			continue
		var autotile_coord: Vector2
		if ground_cell_id == ground_no_goop_tile_index:
			autotile_coord = Utils.rand_value(AUTOTILE_COORDS_GOOPLESS_GRASS)
		else:
			autotile_coord = Utils.rand_value(AUTOTILE_COORDS_GOOPY_GRASS)
		_tile_map.set_cellv(cell, grass_tile_index, false, false, false, autotile_coord)
