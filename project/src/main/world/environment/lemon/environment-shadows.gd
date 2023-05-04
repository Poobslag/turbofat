@tool
class_name OutdoorShadows
extends Node2D

@export var obstacle_map_path: NodePath: set = set_obstacle_map_path

## Maps tile indexes to their grid size. This allows us to generate larger shadows for tiles which span multiple cells.
##
## This mapping is optional. Tile indexes which are absent will be given a 1x1 cell shadow.
##
## key: (int) tile index corresponding to a tile in the obstacle map
## value: (Rect2i) tile's grid size, in cells
@export var cell_shadow_mapping: Dictionary: set = set_cell_shadow_mapping

@onready var _obstacle_map_shadows := $ObstacleMapShadows
@onready var _creature_shadows := $CreatureShadows
@onready var _shadow_caster_shadows := $ShadowCasterShadows

func _ready() -> void:
	_refresh_obstacle_map_path()
	_refresh_cell_shadow_mapping()


func set_obstacle_map_path(new_obstacle_map_path: NodePath) -> void:
	obstacle_map_path = new_obstacle_map_path
	_refresh_obstacle_map_path()


func set_cell_shadow_mapping(new_cell_shadow_mapping: Dictionary) -> void:
	cell_shadow_mapping = new_cell_shadow_mapping
	_refresh_cell_shadow_mapping()


## Creates a shadow for a creature in a scene.
func create_creature_shadow(creature: Creature) -> void:
	_creature_shadows.create_shadow(creature)


## Creates a shadow for a 'shadow caster' in a scene.
##
## Shadow casters are objects which cast shadows. This doesn't include environment tiles and creatures, which have
## special shadow casting logic.
func create_shadow_caster_shadow(shadow_caster: Node2D) -> void:
	_shadow_caster_shadows.create_shadow(shadow_caster)


func _refresh_obstacle_map_path() -> void:
	if not is_inside_tree():
		return
	
	if obstacle_map_path:
		$ObstacleMapShadows.obstacle_map_path = $ObstacleMapShadows.get_path_to(get_node(obstacle_map_path))
	$ObstacleMapShadows.notify_property_list_changed()


func _refresh_cell_shadow_mapping() -> void:
	if not is_inside_tree():
		return
	$ObstacleMapShadows.cell_shadow_mapping = cell_shadow_mapping
	$ObstacleMapShadows.notify_property_list_changed()
