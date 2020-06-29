extends LevelChunkControl
"""
A level editor chunk which contains a snack/cake box.
"""

export (PuzzleTileMap.BoxInt) var box_type: int setget set_box_type

export (Vector2) var box_size: Vector2 = Vector2(3, 3) setget set_box_size

func _ready() -> void:
	$"../../Buttons/RotateButton".connect("pressed", self, "_on_RotateButton_pressed")
	$"../../Buttons/ChangeButton".connect("pressed", self, "_on_ChangeButton_pressed")


func set_box_type(new_box_type: int) -> void:
	box_type = new_box_type
	_refresh_tilemap()


func set_box_size(new_box_size: Vector2) -> void:
	box_size = new_box_size
	_refresh_tilemap()
	_refresh_scale()


func _refresh_tilemap() -> void:
	$TileMap.clear()
	$TileMap.build_box(0, 0, box_size.x, box_size.y, box_type)


func _on_RotateButton_pressed() -> void:
	if box_size.y >= 3:
		set_box_size(Vector2(box_size.y, box_size.x))


func _on_ChangeButton_pressed() -> void:
	set_box_type((box_type + 1) % PuzzleTileMap.BoxInt.size())
