tool
extends Node
## Adds puddle tiles to an overworld terrain map.
##
## Puddle tiles are added to a random selection of goopless cake tiles.

export (NodePath) var ground_map_path: NodePath

## Percent of cake tiles which should have puddles
export (float, 0.0, 1.0) var puddle_density := 0.03

## The ground tilemap's tile ID for goopless cells
export (int) var ground_no_goop_tile_index: int

## The terrain tilemap's tile ID for puddle tiles
export (int) var puddle_tile_index: int

## An editor toggle which adds puddles to a random selection of goopy/goopless cake tiles
export (bool) var _autotile: bool setget autotile

## Terrain tilemap with puddle tiles to place
onready var _tile_map := get_parent()

## Ground tilemap containing data on which cells should have puddles on top of them
onready var _ground_map: TileMap = get_node(ground_map_path)

## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Refreshes the position of puddle tiles.
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
	
	_erase_all_puddles()
	_add_random_puddles()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
	_ground_map = get_node(ground_map_path) if ground_map_path else null


func _erase_all_puddles() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) == puddle_tile_index:
			_tile_map.set_cellv(cell, TileMap.INVALID_CELL)


func _add_random_puddles() -> void:
	for cell in _ground_map.get_used_cells():
		var ground_cell_id := _ground_map.get_cellv(cell)
		if not ground_cell_id in [ground_no_goop_tile_index]:
			# only add puddles to goopless cake tiles
			continue
		if _tile_map.get_cellv(cell) != TileMap.INVALID_CELL:
			continue
		if randf() >= puddle_density:
			# only add puddles to a random selection of tiles
			continue
		var autotile_coord := Vector2(randi() % 4, randi() % 3)
		_tile_map.set_cellv(cell, puddle_tile_index, false, false, false, autotile_coord)
