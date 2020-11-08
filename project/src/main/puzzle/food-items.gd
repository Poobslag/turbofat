extends Node2D
"""
Food items which appear when the player clears boxes in puzzle mode.
"""

export (NodePath) var playfield_path: NodePath
export (PackedScene) var FoodScene: PackedScene

onready var _playfield: Playfield = get_node(playfield_path)
onready var _puzzle_tile_map := _playfield.tile_map

# relative position of the PuzzleTileMap, used for positioning food
onready var _puzzle_tile_map_position: Vector2 = _puzzle_tile_map.get_global_transform().origin \
		- get_global_transform().origin

"""
Adds a food item in the specified cell.
"""
func add_food_item(cell: Vector2, food_type: int) -> void:
	if cell.y < PuzzleTileMap.FIRST_VISIBLE_ROW:
		return
	
	var food_item: FoodItem = FoodScene.instance()
	food_item.frame = food_type
	food_item.position = _puzzle_tile_map.map_to_world(cell)
	food_item.position += _puzzle_tile_map.cell_size * Vector2(0.5, 0.5)
	food_item.position *= _puzzle_tile_map.scale / $TextureRect.rect_scale
	food_item.position += _puzzle_tile_map_position / $TextureRect.rect_scale
	food_item.base_scale = _puzzle_tile_map.scale / $TextureRect.rect_scale
	$Viewport.add_child(food_item)


func _on_StarSeeds_food_spawned(cell: Vector2, food_type: int) -> void:
	add_food_item(cell, food_type)
