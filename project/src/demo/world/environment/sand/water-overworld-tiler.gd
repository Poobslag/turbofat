tool
extends Node
## Autotiles a tilemap for water tiles.
##
## Water tiles utilitize an AnimatedTexture, and Godot cannot autotile AnimatedTextures. The autotiling rules for
## water tiles are very simple anyways. Each water cell receives a random water texture.

## Indexes of water tiles in the parent tilemap
export (Array, int) var water_tile_indexes := []

## Editor toggle which manually applies autotiling
export (bool) var _autotile: bool setget autotile

## Tilemap with water which we should autotile
onready var _tile_map := get_parent()

## Preemptively initializes onready variables to avoid null references
func _enter_tree() -> void:
	_initialize_onready_variables()


## Autotiles water, applying a random water texture to each water cell.
func autotile(value: bool) -> void:
	if not value:
		# only autotile in the editor when the 'Autotile' property is toggled
		return
	
	if Engine.editor_hint:
		if not _tile_map:
			# initialize variables to avoid nil reference errors in the editor when editing tool scripts
			_initialize_onready_variables()
	
	_shuffle_water_tiles()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_tile_map = get_parent()


## Applies a random water texture to each water cell.
func _shuffle_water_tiles() -> void:
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) in water_tile_indexes:
			_tile_map.set_cellv(cell, Utils.rand_value(water_tile_indexes), randf() < 0.5)
