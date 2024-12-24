extends Node2D
## Draws the eating effects including the cyclone of teeth and dust cloud which appear while a shark is eating.
##
## Coordinates animations and adjusts the tilemap of eaten tiles.

signal finished_eating

## Number of animation variants in the sprite sheet. We cycle between random variants.
const TOOTH_VARIANT_COUNT := 5

## Start position for the tilemap of eaten tiles. The tilemap moves down as the shark eats.
const TILE_MAP_START_POSITION := Vector2(144, 296)

## Path to the Particles2D which emits crumb particles as a piece is eaten.
export (NodePath) var crumbs_path: NodePath

export (PackedScene) var PuzzleTileMapScene: PackedScene

## Can be set to 'true' to activate the tooth cloud's various eating effects.
export (bool) var eating: bool = false setget set_eating

## Tile index in the PuzzleTileMap's tileset which is currently being eaten (piece, box, vegetable...)
var eaten_tile := 0

## Autotile_y for the flavor of pieces being eaten (chocolate, fruit, bread...)
var eaten_autotile_y := 0

## Duration in seconds the shark takes to eat.
var eat_duration := Shark.DEFAULT_EAT_DURATION

## Tween which ends the eating animation.
var _eat_tween: SceneTreeTween

## node which contains any child PuzzleTileMap node
onready var _tilemap_holder: Control = $TileMapHolder

## Eaten piece tilemap.
onready var _tile_map: PuzzleTileMap

## Dust clouds which appear over the shark's mouth while they eat.
onready var _clouds: SharkClouds = $Clouds

## Cyclone of teeth which appears over the shark's mouth while they eat.
onready var _tooth: Sprite = $Tooth

## Emits crumb particles as a piece is eaten.
onready var _crumbs: Particles2D = get_node(crumbs_path)

## Timer which cycles the dust clouds to the next frame.
onready var _cloud_timer: Timer = $CloudTimer

## Timer which cycles the cyclone of teeth to the next frame.
onready var _tooth_timer: Timer = $ToothTimer

func _ready() -> void:
	_refresh_eating()


## Assigns all eaten tiles to a new color.
##
## Parameters:
## 	'tile': tile index in the PuzzleTileMap's tileset which is currently being eaten (piece, box, vegetable...)
##
## 	'autotile_y': autotile_y for the flavor of pieces being eaten (chocolate, fruit, bread...)
func set_eaten_color(tile: int, autotile_y: int) -> void:
	_check_for_tilemap()
	eaten_tile = tile
	eaten_autotile_y = autotile_y
	
	for cell in _tile_map.get_used_cells():
		var autotile_coord := _tile_map.get_cell_autotile_coord(cell.x, cell.y)
		autotile_coord.y = eaten_autotile_y
		_tile_map.set_block(cell, eaten_tile, autotile_coord)


## Adds a cell to the eaten piece tilemap.
func set_eaten_cell(position: Vector2) -> void:
	_check_for_tilemap()
	_tile_map.set_block(position, eaten_tile, Vector2(0, eaten_autotile_y))


## Clears the eaten piece tilemap.
func clear_eaten_cells() -> void:
	_check_for_tilemap()
	_tile_map.clear()


## Updates the tileset for the eaten piece tilemap.
##
## Parameters:
## 	'new_puzzle_tile_set_type': enum from TileSetType referencing the tileset used to render blocks
func set_puzzle_tile_set_type(new_puzzle_tile_set_type: int) -> void:
	_check_for_tilemap()
	_tile_map.set_puzzle_tile_set_type(new_puzzle_tile_set_type)


func set_eating(new_eating: bool) -> void:
	if eating == new_eating:
		return
	eating = new_eating
	
	_refresh_eating()


## Toggles our visual effects visible or invisible based on our current 'eating' value.
func _refresh_eating() -> void:
	visible = eating
	if visible:
		_check_for_tilemap()
		_cloud_timer.start()
		_tooth_timer.start()
		
		_clouds.refresh()
		_crumbs.refresh()
		_crumbs.emitting = true
		_connect_eaten_cells()
		_start_eat_tween()
	else:
		_crumbs.emitting = false
		_cloud_timer.stop()
		_tooth_timer.stop()
		_eat_tween = Utils.kill_tween(_eat_tween)


