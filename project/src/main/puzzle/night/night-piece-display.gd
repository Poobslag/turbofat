class_name NightPieceDisplay
extends Node2D
## Contains logic for a piece display shown during night mode.
##
## This piece display is synchronized with a daytime piece display, and rendered over top of it.

## display to synchronize with
var source_display: PieceDisplay

@onready var _tile_map := $TileMap

func initialize(init_source_display: PieceDisplay) -> void:
	source_display = init_source_display


func _ready() -> void:
	_tile_map.source_tile_map = source_display.tile_map
