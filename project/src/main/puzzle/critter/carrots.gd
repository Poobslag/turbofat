class_name Carrots
extends Node2D
## Handles carrots, puzzle critters which rocket up the screen, blocking the player's vision.
##
## Carrots remain onscreen for several seconds. They have many different sizes, and can also leave behind a smokescreen
## which blocks the player's vision for even longer.

export (PackedScene) var CarrotScene: PackedScene

var playfield_path: NodePath setget set_playfield_path

var _playfield: Playfield

func _ready() -> void:
	_refresh_playfield_path()


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()


## Removes the newest carrots from the playfield.
##
## Parameters:
## 	'count': The number of carrots to remove. If there aren't enough carrots on the playfield, all carrots are removed.
func remove_carrots(count: int) -> void:
	for _i in range(count):
		_remove_carrot()


## Adds carrots to the playfield.
##
## Details like the number of carrots to add, where to add them and how fast they move are all specified by the config
## parameter.
##
## Parameters:
## 	'config': rules for how many carrots to add, where to add them, and how fast they move.
func add_carrots(config: CarrotConfig) -> void:
	var potential_carrot_columns: Array
	if config.columns:
		potential_carrot_columns = config.columns.duplicate()
	else:
		potential_carrot_columns = range(PuzzleTileMap.COL_COUNT)
	
	# don't allow carrots to spawn too far to the right
	var carrot_dimensions: Vector2 = CarrotConfig.DIMENSIONS_BY_CARROT_SIZE[config.size]
	potential_carrot_columns = Utils.intersection(potential_carrot_columns, \
			range(PuzzleTileMap.COL_COUNT - carrot_dimensions.x))
	potential_carrot_columns.shuffle()
	
	for i in range(1, potential_carrot_columns.size()):
		if abs(potential_carrot_columns[i] - potential_carrot_columns[i - 1]) < carrot_dimensions.x:
			# carrots are too close together; swap another carrot in
			var swap_index := i
			for j in range(i + 1, potential_carrot_columns.size()):
				if abs(potential_carrot_columns[j] - potential_carrot_columns[i - 1]) >= carrot_dimensions.x:
					swap_index = j
					break
			if swap_index != i:
				var swap: int = potential_carrot_columns[i]
				potential_carrot_columns[i] = potential_carrot_columns[swap_index]
				potential_carrot_columns[swap_index] = swap
	
	for i in range(min(config.count, potential_carrot_columns.size())):
		_add_carrot(Vector2(potential_carrot_columns[i], PuzzleTileMap.ROW_COUNT), config)


func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	_playfield = get_node(playfield_path)


## Adds a carrot to the specified cell.
##
## Details like the number of carrots to add, where to add them and how fast they move are all specified by the config
## parameter.
##
## Parameters:
## 	'config': rules for how many carrots to add, where to add them, and how fast they move.
func _add_carrot(cell: Vector2, config: CarrotConfig) -> void:
	var carrot_dimensions: Vector2 = CarrotConfig.DIMENSIONS_BY_CARROT_SIZE[config.size]
	
	# initialize the carrot and add it to the scene
	var carrot: Carrot = CarrotScene.instance()
	
	carrot.z_index = 5
	carrot.scale = _playfield.tile_map.scale
	
	carrot.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	carrot.position += _playfield.tile_map.cell_size * Vector2(carrot_dimensions.x * 0.5, 0.5)
	carrot.position *= _playfield.tile_map.scale
	
	carrot.smoke = config.smoke
	carrot.carrot_size = config.size
	
	add_child(carrot)
	
	# launch the carrot towards its destination at the top of the screen
	var destination_cell := Vector2(cell.x, 0)
	var destination_position: Vector2
	destination_position = _playfield.tile_map.map_to_world(destination_cell + Vector2(0, -carrot_dimensions.y))
	destination_position += _playfield.tile_map.cell_size * Vector2(carrot_dimensions.x * 0.5, 0.5)
	destination_position *= _playfield.tile_map.scale
	
	var duration := config.duration
	carrot.launch(destination_position, duration)


## Removes the newest carrot.
func _remove_carrot() -> void:
	var i := get_child_count() - 1
	while i >= 0:
		var carrot: Carrot = get_child(i)
		if not carrot.hiding:
			carrot.hide()
			break
		i -= 1
