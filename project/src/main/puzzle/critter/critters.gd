extends Control
## Draws puzzle 'critters', little monsters which affect the puzzle.

export (NodePath) var playfield_path: NodePath setget set_playfield_path
export (NodePath) var piece_manager_path: NodePath setget set_piece_manager_path

## Draws moles, puzzle critters which dig up star seeds for the player.
onready var _moles: Moles = $Moles

## Draws onions, puzzle critters which darken things making it hard to see.
onready var _onions: Onions = $Onions

# Draws carrots, puzzle critters which rocket up the screen, blocking the player's vision.
onready var _carrots: Carrots = $Carrots

func _ready() -> void:
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")
	_refresh_playfield_path()
	_refresh_piece_manager_path()


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()


func set_piece_manager_path(new_piece_manager_path: NodePath) -> void:
	piece_manager_path = new_piece_manager_path
	_refresh_piece_manager_path()


func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and _moles):
		return
	
	_moles.playfield_path = _moles.get_path_to(get_node(playfield_path))
	_onions.playfield_path = _onions.get_path_to(get_node(playfield_path))
	_carrots.playfield_path = _carrots.get_path_to(get_node(playfield_path))


func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and _moles):
		return
	
	_moles.piece_manager_path = _moles.get_path_to(get_node(piece_manager_path))


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	visible = not value
