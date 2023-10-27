extends Control
## Swaps the progress board map scene based on the current region.

## Default map scene to use if none is defined for the current region.
const DEFAULT_MAP_SCENE_PATH := "res://src/main/career/ui/ProgressBoardMapMarsh.tscn"

## key: (String) region id
## value: (String) path for a progress board map scene.
const MAP_SCENE_PATHS_BY_REGION_ID := {
	"lemon": "res://src/main/career/ui/ProgressBoardMapLemon.tscn",
	"lemon_2": "res://src/main/career/ui/ProgressBoardMapLemon2.tscn",
	"marsh": "res://src/main/career/ui/ProgressBoardMapMarsh.tscn",
	"poki": "res://src/main/career/ui/ProgressBoardMapPoki.tscn",
	"sand": "res://src/main/career/ui/ProgressBoardMapSand.tscn",
	"lava": "res://src/main/career/ui/ProgressBoardMapLava.tscn",
}

export (String) var region_id: String setget set_region_id

## Exposes the map's path2d for the progress board trail.
var path2d: Path2D

func _ready() -> void:
	_refresh()


func set_region_id(new_region_id: String) -> void:
	region_id = new_region_id
	_refresh()


## Swaps the progress board map scene based on the current region.
func _refresh() -> void:
	# remove old map node from tree
	var old_map_node: Node = get_node_or_null("Map")
	if old_map_node:
		remove_child(old_map_node)
		old_map_node.queue_free()
	
	# instance new map node
	var map_scene_path: String = MAP_SCENE_PATHS_BY_REGION_ID.get(region_id, DEFAULT_MAP_SCENE_PATH)
	var map_scene: PackedScene = load(map_scene_path)
	var map_node: Control = map_scene.instance()
	
	# add new map node to tree
	map_node.margin_right = 0
	map_node.margin_bottom = 0
	map_node.name = "Map"
	add_child(map_node)
	path2d = map_node.get_node("Path2D")
