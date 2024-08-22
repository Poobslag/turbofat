extends BlockLevelChunkControl
## Level editor chunk which contains a snack/cake box.

export (Foods.BoxType) var box_type: int setget set_box_type

export (Vector2) var box_size: Vector2 = Vector2(3, 3) setget set_box_size

func set_box_type(new_box_type: int) -> void:
	box_type = new_box_type
	_refresh_tile_map()


func set_box_size(new_box_size: Vector2) -> void:
	box_size = new_box_size
	_refresh_tile_map()
	_refresh_scale()


func _refresh_tile_map() -> void:
	$TileMap.clear()
	$TileMap.build_box(Rect2(Vector2.ZERO, box_size), box_type)


func _on_RotateButton_pressed() -> void:
	if box_size.y >= 3:
		set_box_size(Vector2(box_size.y, box_size.x))


func _on_NextButton_pressed() -> void:
	set_box_type((box_type + 1) % Foods.BoxType.size())


func _on_PrevButton_pressed() -> void:
	set_box_type(int(fposmod(box_type - 1, Foods.BoxType.size())))
