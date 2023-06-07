class_name PieceDisplay
extends Node2D
## Contains logic for a single 'piece display'. A single display might display the piece which is coming up 3 pieces
## from now, or the player's currently held piece. Several displays are shown at once.

var _displayed_type: PieceType
var _displayed_orientation: int

@onready var tile_map: PuzzleTileMap = $TileMap

func _ready() -> void:
	CurrentLevel.changed.connect(_on_Level_settings_changed)
	_prepare_tileset()


## Updates the display based on the specified piece's type and orientation.
func refresh_tile_map(next_piece: NextPiece) -> void:
	if next_piece.type == _displayed_type and next_piece.orientation == _displayed_orientation:
		return
	
	tile_map.clear_puzzle()
	if next_piece.type != PieceTypes.piece_null:
		var bounding_box := Rect2i( \
				next_piece.type.get_cell_position(next_piece.orientation, 0), Vector2i.ONE)
		# update the tilemap with the new piece type
		for i in range(next_piece.type.pos_arr[0].size()):
			var block_pos := next_piece.type.get_cell_position(next_piece.orientation, i)
			var block_color := next_piece.type.get_cell_color(next_piece.orientation, i)
			tile_map.set_block(block_pos, 0, block_color)
			bounding_box = bounding_box.expand( \
					next_piece.type.get_cell_position(next_piece.orientation, i))
			bounding_box = bounding_box.expand( \
					next_piece.type.get_cell_position(next_piece.orientation, i) + Vector2i.ONE)
		
		# grow to accommodate bigger pieces
		var bounding_box_longest_dimension: float = max(bounding_box.size.x, bounding_box.size.y)
		tile_map.scale = Vector2(1.5, 1.5) / max(bounding_box_longest_dimension, 3)
		tile_map.position = Vector2(tile_map.tile_set.tile_size) * Vector2(0.75, 0.75) \
				- Vector2(tile_map.tile_set.tile_size) * tile_map.scale * (Vector2(bounding_box.position) + bounding_box.size / 2.0)
	
	tile_map.corner_map.dirty = true
	_displayed_type = next_piece.type
	_displayed_orientation = next_piece.orientation


func _prepare_tileset() -> void:
	tile_map.puzzle_tile_set_type = CurrentLevel.settings.other.tile_set


func _on_Level_settings_changed() -> void:
	_prepare_tileset()
