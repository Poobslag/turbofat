tool
extends Node
## Adds pebble tiles to an overworld terrain map.
##
## Pebble tiles are added to a random selection of goopy/goopless cake tiles.

export (NodePath) var ground_map_path: NodePath

## Percent of cake tiles which should have pebbles
export (float, 0.0, 1.0) var pebble_density := 0.03

## Ground tilemap's tile ID for goopless cells
export (int) var ground_no_goop_tile_index: int

## Ground tilemap's tile ID for goopy cells
export (int) var ground_all_goop_tile_index: int

## Terrain tilemap's tile ID for pebble tiles
export (int) var pebble_tile_index: int

## Editor toggle which adds pebbles to a random selection of goopy/goopless cake tiles
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
## Pebble tiles are added to a random selection of goopy/goopless cake tiles.
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
	_ground_map = get_node(ground_map_path) if ground_map_path else null


func _erase_all_pebbles() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) == pebble_tile_index:
			_tile_map.set_cellv(cell, TileMap.INVALID_CELL)


func _add_random_pebbles() -> void:
	for cell in _ground_map.get_used_cells():
		var ground_cell_id := _ground_map.get_cellv(cell)
		if not ground_cell_id in [ground_no_goop_tile_index, ground_all_goop_tile_index]:
			# only add pebbles to goopy/goopless cake tiles
			continue
		if _tile_map.get_cellv(cell) != TileMap.INVALID_CELL:
			continue
		if not randf() <= pebble_density:
			# only add pebbles to a random selection of tiles
			continue
		var autotile_coord := Vector2(randi() % 4, randi() % 3)
		_tile_map.set_cellv(cell, pebble_tile_index, false, false, false, autotile_coord)
