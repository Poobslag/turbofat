extends Control
## Draws puzzle 'critters', little monsters which affect the puzzle.

export (NodePath) var playfield_path: NodePath setget set_playfield_path
export (NodePath) var piece_manager_path: NodePath setget set_piece_manager_path

## Draws carrots, puzzle critters which rocket up the screen, blocking the player's vision.
onready var _carrots: Carrots = $Carrots

## Draws moles, puzzle critters which dig up star seeds for the player.
onready var _moles: Moles = $Moles

## Draws onions, puzzle critters which darken things making it hard to see.
onready var _onions: Onions = $Onions

## Draws sharks, puzzle critters which eat pieces.
onready var _sharks: Sharks = $Sharks

## Draws spears, puzzle critters which add veggie blocks from the sides.
onready var _spears: Spears = $Spears

## Draws tomatoes, puzzle critters which indicate lines which can't be cleared.
onready var _tomatoes: Tomatoes = $Tomatoes

onready var _cell_critter_manager: CellCritterManager = $CellCritterManager

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
	
	_cell_critter_manager.playfield_path = _cell_critter_manager.get_path_to(get_node(playfield_path))
	
	_carrots.playfield_path = _carrots.get_path_to(get_node(playfield_path))
	_moles.playfield_path = _moles.get_path_to(get_node(playfield_path))
	_onions.playfield_path = _onions.get_path_to(get_node(playfield_path))
	_sharks.playfield_path = _sharks.get_path_to(get_node(playfield_path))
	_spears.playfield_path = _spears.get_path_to(get_node(playfield_path))
	_tomatoes.playfield_path = _tomatoes.get_path_to(get_node(playfield_path))


func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and _moles):
		return
	
	_cell_critter_manager.piece_manager_path = _cell_critter_manager.get_path_to(get_node(piece_manager_path))
	
	_moles.piece_manager_path = _moles.get_path_to(get_node(piece_manager_path))
	_sharks.piece_manager_path = _sharks.get_path_to(get_node(piece_manager_path))
	_spears.piece_manager_path = _spears.get_path_to(get_node(piece_manager_path))


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	visible = not value