## Connects adjacent cells in the eaten piece tilemap.
func _connect_eaten_cells() -> void:
	for cell in _tile_map.get_used_cells():
		var autotile_coord := Vector2(0, eaten_autotile_y)
		if _tile_map.get_cellv(cell + Vector2.UP) != TileMap.INVALID_CELL:
			autotile_coord.x = PuzzleConnect.set_u(autotile_coord.x)
		if _tile_map.get_cellv(cell + Vector2.DOWN) != TileMap.INVALID_CELL:
			autotile_coord.x = PuzzleConnect.set_d(autotile_coord.x)
		if _tile_map.get_cellv(cell + Vector2.LEFT) != TileMap.INVALID_CELL:
			autotile_coord.x = PuzzleConnect.set_l(autotile_coord.x)
		if _tile_map.get_cellv(cell + Vector2.RIGHT) != TileMap.INVALID_CELL:
			autotile_coord.x = PuzzleConnect.set_r(autotile_coord.x)
		_tile_map.set_block(cell, eaten_tile, autotile_coord)


## Makes the eaten piece tilemap descend into the shark's mouth.
func _start_eat_tween() -> void:
	var piece_height := _tile_map.get_used_rect().size.y * _tile_map.cell_size.y
	_tile_map.position = TILE_MAP_START_POSITION
	_eat_tween = Utils.recreate_tween(self, _eat_tween)
	_eat_tween.tween_property(_tile_map, "position",
			TILE_MAP_START_POSITION + Vector2(0, piece_height), eat_duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_eat_tween.tween_callback(self, "_on_Tween_completed")


## Randomizes the appearance of the cyclone of teeth.
##
## Cycles to a randomly selected animation frame and randomly flips it horizontally.
func _shuffle_tooth() -> void:
	_tooth.flip_h = randf() < 0.5
	_tooth.frame = (_tooth.frame + Utils.randi_range(1, TOOTH_VARIANT_COUNT - 1)) % TOOTH_VARIANT_COUNT


## Lazily instances the tilemap if it
##
## It takes about 34 ms to instance the PuzzleTileMap. Doing it for a single shark results in a slight 1-2 frame burp,
## but doing it for 10-20 sharks which all spawn simultaneously results in 20-40 frames of lag.
func _check_for_tilemap() -> void:
	if not _tile_map:
		_borrow_tilemap()
		_tile_map.position = TILE_MAP_START_POSITION
		_tile_map.scale = Vector2.ONE
		_tile_map.z_index = 0


## Obtains a PuzzleTileMap, either from a SharkTileMapPool or by instancing one.
func _borrow_tilemap() -> void:
	var new_tile_map: PuzzleTileMap
	if _shark_tile_map_pool():
		# if a SharkTileMapPool is available, we obtain a pooled PuzzleTileMap
		new_tile_map = _shark_tile_map_pool().borrow_tilemap()
	else:
		# if no SharkTileMapPool is available, we instance our own PuzzleTileMap.
		new_tile_map = PuzzleTileMapScene.instance()
	
	_tile_map = new_tile_map
	_tilemap_holder.add_child(_tile_map)
	_clouds.tile_map = _tile_map
	_crumbs.tile_map = _tile_map


## Returns any SharkTileMapPool in the scene tree, or 'null' if none exists.
func _shark_tile_map_pool() -> SharkTileMapPool:
	if not is_inside_tree():
		return null
	var pool: SharkTileMapPool
	if get_tree().get_nodes_in_group("shark_tilemap_pools"):
		pool = get_tree().get_nodes_in_group("shark_tilemap_pools")[0]
	return pool


## Releases this shark's PuzzleTileMap, either returning it to the SharkTileMapPool or freeing it.
func _return_tilemap() -> void:
	var old_tile_map := _tile_map
	
	_tilemap_holder.remove_child(old_tile_map)
	_tile_map = null
	_clouds.tile_map = null
	_crumbs.tile_map = null
	
	if _shark_tile_map_pool():
		# if a SharkTileMapPool is available, we return our pooled PuzzleTileMap
		_shark_tile_map_pool().return_tilemap(old_tile_map)
	else:
		# if no SharkTileMapPool is available, we free our PuzzleTileMap
		old_tile_map.queue_free()


func _on_CloudTimer_timeout() -> void:
	_clouds.shuffle()


func _on_ToothTimer_timeout() -> void:
	_shuffle_tooth()


func _on_Tween_completed() -> void:
	# we don't need our PuzzleTileMap anymore; return it to the SharkTileMapPool so other sharks can use it
	_return_tilemap()
	
	emit_signal("finished_eating")
