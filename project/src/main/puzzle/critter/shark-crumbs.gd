extends Particles2D
## Emits crumb particles as a piece is eaten.

## Tile map for the pieces the shark is eating.
var tile_map: PuzzleTileMap setget set_tile_map

func set_tile_map(new_tile_map: PuzzleTileMap) -> void:
	tile_map = new_tile_map
	
	refresh()


## Updates our particle properties based on the pieces the shark is eating.
##
## If the shark is eating an especially wide chunk of food, we will emit more particles over a wider area.
func refresh() -> void:
	if not tile_map or not tile_map.get_used_cells():
		amount = 2
		return
	
	# assign color
	var used_cell: Vector2 = tile_map.get_used_cells()[0]
	modulate = Utils.rand_value(tile_map.crumb_colors_for_cell(used_cell))
	
	# assign width, position, scale
	process_material.emission_box_extents.x = max(1.0, tile_map.get_used_rect().size.x) * tile_map.cell_size.x * 0.5
	position.x = tile_map.get_used_rect().get_center().x
	process_material.scale = tile_map.global_scale.x
	
	# assign particle count (6 * cell width)
	amount = 6 * max(1.0, tile_map.get_used_rect().size.x)
