class_name NightPuzzleTileMap
extends TileMap
## TileMap containing puzzle blocks shown to the player during night mode.
##
## This tilemap is synchronized with a daytime tilemap, and rendered over it.

## All nighttime tilemaps are drawn with the same shade of light blue.
const TILE_COLOR := Color("aed8d1")

## tilemap to synchronize with
var source_tile_map: PuzzleTileMap: set = set_source_tile_map

## number in the range [0, 1] which can be set to make the tilemap flash or blink.
var whiteness := 0.0: set = set_whiteness

func _process(_delta: float) -> void:
	if not source_tile_map:
		return
	
	visible = source_tile_map.visible
	
	if visible:
		_refresh_tiles_from_source()
		scale = source_tile_map.scale
		position = source_tile_map.position


func set_source_tile_map(new_source_tile_map: PuzzleTileMap) -> void:
	source_tile_map = new_source_tile_map


## Refreshes the tilemap's cells to match the source tilemap 1:1.
##
## Can be overridden to refresh tiles differently.
func _refresh_tiles_from_source() -> void:
	clear()
	for cell in source_tile_map.get_used_cells():
		var autotile_coord := Vector2(source_tile_map.get_cell_autotile_coord(cell.x, cell.y).x, 0)
		set_cellv(cell, 0, false, false, false, autotile_coord)
	
	visible = source_tile_map.visible


## Sets the whiteness property to make the tilemap flash or blink.
func set_whiteness(new_whiteness: float) -> void:
	if whiteness == new_whiteness:
		return
	whiteness = new_whiteness
	
	modulate = lerp(TILE_COLOR, Color.WHITE, whiteness)
