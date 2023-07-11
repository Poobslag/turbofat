class_name EditorPlayfield
extends Control
## Playfield for use in the level editor.
##
## This script provides drag/drop logic and other things specific to the level editor.

## emitted when the player changes the tilemap's contents. This signal is not emitted when set_cell is called to
## prevent infinite recursion when populated by editor-json.gd.
signal tile_map_changed

## emitted when the player changes the pickups. This signal is not emitted set_pickup is called to
## prevent infinite recursion when populated by editor-json.gd.
signal pickups_changed

var _dragging_right_mouse := false

## 'pos' parameter for the previous call to 'can_drop_data'
var _prev_can_drop_pos: Vector2

## 'data' parameter for the previous call to 'can_drop_data'
var _prev_can_drop_data: Object

## Data previously dropped on this panel. New drag events originating from this panel reuse the dropped data.
var _prev_dropped_data: Object

onready var _tile_map := $Bg/TileMap
onready var _tile_map_drop_preview := $Bg/TileMapDropPreview
onready var _pickups := $Bg/Pickups
onready var _pickups_drop_preview := $Bg/PickupsDropPreview

func _ready() -> void:
	_tile_map.clear()
	_tile_map.get_node("CornerMap").dirty = true
	_pickups.clear()
	_clear_previews()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_dragging_right_mouse = event.button_mask & BUTTON_RIGHT
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		# click/drag the right mouse to erase parts of the tilemap
		if _dragging_right_mouse:
			var cell_pos := _cell_pos(event.position)
			# only emit signals if the underlying data changed to avoid generating json too frequently
			var should_update_tilemap := true if _tile_map.get_cellv(cell_pos) != TileMap.INVALID_CELL else false
			var should_update_pickups := true if _pickups.get_food_type(cell_pos) != -1 else false
			if should_update_tilemap:
				set_block(cell_pos, -1)
			if should_update_pickups:
				set_pickup(cell_pos, -1)
			if should_update_tilemap:
				emit_signal("tile_map_changed")
			if should_update_pickups:
				emit_signal("pickups_changed")


func can_drop_data(pos: Vector2, data: Object) -> bool:
	var can_drop := Rect2(Vector2.ZERO, rect_size).has_point(pos)
	if can_drop:
		if data is BlockLevelChunk:
			# update drop preview for block
			_clear_previews()
			_store_block_level_chunk(_tile_map_drop_preview, pos, data)
		if data is PickupLevelChunk:
			if _cell_pos(pos) == _cell_pos(_prev_can_drop_pos) \
					and _prev_can_drop_data is PickupLevelChunk \
					and data.box_type == _prev_can_drop_data.box_type:
				# ignore update; otherwise the pickup preview flickers wildly
				pass
			else:
				# update drop preview for pickup level chunk
				_clear_previews()
				_store_pickup_level_chunk(_pickups_drop_preview, pos, data)
	_prev_can_drop_pos = pos
	_prev_can_drop_data = data
	return can_drop


func drop_data(pos: Vector2, data: Object) -> void:
	if data is BlockLevelChunk:
		_clear_previews()
		_store_block_level_chunk(_tile_map, pos, data)
		emit_signal("tile_map_changed")
	if data is PickupLevelChunk:
		_clear_previews()
		_store_pickup_level_chunk(_pickups, pos, data)
		emit_signal("pickups_changed")
	
	# store the dropped data so it can be reused for later drag events
	_prev_dropped_data = data
	if _prev_dropped_data is BlockLevelChunk:
		# change vegetable data avoid repeating the same vegetables
		for cell in _prev_dropped_data.used_cells:
			if _prev_dropped_data.tiles[cell] == PuzzleTileMap.TILE_VEG:
				_prev_dropped_data.autotile_coords[cell] = PuzzleTileMap.random_veg_autotile_coord()


## If the player clicks and drags on the playfield, we reuse the previously dropped data.
##
## This makes it easier to populate a playfield with lots of vegetables or pickups.
func get_drag_data(_pos: Vector2) -> Object:
	return _prev_dropped_data


## Adds a dragged chunk of blocks to a tilemap.
##
## Parameters:
## 	'target_tile_map': The tilemap to modify
##
## 	'pos': An x/y control coordinate like '58, 132'
##
## 	'data': The data to apply to the tilemap
func _store_block_level_chunk(target_tile_map: PuzzleTileMap, pos: Vector2, data: BlockLevelChunk) -> void:
	for cell in data.used_cells:
		var target_pos: Vector2 = _cell_pos(pos) + cell
		_set_tile_map_block(target_tile_map, target_pos, data.tiles[cell], data.autotile_coords[cell])


## Adds a dragged pickup to a set of pickups.
##
## Parameters:
## 	'target_pickups': The set of pickups to modify
##
## 	'pos': An x/y control coordinate like '58, 132'
##
## 	'data': The pickup to add to the set of pickups
func _store_pickup_level_chunk(target_pickups: EditorPickups, pos: Vector2, data: PickupLevelChunk) -> void:
	var target_pos: Vector2 = _cell_pos(pos)
	target_pickups.set_pickup(target_pos, data.box_type)


## Clears all of the drop previews.
##
## When dragging/dropping items in the editor, we show translucent previews where the items will drop. These previews
## are cleared following a successful drop, or if the mouse exits the control.
func _clear_previews() -> void:
	_tile_map_drop_preview.clear()
	_pickups_drop_preview.clear()
	_prev_can_drop_pos = Vector2(-808, -949)
	_prev_can_drop_data = null


func set_block(pos: Vector2, tile: int, autotile_coord: Vector2 = Vector2.ZERO) -> void:
	_set_tile_map_block(_tile_map, pos, tile, autotile_coord)


func set_pickup(pos: Vector2, box_type: int) -> void:
	_pickups.set_pickup(pos, box_type)


func get_tile_map() -> TileMap:
	return $Bg/TileMap as TileMap


func get_pickups() -> EditorPickups:
	return $Bg/Pickups as EditorPickups


## Converts an x/y control coordinate like '58, 132' into a tile_map coordinate like '3, 2'
func _cell_pos(pos: Vector2) -> Vector2:
	var result := pos * Vector2(PuzzleTileMap.COL_COUNT, PuzzleTileMap.ROW_COUNT) / rect_size
	return result.floor()


func _set_tile_map_block(tile_map: TileMap, pos: Vector2, tile: int, autotile_coord: Vector2) -> void:
	if Rect2(0, 0, PuzzleTileMap.COL_COUNT, PuzzleTileMap.ROW_COUNT).has_point(pos):
		tile_map.set_block(pos, tile, autotile_coord)
		tile_map.get_node("CornerMap").dirty = true


func _on_mouse_exited() -> void:
	_clear_previews()
