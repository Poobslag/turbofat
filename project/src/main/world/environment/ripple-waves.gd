extends Node2D
## Renders animated goop waves.

const MAX_WAVE_COUNT := 50

## path to the underlying tilemap which controls where waves can spawn
export (NodePath) var tile_map_path: NodePath

## wave movement direction
export (Ripples.RippleDirection) var direction := Ripples.RippleDirection.NORTHEAST

export (PackedScene) var RippleWaveScene: PackedScene

## wave movement speed
export (float) var speed: float = 100.0

## duration between waves
export (float) var wait_time: float = 6.0

## ground tile ids which a ripple can appear over
export (Array, int) var rippleable_tile_ids := []

## path underlying tilemap which controls where waves can spawn
onready var _tile_map: TileMap = get_node(tile_map_path)

onready var _wave_spawn_timer := $WaveSpawnTimer

func _ready() -> void:
	_wave_spawn_timer.start(wait_time)
	
	# MAX_WAVE_COUNT is here for safety, but wave_index should never reach
	# MAX_WAVE_COUNT unless our speed is 0 or something else is wrong
	for wave_index in range(MAX_WAVE_COUNT):
		var wave_position := _wave_position(wave_index)
		wave_index += 1
		
		if not _tile_map.get_used_rect().has_point(_tile_map.world_to_map(wave_position)):
			# we've covered the tilemap with waves; the next wave would be out of bounds
			break
		
		_spawn_wave(wave_position)


## Calculates the position of the specified wave.
##
## When spawning the initial waves, waves are offset based on the wave frequency and movement speed.
func _wave_position(wave_index: int = 0) -> Vector2:
	# calculate where the first wave should spawn
	var wave_cell_position := Vector2.ZERO
	var used_rect := _tile_map.get_used_rect()
	match direction:
		Ripples.RippleDirection.NORTHEAST:
			wave_cell_position.x = int((used_rect.position.x + used_rect.end.x) * 0.5)
			wave_cell_position.y = used_rect.end.y - 1
		Ripples.RippleDirection.SOUTHEAST:
			wave_cell_position.x = used_rect.position.x
			wave_cell_position.y = int((used_rect.position.y + used_rect.end.y) * 0.5)
		Ripples.RippleDirection.SOUTHWEST:
			wave_cell_position.x = int((used_rect.position.x + used_rect.end.x) * 0.5)
			wave_cell_position.y = used_rect.position.y
		Ripples.RippleDirection.NORTHWEST:
			wave_cell_position.x = used_rect.end.x - 1
			wave_cell_position.y = int((used_rect.position.y + used_rect.end.y) * 0.5)
	var zero_wave_position := Utils.map_to_world_centered(_tile_map, wave_cell_position)
	
	# calculate the distance between each wave
	var offset_per_wave: Vector2 = speed * Ripples.ISO_VECTOR_BY_RIPPLE_DIRECTION[direction] \
			* _wave_spawn_timer.wait_time
	
	return zero_wave_position + wave_index * offset_per_wave


## Spawns a wave at the specified position.
func _spawn_wave(wave_position: Vector2) -> void:
	var ripple_wave_scene: RippleWave = RippleWaveScene.instance()
	ripple_wave_scene.initialize(_tile_map, direction, wave_position)
	ripple_wave_scene.rippleable_tile_ids = rippleable_tile_ids
	ripple_wave_scene.speed = speed
	add_child(ripple_wave_scene)


func _on_RippleSpawnTimer_timeout() -> void:
	var wave_position := _wave_position()
	_spawn_wave(wave_position)
