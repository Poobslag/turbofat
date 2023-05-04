extends Control
## Draws shadowy stars and seeds inside snack boxes and cake boxes during night mode.
##
## These star seeds are is synchronized with the daytime star seeds, and rendered over them.

## path to the daytime starseeds to synchronize with.
@export var source_star_seeds_path: NodePath

@export var StarSeedScene: PackedScene

## key: (Vector2i) playfield cell positions
## value: (StarSeed) StarSeed node contained within that cell
var _star_seeds_by_cell: Dictionary

## daytime starseeds to synchronize with.
@onready var _source_star_seeds: StarSeeds = get_node(source_star_seeds_path)

func _process(_delta: float) -> void:
	for cell in Utils.subtract(_star_seeds_by_cell.keys(), _source_star_seeds.get_cells_with_star_seeds()):
		_remove_star_seed(cell)
	
	for cell in Utils.subtract(_source_star_seeds.get_cells_with_star_seeds(), _star_seeds_by_cell.keys()):
		_add_star_seed(cell)
	
	for cell in _star_seeds_by_cell:
		_star_seeds_by_cell[cell].food_type = _source_star_seeds.get_star_seed(cell).food_type


## Removes a star seed from a playfield cell.
func _remove_star_seed(cell: Vector2i) -> void:
	_star_seeds_by_cell[cell].queue_free()
	_star_seeds_by_cell.erase(cell)


## Adds a star seed to a playfield cell.
func _add_star_seed(cell: Vector2i) -> void:
	var star_seed: StarSeed = StarSeedScene.instantiate()
	
	var source_star_seed := _source_star_seeds.get_star_seed(cell)
	star_seed.visible = _source_star_seeds.get_star_seed(cell).visible
	star_seed.food_type = source_star_seed.food_type
	star_seed.position = source_star_seed.position
	star_seed.scale = source_star_seed.scale
	star_seed.z_index = 4
	
	_star_seeds_by_cell[cell] = star_seed
	add_child(star_seed)
