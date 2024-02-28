tool
class_name EnvironmentShadows
extends Node2D

export (NodePath) var obstacles_path: NodePath setget set_obstacles_path

## Maps tile indexes to their grid size. This allows us to generate larger shadows for tiles which span multiple cells.
##
## This mapping is optional. Tile indexes which are absent will be given a 1x1 cell shadow.
##
## key: (int) tile index corresponding to a tile in the obstacle map
## value: (Rect2) rectangle which measures tile's grid size, in cells
export (Dictionary) var cell_shadow_mapping setget set_cell_shadow_mapping

onready var _creature_shadows := $CreatureShadows
onready var _shadow_caster_shadows := $ShadowCasterShadows
onready var _obstacle_map_shadows := $ObstacleMapShadows

func _ready() -> void:
	_refresh_obstacles_path()
	_refresh_cell_shadow_mapping()


func set_obstacles_path(new_obstacles_path: NodePath) -> void:
	obstacles_path = new_obstacles_path
	_refresh_obstacles_path()


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


func _refresh_obstacles_path() -> void:
	if not is_inside_tree():
		return
	
	# assign the CreatureShadows.CreatureParentPath property
	if obstacles_path:
		var obstacles := get_node(obstacles_path)
		_creature_shadows.creature_parent_path = _creature_shadows.get_path_to(obstacles)
		_creature_shadows.property_list_changed_notify()
	
	# assign the ObstacleMapShadows.ObstacleMapPath property
	if obstacles_path and get_node(obstacles_path).has_node("ObstacleMap"):
		var obstacle_map := get_node(obstacles_path).get_node("ObstacleMap")
		_obstacle_map_shadows.obstacle_map_path = _obstacle_map_shadows.get_path_to(obstacle_map)
		_obstacle_map_shadows.property_list_changed_notify()


func _refresh_cell_shadow_mapping() -> void:
	if not is_inside_tree():
		return
	_obstacle_map_shadows.cell_shadow_mapping = cell_shadow_mapping
	_obstacle_map_shadows.property_list_changed_notify()
