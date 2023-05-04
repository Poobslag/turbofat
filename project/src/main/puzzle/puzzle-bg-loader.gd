extends Control
## Updates the puzzle background.

## Path to the scene resource defining a puzzle background for levels which do not specify an
## background, or which specify an invalid background
const DEFAULT_BG_PATH := "res://src/main/puzzle/WoodBg.tscn"

## Shadow color for levels which do not specify a color, or which specify an invalid color
const DEFAULT_BG_COLOR := Color("582612")

## key: (String) an Environment name which appears in the json definitions
## value: (String) Path to the scene resource defining a puzzle background for that environment
const BG_PATH_BY_NAME := {
	"lemon": "res://src/main/puzzle/LemonBg.tscn",
}

## key: (String) an Environment name which appears in the json definitions
## value: (Color) Color for shadows in the puzzle scene
const BG_SHADOW_COLOR_BY_NAME := {
	"lemon": Color("3d291f"),
}

## Nodes showing shadows to recolor when the background changes.
@export var shadow_paths: Array[NodePath]

func _ready() -> void:
	_remove_bg()
	_add_bg()
	_refresh_shadow_color()


func _remove_bg() -> void:
	if not has_node("Bg"):
		return
	
	var bg := get_node("Bg")
	bg.queue_free()
	remove_child(bg)


func _add_bg() -> void:
	var bg_scene_path: String = BG_PATH_BY_NAME.get(CurrentLevel.puzzle_environment_name, DEFAULT_BG_PATH)
	var bg_scene: PackedScene = load(bg_scene_path)
	var bg := bg_scene.instantiate()
	bg.name = "Bg"
	add_child(bg)


func _refresh_shadow_color() -> void:
	var shadow_color: Color = BG_SHADOW_COLOR_BY_NAME.get(CurrentLevel.puzzle_environment_name, DEFAULT_BG_COLOR)
	for shadow_path in shadow_paths:
		var shadow_node: Node = get_node(shadow_path)
		if "color" in shadow_node:
			shadow_node.color = shadow_color
