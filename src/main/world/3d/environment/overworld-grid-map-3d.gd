# uncomment to alter grid map in editor
#tool
class_name OverworldGridMap3d
extends GridMap
"""
GridMap containing an overworld environment with ground, walls, environmental sprites.
"""

# invisible wall extending up from the cell
const TILE_IMPASSABLE := 0

# tilemap indexes corresponding to dirt/grass
const TILE_BLOCK_ROCKROCK := 1
const TILE_BLOCK_ROCK := 2
const TILE_BLOCKHALF_ROCK := 3

# tilemap indexes corresponding to paths
const TILE_PATH_END := 4
const TILE_PATH_STRAIGHT := 5
const TILE_PATH_CORNER := 6
const TILE_PATH_CIRCLE := 7

# tilemap indexes corresponding to tufts of grass
const TILE_GRASS_TUFTS := [8, 9, 10, 11]


# Orientation values used to rotate cell items
const ORIENT_UP := 0
const ORIENT_DOWN := 10
const ORIENT_LEFT := 16
const ORIENT_RIGHT := 22

"""
Defines autotiling behavior for paths.

Key: A bitmask corresponding to the surrounding tiles; 1=UP, 2=DOWN, 4=LEFT, 8=RIGHT

Value: Array containing the resulting path's tile and orientation.
"""
const PATH_AUTOTILE: Dictionary = {
	0: [TILE_PATH_CIRCLE, ORIENT_UP],
	1: [TILE_PATH_END, ORIENT_LEFT],
	2: [TILE_PATH_END, ORIENT_RIGHT],
	3: [TILE_PATH_STRAIGHT, ORIENT_RIGHT],
	4: [TILE_PATH_END, ORIENT_DOWN],
	5: [TILE_PATH_CORNER, ORIENT_UP],
	6: [TILE_PATH_CORNER, ORIENT_LEFT],
	7: [TILE_PATH_CIRCLE, ORIENT_UP],
	8: [TILE_PATH_END, ORIENT_UP],
	9: [TILE_PATH_CORNER, ORIENT_RIGHT],
	10: [TILE_PATH_CORNER, ORIENT_DOWN],
	11: [TILE_PATH_CIRCLE, ORIENT_UP],
	12: [TILE_PATH_STRAIGHT, ORIENT_UP],
	13: [TILE_PATH_CIRCLE, ORIENT_UP],
	14: [TILE_PATH_CIRCLE, ORIENT_UP],
	15: [TILE_PATH_CIRCLE, ORIENT_UP],
}

# Used in the editor to regenerate worlds when testing. They are not used during the game.
export(bool) var _regenerate_empty_world: bool setget regenerate_empty_world
export(bool) var _regenerate_dramatic_world: bool setget regenerate_dramatic_world

# the level's (x, z) extents. A value of (9, 6) represents an 18 x 12 level.
var _extents: Vector2

"""
Repopulate the grid map with a simple world.

The world contains a valley, walls on both sides, and a path down the middle.
"""
func regenerate_dramatic_world(regenerate: bool = true) -> void:
	if not regenerate:
		return
	
	regenerate_empty_world(true, Vector2(9, 6))
	
	var ridge_max_z := 3
	var ridge_min_z := -3
	var path_z := -1
	
	# walls
	for x in range(-9, 9):
		for y in range(0, 4):
			set_cell_item(x, y, -6, TILE_BLOCK_ROCK)
			set_cell_item(x, y, 5, TILE_BLOCK_ROCK)
	
	for x in range(-9, 9):
		var rand_walk: float
		
		# top ridge (flat area by wall)
		for z in range(ridge_max_z, 6):
			set_cell_item(x, 0, z, TILE_BLOCK_ROCK)
		ridge_max_z = _rand_walk(ridge_max_z, 2, 5)
		rand_walk = randf()
		
		# bottom ridge
		for z in range(-6, ridge_min_z):
			set_cell_item(x, 0, z, TILE_BLOCK_ROCK)
		ridge_min_z = _rand_walk(ridge_min_z, -5, -2)
		
		# path
		set_cell_item(x, 0, path_z, TILE_PATH_CIRCLE)
		set_cell_item(x, 0, path_z + 1, TILE_PATH_CIRCLE)
		if x > -9:
			set_cell_item(x - 1, 0, path_z, TILE_PATH_CIRCLE)
			set_cell_item(x - 1, 0, path_z + 1, TILE_PATH_CIRCLE)
		path_z = _rand_walk(path_z, -2, 0)
	
	plant_grass()
	autotile_paths()


