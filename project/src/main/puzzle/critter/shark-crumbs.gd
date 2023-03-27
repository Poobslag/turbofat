extends Particles2D
## Emits crumb particles as a piece is eaten.

## The path to the tile map for the pieces the shark is eating.
export (NodePath) var tile_map_path: NodePath

## The tile map for the pieces the shark is eating.
onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)

## Updates our particle properties based on the pieces the shark is eating.
##
## If the shark is eating an especially wide chunk of food, we will emit more particles over a wider area.
func refresh() -> void:
	if not _tile_map.get_used_cells():
		amount = 2
		return
	
	# assign color
	var used_cell: Vector2 = _tile_map.get_used_cells()[0]
	modulate = Utils.rand_value(_tile_map.crumb_colors_for_cell(used_cell))
	
	# assign width, position, scale
	process_material.emission_box_extents.x = max(1.0, _tile_map.get_used_rect().size.x) * _tile_map.cell_size.x * 0.5
	position.x = _tile_map.get_used_rect().get_center().x
	process_material.scale = _tile_map.global_scale.x
	
	# assign particle count (6 * cell width)
	amount = 6 * max(1.0, _tile_map.get_used_rect().size.x)
