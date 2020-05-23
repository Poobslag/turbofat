extends LevelChunkControl
"""
A level editor chunk which contains a snack/cake box.
"""

export (Playfield.BoxInt) var _box_type: int setget set_box_type

export (Vector2) var _box_size: Vector2 = Vector2(3, 3) setget set_box_size

func _ready() -> void:
	$"../RotateButton".connect("pressed", self, "_on_RotateButton_pressed")
	$"../ChangeButton".connect("pressed", self, "_on_ChangeButton_pressed")


func set_box_type(box_type: int) -> void:
	_box_type = box_type
	_refresh_tilemap()


func set_box_size(box_size: Vector2) -> void:
	_box_size = box_size
	_refresh_tilemap()
	_refresh_scale()


func _refresh_tilemap() -> void:
	$TileMap.clear()
	$TileMap.make_box(0, 0, _box_size.x, _box_size.y, _box_type)


func _on_RotateButton_pressed() -> void:
	if _box_size.y >= 3:
		set_box_size(Vector2(_box_size.y, _box_size.x))


func _on_ChangeButton_pressed() -> void:
	set_box_type((_box_type + 1) % Playfield.BoxInt.size())
