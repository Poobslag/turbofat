extends Node2D
## Creates goop globs on the playfield when the player does well.
##
## These goop globs are initialized to a specific color and position and launched in a random direction.

## emitted when a goop glob hits a wall
signal hit_wall(glob)

## emitted when a goop glob smears against the playfield or next piece area
signal hit_playfield(glob)
signal hit_next_pieces(glob)

@export var puzzle_tile_map_path: NodePath
@export var playfield_path: NodePath
@export var next_piece_displays_path: NodePath
@export var GoopGlobScene: PackedScene

@onready var _puzzle_tile_map: PuzzleTileMap = get_node(puzzle_tile_map_path)
@onready var _puzzle_areas: PuzzleAreas

## relative position of the PuzzleTileMap, used for positioning goop
@onready var _puzzle_tile_map_position: Vector2 = _puzzle_tile_map.get_global_transform().origin \
		- get_global_transform().origin

func _ready() -> void:
	_puzzle_areas = PuzzleAreas.new()
	_puzzle_areas.playfield_area = get_node(playfield_path).get_rect() if playfield_path else null
	_puzzle_areas.next_pieces_area = get_node(next_piece_displays_path).get_rect() if next_piece_displays_path else null
	_puzzle_areas.walled_area = _puzzle_areas.playfield_area.merge(_puzzle_areas.next_pieces_area)


## Launches new goop globs from the specified tile.
##
## Parameters:
## 	'cell_pos': An (x, y) position in the TileMap containing the playfield blocks
## 	'box_type': Enum from Foods.BoxType defining the glob's color
## 	'glob_count': The number of goop globs to launch
## 	'glob_alpha': The initial alpha component of the globs. Affects their size and duration
func _spawn_globs(cell_pos: Vector2i, box_type: Foods.BoxType, glob_count: int, glob_alpha: float = 1.0) -> void:
	var viewport: SubViewport
	if Foods.is_cake_box(box_type):
		viewport = $GlobViewports/RainbowViewport
	else:
		viewport = $GlobViewports/SubViewport
	
	for _i in range(glob_count):
		var glob: GoopGlob = _instance_glob(viewport)
		var glob_position := _puzzle_tile_map.somewhere_near_cell(cell_pos) + _puzzle_tile_map_position
		glob.initialize(box_type, glob_position)
		glob.modulate.a = glob_alpha
		glob.fall()


func _instance_glob(new_parent: Node = null) -> GoopGlob:
	var glob: GoopGlob = GoopGlobScene.instantiate()
	glob.puzzle_areas = _puzzle_areas
	glob.hit_wall.connect(_on_GoopGlob_hit_wall)
	glob.hit_playfield.connect(_on_GoopGlob_hit_playfield)
	glob.hit_next_pieces.connect(_on_GoopGlob_hit_next_pieces)
	new_parent.add_child(glob)
	return glob


## When a line is cleared, we generate goop globs for any boxes involved in the line clear.
##
## This must be called before the line is cleared so that we can evaluate the food blocks before they're erased.
func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		var box_type: Foods.BoxType
		var glob_count: int
		if _puzzle_tile_map.get_cell(x, y) == PuzzleTileMap.TILE_BOX:
			box_type = _puzzle_tile_map.get_cell_atlas_coords(0, Vector2i(x, y)).y
			if Foods.is_snack_box(box_type):
				glob_count = 2
			elif Foods.is_cake_box(box_type):
				glob_count = 4
		_spawn_globs(Vector2i(x, y), box_type, glob_count)


## When a box is built, we generate goop globs on the inside of the box.
func _on_Playfield_box_built(rect: Rect2i, box_type: Foods.BoxType) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var glob_count: int
			if Foods.is_snack_box(box_type):
				glob_count = 1
			elif Foods.is_cake_box(box_type):
				glob_count = 2
			_spawn_globs(Vector2i(x, y), box_type, glob_count)


## When a squish move is performed, we generate goop globs around the old and new piece position.
func _on_PieceManager_squish_moved(piece: ActivePiece, old_pos: Vector2i) -> void:
	if CurrentLevel.settings.other.tile_set == PuzzleTileMap.TileSetType.VEGGIE:
		# veggie pieces don't spawn goop
		return
	
	for pos_arr_item_obj in piece.get_pos_arr():
		var pos_arr_item: Vector2i = pos_arr_item_obj
		var glob_cell_from := old_pos + pos_arr_item
		var glob_cell_to := piece.pos + pos_arr_item
		_spawn_globs(glob_cell_from, piece.type.get_box_type(), 1, 0.8)
		_spawn_globs(glob_cell_to, piece.type.get_box_type(), 1, 0.8)


func _on_GoopGlob_hit_wall(glob: GoopGlob) -> void:
	emit_signal("hit_wall", glob)
	glob.queue_free()


func _on_GoopGlob_hit_playfield(glob: GoopGlob) -> void:
	emit_signal("hit_playfield", glob)


func _on_GoopGlob_hit_next_pieces(glob: GoopGlob) -> void:
	emit_signal("hit_next_pieces", glob)
