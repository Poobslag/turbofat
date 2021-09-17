class_name EditorPickups
extends Control
"""
Pickups for use in the level editor.

This stripped down class excludes gameplay code for sound effects and scoring. It only includes logic required for the
level editor.
"""

export (PackedScene) var SeedPickupScene: PackedScene
export (NodePath) var _puzzle_tile_map_path: NodePath

# key: Vector2 playfield cell positions
# value: Pickup node contained within that cell
var _pickups_by_cell: Dictionary

onready var _puzzle_tile_map: PuzzleTileMap = get_node(_puzzle_tile_map_path)

"""
Adds or replaces a pickup in a playfield cell.
"""
func set_pickup(cell: Vector2, box_type: int) -> void:
	remove_pickup(cell)
	
	if box_type != -1:
		var pickup: Pickup = SeedPickupScene.instance()
		pickup.food_type = _food_type_for_cell(box_type, cell)
	
		pickup.position = _puzzle_tile_map.map_to_world(cell)
		pickup.position += _puzzle_tile_map.cell_size * Vector2(0.5, 0.5)
		pickup.position *= _puzzle_tile_map.scale
		pickup.scale = _puzzle_tile_map.scale
		pickup.z_index = 4 # in front of the active piece
		
		_pickups_by_cell[cell] = pickup
		add_child(pickup)


"""
Returns the food type for the pickup at the specified cell.

Returns:
	An enum from Foods.FoodType for the pickup at the specified cell, or -1 if the cell is empty.
"""
func get_food_type(cell: Vector2) -> int:
	var result := -1
	if _pickups_by_cell.has(cell):
		var food_type: int = _pickups_by_cell.get(cell, -1).food_type
		result = Foods.BOX_TYPE_BY_FOOD_TYPE[food_type]
	return result


"""
Removes a pickup from a playfield cell.
"""
func remove_pickup(cell: Vector2) -> void:
	if not _pickups_by_cell.has(cell):
		return
	
	_pickups_by_cell[cell].queue_free()
	_pickups_by_cell.erase(cell)


"""
Removes all pickups from all playfield cells.
"""
func clear() -> void:
	for pickup in get_children():
		pickup.queue_free()
	_pickups_by_cell.clear()


func get_used_cells() -> Array:
	return _pickups_by_cell.keys()


"""
Return the food type for the specified cell.

The food type corresponds to the box type, although we alternate identical snack box pickups in a checkerboard pattern.
"""
func _food_type_for_cell(box_type: int, cell: Vector2) -> int:
	var food_types: Array = Foods.FOOD_TYPES_BY_BOX_TYPES[box_type]
	return food_types[(int(cell.x + cell.y) % food_types.size())]
