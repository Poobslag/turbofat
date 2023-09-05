class_name FryingPansUi
extends Control
## UI control which shows a list of frying pans corresponding to the player's lives.
##
## The frying pans are displayed in a tilemap. When the player tops out, the tilemap is updated and a new 'frying pan
## ghost' is added, which animates a frying pan fading away.

## tileset index for regular pans (white)
const TILE_INDEX_PAN := 0

## tileset index for gold pans (yellow with a circular mark)
const TILE_INDEX_PAN_GOLD := 1

## tileset index for dead pans (red with a slash)
const TILE_INDEX_PAN_DEAD := 2

## if true, the pans are shown as gold pans. golden pans are used shown if topping out clears the playfield
export (bool) var gold := false setget set_gold

## maximum number of frying pans to display (the number of lives the player starts with)
export (int) var pans_max := 3 setget set_pans_max

## number of remaining non-dead pans (the number of lives the player has left)
export (int) var pans_remaining := 3 setget set_pans_remaining

export (PackedScene) var FryingPanGhostScene: PackedScene

## tilemap cell containing the upper left most dead pan
var _first_dead_cell: Vector2

onready var _tile_map: TileMap = $TileMap

func _ready() -> void:
	refresh_tilemap()


func set_gold(new_gold: bool) -> void:
	if gold == new_gold:
		return
	gold = new_gold
	refresh_tilemap()


func set_pans_max(new_pans_max: int) -> void:
	if pans_max == new_pans_max:
		return
	pans_max = new_pans_max
	refresh_tilemap()


## Sets the number of remaining non-dead pans (the number of lives the player has left.)
##
## This refreshes the tilemap and sometimes adds a frying pan ghost.
func set_pans_remaining(new_pans_remaining: int) -> void:
	if pans_remaining == new_pans_remaining:
		return
	
	var old_pans_remaining := pans_remaining
	pans_remaining = new_pans_remaining
	refresh_tilemap()
	
	if is_inside_tree() and pans_remaining == old_pans_remaining - 1:
		_add_frying_pan_ghost()


## Recalculates the tilemap cells, tilemap scale, and _first_dead_cell field.
func refresh_tilemap() -> void:
	var pan_cells := _calculate_pan_cells()
	_tile_map.clear()
	_add_pans_to_tilemap(pan_cells)
	_update_tilemap_scale()


## Calculates the position of frying pans within the tilemap.
##
## Returns:
## 	An array of Vector2 coordinates in the tilemap which should contain frying pans.
func _calculate_pan_cells() -> Array:
	var pan_cells := []
	
	# calculate the number of pans per row
	var pans_per_row := 6
	if pans_max >= 19:
		pans_per_row = 10
	elif pans_max >= 6:
		pans_per_row = 6
	else:
		pans_per_row = 5
	
	# calculate the positions of pans within each row
	var cell_pos := Vector2.ZERO
	for _i in range(min(pans_max, 50)):
		pan_cells.append(cell_pos)
		cell_pos.x += 2
		if cell_pos.x >= 2 * pans_per_row:
			cell_pos = Vector2(0, cell_pos.y + 1)
	
	# center the bottom row horizontally
	for i in range(pans_max - cell_pos.x / 2, min(pans_max, 50)):
		pan_cells[i].x += pans_per_row - cell_pos.x / 2
	
	return pan_cells


## Places pans in the appropriate tilemap cells.
##
## Parameters:
## 	'pan_cells': An array of Vector2 coordinates in the tilemap which should contain frying pans.
func _add_pans_to_tilemap(pan_cells: Array) -> void:
	for i in range(pan_cells.size()):
		var pan_cell: Vector2 = pan_cells[i]
		var tile: int
		if i >= pans_remaining:
			tile = TILE_INDEX_PAN_DEAD
			if i == pans_remaining:
				# update the _first_dead_cell field to facilitate the spawning of frying pan ghosts
				_first_dead_cell = pan_cell
		elif gold:
			tile = TILE_INDEX_PAN_GOLD
		else:
			tile = TILE_INDEX_PAN
		_tile_map.set_cellv(pan_cell, tile)


## Updates the tilemap scale based on its contents.
##
## The tilemap is rescaled so that its contents will fit into its parent control horizontally.
func _update_tilemap_scale() -> void:
	var total_width := max(10, _tile_map.get_used_rect().size.x + 1) * _tile_map.cell_size.x
	_tile_map.scale = Vector2.ONE * (rect_size.x / total_width)


## Animates a pan disappearing when the player loses a life.
##
## The ghost is spawned at the location of the the upper left most dead pan. It should be called immediately after the
## player loses a life and the tilemap is refreshed.
func _add_frying_pan_ghost() -> void:
	var frying_pan_ghost: Sprite = FryingPanGhostScene.instance()
	var tile_id := TILE_INDEX_PAN_GOLD if gold else TILE_INDEX_PAN
	frying_pan_ghost.texture = _tile_map.tile_set.tile_get_texture(tile_id)
	frying_pan_ghost.material = _tile_map.tile_set.tile_get_material(tile_id)
	frying_pan_ghost.scale = _tile_map.scale
	frying_pan_ghost.position = _tile_map.cell_size * _tile_map.scale * (_first_dead_cell + Vector2(1.0, 0.5))
	add_child(frying_pan_ghost)
