extends Node
## Moves the ghost piece when the piece or playfield changes.

export (NodePath) var tile_map_path: NodePath

## Stores the offset used when drawing the ghost piece.
#
## We calculate and store this even if the ghost piece is disabled. This allows us to properly handle enabling and
## disabling the ghost piece during a puzzle.
var _ghost_shadow_offset := Vector2.ZERO

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)

func _ready() -> void:
	SystemData.gameplay_settings.connect("ghost_piece_changed", self, "_on_GameplaySettings_ghost_piece_changed")
	_refresh_ghost_piece()


func _refresh_ghost_piece() -> void:
	if SystemData.gameplay_settings.ghost_piece:
		_tile_map.set_ghost_shadow_offset(_ghost_shadow_offset)
	else:
		_tile_map.set_ghost_shadow_offset(Vector2.ZERO)


func _on_Dropper_hard_drop_target_pos_changed(piece: ActivePiece, hard_drop_target_pos: Vector2) -> void:
	_ghost_shadow_offset = hard_drop_target_pos - piece.pos
	_refresh_ghost_piece()


func _on_GameplaySettings_ghost_piece_changed(_value: bool) -> void:
	_refresh_ghost_piece()
