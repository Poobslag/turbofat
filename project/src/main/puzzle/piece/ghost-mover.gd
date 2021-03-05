extends Node
"""
Moves the ghost piece when the piece or playfield changes.
"""

export (NodePath) var tile_map_path: NodePath

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)

func _on_Dropper_hard_drop_target_pos_changed(piece: ActivePiece, hard_drop_target_pos: Vector2) -> void:
	if PlayerData.gameplay_settings.ghost_piece:
		_tile_map.set_ghost_shadow_offset(hard_drop_target_pos - piece.pos)
