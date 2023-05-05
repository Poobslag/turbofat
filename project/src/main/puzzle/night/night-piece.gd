extends Control
## Displays the active pieces to the player during night mode.
##
## This piece is synchronized with the daytime piece, and rendered over it.

## The path to the daytime piece manager to synchronize with.
export (NodePath) var piece_manager_path: NodePath setget set_piece_manager_path

## daytime piece manager to synchronize with
var _piece_manager: PieceManager

onready var _tile_map: NightPuzzleTileMap = $TileMap
onready var _squish_fx: NightSquishFx = $SquishFx

func _ready() -> void:
	_refresh_piece_manager_path()


func set_piece_manager_path(new_piece_manager_path: NodePath) -> void:
	piece_manager_path = new_piece_manager_path
	_refresh_piece_manager_path()


## Connects piece manager listeners.
func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and not piece_manager_path.is_empty()):
		return
	
	_piece_manager = get_node(piece_manager_path) if piece_manager_path else null
	
	_tile_map.source_tile_map = _piece_manager.tile_map
	_squish_fx.source_squish_fx = _piece_manager.get_squish_fx()
