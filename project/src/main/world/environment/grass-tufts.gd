extends YSort
"""
Generates grass tufts over grassy parts of a tilemap.
"""

const GRASS_CELL := 22

export (NodePath) var ground_map_path: NodePath
export (PackedScene) var GrassTuftScene: PackedScene

onready var _ground_map: TileMap = get_node(ground_map_path)

# the direction of the tilemap's x and y axis
var _x_axis: Vector2
var _y_axis: Vector2

func _ready() -> void:
	_x_axis = _ground_map.cell_size * Vector2(0.5, 0.5)
	_y_axis = _ground_map.cell_size * Vector2(-0.5, 0.5)
	_refresh()


func _refresh() -> void:
	for child in get_children():
		child.queue_free()
	
	# add grass tufts over some of the tilemap's grassy cells
	for cell_obj in _ground_map.get_used_cells():
		var cell: Vector2 = cell_obj
		if _ground_map.get_cellv(cell) == GRASS_CELL:
			if randf() < 0.12:
				_add_tuft(cell)
				_add_tuft(cell)
			elif randf() < 0.25:
				_add_tuft(cell)


"""
Adds a grass tuft to a random position within the specified cell.
"""
func _add_tuft(cell: Vector2) -> void:
	var new_tuft: Sprite = GrassTuftScene.instance()
	new_tuft.position = _ground_map.map_to_world(cell) + _x_axis * randf() + _y_axis * randf()
	new_tuft.flip_h = randf() > 0.5
	add_child(new_tuft)
