tool
extends Spatial
"""
A demo which shows off the overworld map generation.

Keys:
	[D]: Regenerate a dramatic world
	[E]: Regenerate an empty world
	[P]: Regenerate a 'path world' which demonstrates path autotiling
	[R]: Regenerate a random world
	[B]: Fling a ball
"""

export(bool) var _regenerate_path_world: bool setget regenerate_path_world

export(bool) var _regenerate_random_world: bool setget regenerate_random_world

func _ready() -> void:
	regenerate_path_world()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_D: $GridMap.regenerate_dramatic_world()
		KEY_E: $GridMap.regenerate_empty_world()
		KEY_P: regenerate_path_world()
		KEY_R: regenerate_random_world()
		KEY_B: $Sphere0.linear_velocity += 200 \
				* Vector3(rand_range(-1.0, 1.0), rand_range(0.01, 1.0), rand_range(-1.0, 1.0)).normalized()


func regenerate_random_world(regenerate: bool = true) -> void:
	$GridMap.regenerate_empty_world(true, Vector2(32, 32))
	
	for x in range(-32, 32):
		for z in range(-32, 32):
			if x in range(-24, 24) and z in range(-24, 24) and randf() < 0.9:
				$GridMap.set_cell_item(x, 0, z, OverworldGridMap.TILE_BLOCK_ROCK)
				if randf() < 0.4:
					$GridMap.set_cell_item(x, 1, z, OverworldGridMap.TILE_PATH_CIRCLE)
				elif x in range(-16, 16) and z in range(-16, 16) and randf() < 0.1:
					$GridMap.set_cell_item(x, 1, z, OverworldGridMap.TILE_BLOCKHALF_ROCK)
	
	$GridMap.plant_grass()
	$GridMap.autotile_paths()


func regenerate_path_world(regenerate: bool = true) -> void:
	$GridMap.regenerate_empty_world(true, Vector2(10, 10))
	
	for x in range(-8, 8):
		for z in range(-8, 8):
			if (not x in range(-2, 2) or not z in range(-1, 3)):
				$GridMap.set_cell_item(x, 0, z, OverworldGridMap.TILE_BLOCK_ROCK)
	
	var path_offset := Vector2(-4, -6)
	var path_layout := [
		" :   :::",
		":::: :::",
		" :   :::",
		" : :    ",
	]
	for z in range(0, path_layout.size()):
		for x in range(0, path_layout[z].length()):
			if path_layout[z][x] == ":":
				$GridMap.set_cell_item(x + path_offset.x, 1, z + path_offset.y, OverworldGridMap.TILE_PATH_CIRCLE)

	for x in range(-7, -5):
		for z in range(-7, -5):
			$GridMap.set_cell_item(x, 1, z, OverworldGridMap.TILE_BLOCKHALF_ROCK)
	
	for x in range(5, 7):
		for z in range(-7, -5):
			$GridMap.set_cell_item(x, 1, z, \
					OverworldGridMap.TILE_GRASS_TUFTS[randi() % OverworldGridMap.TILE_GRASS_TUFTS.size()])
	
	$GridMap.autotile_paths()
