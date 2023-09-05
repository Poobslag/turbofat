tool
extends Node
## Adds chocolate chip tiles to an overworld terrain map.
##
## Chocolate chip tiles are added to a random selection of goopy/goopless cake tiles.

export (NodePath) var ground_map_path: NodePath

## Percent of cake tiles which should have chips
export (float, 0.0, 1.0) var chip_density := 0.03

## Ground tilemap's tile ID for goopless cells
export (int) var ground_no_goop_tile_index: int

## Ground tilemap's tile ID for goopy cells
export (int) var ground_all_goop_tile_index: int

## Terrain tilemap's tile ID for goopless chocolate chip tiles
export (int) var chip_no_goop_tile_index: int

## Terrain tilemap's tile ID for goopy chocolate chip tiles
export (int) var chip_goop_tile_index: int

## Editor toggle which adds chips to a random selection of goopy/goopless cake tiles
export (bool) var _autotile: bool setget autotile

## Terrain tilemap with chip tiles to place
onready var _tile_map := get_parent()

## Ground tilemap containing data on which cells should have chips on top of them
onready var _ground_map: TileMap = get_node(ground_map_path)

## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Refreshes the position of chip tiles.
##
## Chip tiles are added to a random selection of goopy/goopless cake tiles.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_erase_all_chips()
	_add_random_chips()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
	_ground_map = get_node(ground_map_path) if ground_map_path else null


func _erase_all_chips() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) in [chip_no_goop_tile_index, chip_goop_tile_index]:
			_tile_map.set_cellv(cell, TileMap.INVALID_CELL)


func _add_random_chips() -> void:
	for cell in _ground_map.get_used_cells():
		var ground_cell_id := _ground_map.get_cellv(cell)
		var chip_tile_index := -1
		match ground_cell_id:
			ground_no_goop_tile_index:
				chip_tile_index = chip_no_goop_tile_index
			ground_all_goop_tile_index:
				chip_tile_index = chip_goop_tile_index
		if chip_tile_index == -1:
			continue
		if _tile_map.get_cellv(cell) != TileMap.INVALID_CELL:
			# only add chips to empty cells
			continue
		if not randf() < chip_density:
			# only add chips to a random selection of tiles
			continue
		var autotile_coord := Vector2(randi() % 4, randi() % 3)
		_tile_map.set_cellv(cell, chip_tile_index, randf() < 0.5, false, false, autotile_coord)
