extends BlockLevelChunkControl
## Level editor chunk which contains a snack/cake box.

@export var box_type: Foods.BoxType: set = set_box_type

@export var box_size: Vector2i = Vector2i(3, 3): set = set_box_size

func _ready() -> void:
	super()
	$"../../Buttons/RotateButton".pressed.connect(_on_RotateButton_pressed)
	$"../../Buttons/ChangeButton".pressed.connect(_on_ChangeButton_pressed)


func set_box_type(new_box_type: Foods.BoxType) -> void:
	box_type = new_box_type
	_refresh_tile_map()


func set_box_size(new_box_size: Vector2i) -> void:
	box_size = new_box_size
	_refresh_tile_map()
	_refresh_scale()


func _refresh_tile_map() -> void:
	$TileMap.clear()
	$TileMap.build_box(Rect2i(Vector2i.ZERO, box_size), box_type)


func _on_RotateButton_pressed() -> void:
	if box_size.y >= 3:
		set_box_size(Vector2i(box_size.y, box_size.x))


func _on_ChangeButton_pressed() -> void:
	set_box_type((box_type + 1) % Foods.BoxType.size())
