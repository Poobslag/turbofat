tool
extends Node
## Randomizes sugar on an overworld terrain map.
##
## Sugar is manually applied to parts of the map. This tiler randomizes the appearance of sugar tiles by flipping tiles
## and selecting random autotile coordinates.

## Terrain tilemap's tile ID for sugar tiles
export (int) var sugar_tile_index: int

## Editor toggle which randomizes the appearance of sugar tiles.
export (bool) var _autotile: bool setget autotile

## Editor toggle which undoes autotiling, reverting all sugar tiles to an unflipped non-random state.
export (bool) var _unautotile: bool setget unautotile

## Terrain tilemap with sugar tiles to place
onready var _tile_map := get_parent()

## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Randomizes the appearance of sugar tiles.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	for cell in _tile_map.get_used_cells_by_id(sugar_tile_index):
		## select a random autotile coordinate
		var autotile_coord := Vector2(Utils.randi_range(0, 1), Utils.randi_range(0, 1))
		
		## randomly flip the sugar tile
		var flip_x := randf() < 0.5
		var flip_y := randf() < 0.5
		
		_tile_map.set_cellv(cell, sugar_tile_index, flip_x, flip_y, false, autotile_coord)

## Undoes autotiling, reverting all sugar tiles to an unflipped non-random state.
func unautotile(value: bool) -> void:
	if not value:
		# only unautotile in the editor when the 'unautotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	for cell in _tile_map.get_used_cells_by_id(sugar_tile_index):
		# revert the sugar tile to an unflipped non-random state.
		_tile_map.set_cellv(cell, sugar_tile_index, false, false, false, Vector2.ZERO)


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()
