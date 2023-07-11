class_name PickupLevelChunkControl
extends Control
## UI component for a draggable chunk of level editor data containing a pickup.

export (Foods.BoxType) var box_type: int setget set_box_type

onready var _pickup := $Pickup

func _ready() -> void:
	_pickup.position = rect_size * 0.5
	$"../../Buttons/ChangeButton".connect("pressed", self, "_on_ChangeButton_pressed")


func set_box_type(new_box_type: int) -> void:
	box_type = new_box_type
	_refresh_pickup()


func get_drag_data(_pos: Vector2) -> Object:
	var data: PickupLevelChunk = PickupLevelChunk.new()
	data.box_type = box_type
	return data


func _refresh_pickup() -> void:
	_pickup.food_type = Foods.FOOD_TYPES_BY_BOX_TYPE[box_type][0]


func _on_ChangeButton_pressed() -> void:
	set_box_type((box_type + 1) % Foods.BoxType.size())