"""
Randomly steps the specified input up and down, keeping it within the specified bounds.
"""
func _rand_walk(input: int, min_value: int, max_value: int) -> int:
	var output := input
	var r := randf()
	if r < 0.2 and output > min_value:
		output -= 1
	elif r < 0.4 and output < max_value:
		output += 1
	return output


"""
Regenerates an empty world.

The empty world only contains a floor surrounded by impassible walls.
"""
func regenerate_empty_world(regenerate: bool = true, extents: Vector2 = Vector2(16, 16)) -> void:
	if not regenerate:
		return
	
	_extents = extents
	clear()
	
	var x_max: int = int(extents.x)
	var z_max: int = int(extents.y)
	var x_min: int = -x_max
	var z_min: int = -z_max
	
	for x in range(x_min - 1, x_max + 1):
		set_cell_item(x, -1, z_min - 1, TILE_IMPASSABLE)
		set_cell_item(x, -1, z_max, TILE_IMPASSABLE)
	for z in range(z_min - 1, z_max + 1):
		set_cell_item(x_min - 1, -1, z, TILE_IMPASSABLE)
		set_cell_item(x_max, -1, z, TILE_IMPASSABLE)
	
	for x in range(x_min, x_max):
		for z in range(z_min, z_max):
			set_cell_item(x, -1, z, TILE_BLOCK_ROCKROCK)


"""
Randomly adds grass tufts.

Grass tufts are only placed over tiles which have a grassy surface.
"""
func plant_grass() -> void:
	for cell_obj in get_used_cells():
		var cell: Vector3 = cell_obj
		if get_cell_item(cell.x, cell.y, cell.z) == TILE_BLOCK_ROCK \
				and get_cell_item(cell.x, cell.y + 1, cell.z) == INVALID_CELL_ITEM:
			# the tile has a grassy surface; maybe add a grass tuft on the top
			if randf() < 0.10:
				set_cell_item(cell.x, cell.y + 1, cell.z, TILE_GRASS_TUFTS[randi() % TILE_GRASS_TUFTS.size()])


"""
Applies autotiling to paths so that they connect to each other.
"""
func autotile_paths() -> void:
	for cell_obj in get_used_cells():
		var cell: Vector3 = cell_obj
		if _is_path(cell.x, cell.y, cell.z):
			# it's a path tile. apply path autotiling logic
			var mask: int = 0
			if _should_path_autotile_to(cell.x, cell.y, cell.z - 1):
				mask = Connect.set_u(mask)
			if _should_path_autotile_to(cell.x, cell.y, cell.z + 1):
				mask = Connect.set_d(mask)
			if _should_path_autotile_to(cell.x - 1, cell.y, cell.z):
				mask = Connect.set_l(mask)
			if _should_path_autotile_to(cell.x + 1, cell.y, cell.z):
				mask = Connect.set_r(mask)
			
			var item: int = PATH_AUTOTILE[mask][0]
			var orientation: int = PATH_AUTOTILE[mask][1]
			if item == TILE_PATH_CIRCLE:
				orientation = ORIENT_UP if int(cell.x + cell.z) % 2 == 0 else ORIENT_RIGHT
			set_cell_item(cell.x, cell.y, cell.z, item, orientation)


"""
Returns 'true' if the specified coordinate contains a path tile.
"""
func _is_path(x: int, y: int, z: int) -> bool:
	return get_cell_item(x, y, z) \
			in [TILE_PATH_END, TILE_PATH_STRAIGHT, TILE_PATH_CORNER, TILE_PATH_CIRCLE]


"""
Returns 'true' if a path should autotile to the specified coordinate.

Paths autotile to other paths, but also autotile off the side of the map.
"""
func _should_path_autotile_to(x: int, y: int, z: int) -> bool:
	return x > _extents.x - 1 or x < -_extents.x \
			or y > _extents.y - 1 or y < -_extents.y \
			or _is_path(x, y, z)
