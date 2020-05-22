class_name TemplateVeg
extends Control
"""
A level editor vegetable block.
"""

func get_drag_data(_pos: Vector2) -> Object:
	var cell: EditorCell = EditorCell.new()
	cell.tile = 2 # veg
	cell.autotile_coord = Vector2(randi() % 18, randi() % 4)
	return cell
