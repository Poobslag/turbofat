extends Node
tool
## Applies autotiling rules to all cells in a TileMap.
##
## After editing a TileSet, there's no easy way to reapply its autotile rules across an entire TileMap. This
## AutotileFixer node makes it easier.
##
## Instructions: Attach this node to a TileMap and toggle this node's 'autotile' property. This will apply autotiling
## rules to all tiles in the TileMap.

## Editor toggle which manually applies autotiling.
export (bool) var _autotile: bool setget autotile

## Applies autotiling rules to all cells in a TileMap.
func autotile(_value: bool) -> void:
	if not _value:
		return
	
	var tile_map: TileMap = get_parent()
	var used_rect := tile_map.get_used_rect()
	tile_map.update_bitmask_region(used_rect.position, used_rect.end)
