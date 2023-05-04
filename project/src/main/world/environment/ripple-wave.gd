class_name RippleWave
extends Node2D
## Renders an animated goop wave.
##
## A goop wave is made up of many RippleSprite instances in a line.

## controls how frequently waves speed up and slow down, in seconds
const SPEED_PERIOD := 6.0

## wave movement speed
@export var speed: float = 100.0

@export var RippleSpriteScene: PackedScene

## ground tile ids which a ripple can appear over
@export var rippleable_tile_ids: Array[int]

## Tilemap where waves should appear. Ripples appear and disappear based on the occupied cells of this tilemap.
var _tile_map: TileMap

## Enum from Ripples.RippleDirection for this wave's movement
var _direction := Ripples.RippleDirection.SOUTHEAST

## current position in the speed adjustment curve
var _speed_phase := randf_range(0, SPEED_PERIOD)

## controls how frequently this wave speeds up and slows down, in seconds
var _speed_period := randf_range(SPEED_PERIOD * 0.5, SPEED_PERIOD * 1.5)

func _ready() -> void:
	_add_ripple_sprites()
	_refresh_ripple_sprites()


func _process(delta: float) -> void:
	# recalculate the speed period if we've completed one cycle of the curve
	_speed_phase += delta
	if _speed_phase > _speed_period:
		_speed_phase -= _speed_period
		_speed_period = randf_range(SPEED_PERIOD * 0.5, SPEED_PERIOD * 1.5)
	
	# update the wave's position
	var velocity: Vector2 = Ripples.ISO_VECTOR_BY_RIPPLE_DIRECTION[_direction] * speed * delta
	var old_position: Vector2 = position
	position += lerp(velocity * 0.2, velocity * 1.8, \
			0.5 + 0.5 * cos(PI * 2 * _speed_phase / _speed_period))
	
	var cell_position := _tile_map.local_to_map(position)
	if cell_position != _tile_map.local_to_map(old_position):
		# the wave's tilemap position changed; refresh which ripples are visible/invisible
		_refresh_ripple_sprites()
	
	if not _tile_map.get_used_rect().has_point(cell_position):
		# the wave has left the tilemap boundaries; queue it for deletion
		queue_free()


## Called after instance() to set the wave's initial values.
func initialize(init_tile_map: TileMap, init_direction: Ripples.RippleDirection, init_position: Vector2) -> void:
	_tile_map = init_tile_map
	_direction = init_direction
	position = init_position


## Adds all ripple sprites corresponding to this wave.
##
## Ripples are never added after the wave is initially spawned. Instead, they are turned visible/invisible as the
## underlying terrain changes.
func _add_ripple_sprites() -> void:
	# calculate which cells are on the edge of the tilemap
	# all cells get a ripplesprite. unoccupied cells get a ripplesprite which starts invisible
	var used_rect := _tile_map.get_used_rect()
	var cell_position := _tile_map.local_to_map(position)
	match _direction:
		Ripples.RippleDirection.SOUTHWEST, Ripples.RippleDirection.NORTHEAST:
			for x in range(used_rect.position.x, used_rect.end.x):
				_add_ripple_sprite(Vector2i(x, cell_position.y))
		Ripples.RippleDirection.SOUTHEAST, Ripples.RippleDirection.NORTHWEST:
			for y in range(used_rect.position.y, used_rect.end.y):
				_add_ripple_sprite(Vector2i(cell_position.x, y))


## Adds a ripple sprite overlaying the specified position in the tilemap.
func _add_ripple_sprite(cell_pos: Vector2i) -> void:
	var ripple_sprite: RippleSprite = RippleSpriteScene.instantiate()
	
	# position the ripple sprite relative to the wave
	ripple_sprite.position = Utils.map_to_world_centered(_tile_map, cell_pos) \
			- Utils.map_to_world_centered(_tile_map, _tile_map.local_to_map(position))
	
	# the default wave sprite points southeast. flip it for other directions
	match _direction:
		Ripples.RippleDirection.NORTHEAST:
			ripple_sprite.flip_v = true
		Ripples.RippleDirection.SOUTHEAST:
			pass
		Ripples.RippleDirection.SOUTHWEST:
			ripple_sprite.flip_h = true
		Ripples.RippleDirection.NORTHWEST:
			ripple_sprite.flip_h = true
			ripple_sprite.flip_v = true
	
	add_child(ripple_sprite)


## Refreshes all ripple's states and appearance based on the tilemap.
func _refresh_ripple_sprites() -> void:
	var cell_forward_vector: Vector2i = Ripples.TILEMAP_VECTOR_BY_RIPPLE_DIRECTION[_direction]
	var cell_right_vector: Vector2i = _rotate_right(cell_forward_vector)
	
	for ripple_sprite in get_children():
		if not ripple_sprite is RippleSprite:
			# We may have other types of children (timers, debug sprites)
			continue
		
		var used_cell := _tile_map.local_to_map(ripple_sprite.position + position)
		
		# if there's no floor in front or behind, this ripple is off
		var ripple_off := not _is_rippleable(used_cell + cell_forward_vector) \
				or not _is_rippleable(used_cell) \
				or not _is_rippleable(used_cell - cell_forward_vector)
		
		# if there's floor in front/left and behind/left, this ripple connects left
		var connected_left := _is_rippleable(used_cell - cell_right_vector) \
				and _is_rippleable(used_cell - cell_right_vector + cell_forward_vector) \
				and _is_rippleable(used_cell - cell_right_vector - cell_forward_vector)
		
		# if there's floor in front/right and behind/right, this ripple connects right
		var connected_right := _is_rippleable(used_cell + cell_right_vector) \
				and _is_rippleable(used_cell + cell_right_vector + cell_forward_vector) \
				and _is_rippleable(used_cell + cell_right_vector - cell_forward_vector)
		
		# update the ripple sprite's state based on the floor cells
		if ripple_off:
			ripple_sprite.ripple_state = Ripples.RippleState.OFF
		elif connected_left and connected_right:
			ripple_sprite.ripple_state = Ripples.RippleState.CONNECTED_BOTH
		elif not connected_left and connected_right:
			ripple_sprite.ripple_state = Ripples.RippleState.CONNECTED_RIGHT
		elif connected_left and not connected_right:
			ripple_sprite.ripple_state = Ripples.RippleState.CONNECTED_LEFT
		else:
			ripple_sprite.ripple_state = Ripples.RippleState.CONNECTED_NONE


## Returns true if a ripple can appear over the specified tile.
func _is_rippleable(tile_position: Vector2i) -> bool:
	var result: bool
	if rippleable_tile_ids:
		# only show ripples over 'rippleable tiles', tiles with goop on them
		result = _tile_map.get_cell_source_id(0, tile_position) in rippleable_tile_ids
	else:
		# show ripples over any non-empty tiles
		result = _tile_map.get_cell_source_id(0, tile_position) != -1
	return result


func _rotate_right(v: Vector2i) -> Vector2i:
	return Vector2i(-v.y, v.x)
