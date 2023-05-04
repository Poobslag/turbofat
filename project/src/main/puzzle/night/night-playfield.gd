extends Control
## Draws the playfield during night mode.
##
## This playfield is synchronized with the daytime playfield, and rendered over it. This involves synchronizing many
## different nodes for things like the playfield blocks, pickups, lights and effects. This node acts as a coordinator,
## delegating this synchronization to other nodes but telling them which nodes to synchronize with.

@export var source_playfield_path: NodePath: set = set_source_playfield_path

## playfield to synchronize with
var _source_playfield: Playfield

@onready var _pickups: NightPickups = $TileMapClip/Pickups
@onready var _playfield_fx: NightPlayfieldFx = $TileMapClip/PlayfieldFx
@onready var _star_poofs: NightStarPoofs = $TileMapClip/StarPoofs
@onready var _tile_map: NightPlayfieldTileMap = $TileMapClip/TileMap

func _ready() -> void:
	_refresh_playfield_path()


func set_source_playfield_path(new_source_playfield_path: NodePath) -> void:
	source_playfield_path = new_source_playfield_path
	_refresh_playfield_path()


## Connects playfield listeners.
func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and not source_playfield_path.is_empty()):
		return
	
	if _source_playfield:
		_source_playfield.line_deleted.disconnect(_tile_map._on_Playfield_line_deleted)
		_source_playfield.line_erased.disconnect(_tile_map._on_Playfield_line_erased)
		_source_playfield.line_inserted.disconnect(_tile_map._on_Playfield_line_inserted)
		_source_playfield.blocks_prepared.disconnect(_tile_map._on_Playfield_blocks_prepared)
		_source_playfield.before_line_cleared.disconnect(_star_poofs._on_Playfield_before_line_cleared)
	
	_source_playfield = get_node(source_playfield_path) if source_playfield_path else null
	
	_tile_map.source_tile_map = _source_playfield.tile_map
	_pickups.source_pickups = _source_playfield.pickups
	_playfield_fx.source_playfield_fx = _source_playfield.playfield_fx
	_star_poofs.source_tile_map = _source_playfield.tile_map
	
	_source_playfield.line_deleted.connect(_tile_map._on_Playfield_line_deleted)
	_source_playfield.line_erased.connect(_tile_map._on_Playfield_line_erased)
	_source_playfield.line_inserted.connect(_tile_map._on_Playfield_line_inserted)
	_source_playfield.blocks_prepared.connect(_tile_map._on_Playfield_blocks_prepared)
	_source_playfield.before_line_cleared.connect(_star_poofs._on_Playfield_before_line_cleared)
