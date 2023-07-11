class_name NightSquishFx
extends Control
## Draws visual effects for a squish move during night mode.
##
## These visual effects are synchronized with the daytime effects, and rendered over them.

## Path to the tilemap containing the active piece shown during night mode.
export (NodePath) var onion_tile_map_path: NodePath setget set_onion_tile_map_path

## visual effects to synchronize with
var source_squish_fx: SquishFx setget set_source_squish_fx

## tilemap containing the active piece shown during night mode
onready var _squish_map: NightPuzzleTileMap = $SquishMap
onready var _sweat_drops: Particles2D = $SweatDrops

## tilemap containing the active piece shown during night mode.
onready var _onion_tile_map: NightPuzzleTileMap = get_node(onion_tile_map_path)

func _ready() -> void:
	_refresh_source_squish_fx()
	_refresh_onion_tile_map_path()


func set_source_squish_fx(new_source_squish_fx: SquishFx) -> void:
	source_squish_fx = new_source_squish_fx
	_refresh_source_squish_fx()


func set_onion_tile_map_path(new_onion_tile_map_path: NodePath) -> void:
	onion_tile_map_path = new_onion_tile_map_path
	_refresh_onion_tile_map_path()


func _physics_process(_delta: float) -> void:
	# synchronize sweat drops
	_sweat_drops.position = source_squish_fx.sweat_drops.position
	_sweat_drops.emitting = source_squish_fx.sweat_drops.emitting
	_sweat_drops.lifetime = source_squish_fx.sweat_drops.lifetime
	
	# synchronize active piece
	_onion_tile_map.position = _onion_tile_map.source_tile_map.position
	_onion_tile_map.whiteness = _onion_tile_map.source_tile_map.whiteness


func _refresh_source_squish_fx() -> void:
	if not source_squish_fx:
		return
	
	_squish_map.source_tile_map = source_squish_fx.squish_map


func _refresh_onion_tile_map_path() -> void:
	if not is_inside_tree():
		return
	
	_onion_tile_map = get_node(onion_tile_map_path)
