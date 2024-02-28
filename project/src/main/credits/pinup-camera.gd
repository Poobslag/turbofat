extends Camera2D
## Camera which positions itself to accomodate creatures of different size.

## Amount of empty space over the creature's head.
export (float, 0, 1) var headroom := 1.0 setget set_headroom
export (NodePath) var creature_path: NodePath

## if 'true', the target camera position needs to be recalculated because something about the customer changed
var _position_dirty := true

onready var _creature := get_node(creature_path)

func _physics_process(_delta: float) -> void:
	if _position_dirty:
		_refresh_position()


func set_headroom(new_headroom: float) -> void:
	headroom = new_headroom
	_position_dirty = true


## Updates the target camera position based on the creature's position and the 'headroom' property.
func _refresh_position() -> void:
	position = _creature.get_node("MouthHook").position
	position += lerp(Vector2(0, 0), Vector2(0, -45), headroom)
	
	_position_dirty = false
