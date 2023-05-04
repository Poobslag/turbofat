class_name PickupLevelChunkControl
extends Control
## UI component for a draggable chunk of level editor data containing a pickup.

@export var box_type: Foods.BoxType: set = set_box_type

@onready var _pickup := $Pickup

func _ready() -> void:
	_pickup.position = size * 0.5
	$"../../Buttons/ChangeButton".pressed.connect(_on_ChangeButton_pressed)


func set_box_type(new_box_type: Foods.BoxType) -> void:
	box_type = new_box_type
	_refresh_pickup()


func _get_drag_data(_pos: Vector2) -> Variant:
	var data: PickupLevelChunk = PickupLevelChunk.new()
	data.box_type = box_type
	return data


func _refresh_pickup() -> void:
	_pickup.food_type = Foods.FOOD_TYPES_BY_BOX_TYPES[box_type][0]


func _on_ChangeButton_pressed() -> void:
	set_box_type((box_type + 1) % Foods.BoxType.size())
