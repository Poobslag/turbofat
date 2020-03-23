"""
A sprite which renders an outline around another sprite. Tracks the target sprite's movement and updates this
outline's position accordingly.
"""
tool
class_name OutlineSprite
extends Sprite

# the path of the sprite which we're drawing an outline around
export (NodePath) var _parent_path: NodePath setget set_parent

# the sprite which we're drawing an outline around
var _parent: Sprite

func set_parent(parent_path: NodePath) -> void:
	_parent_path = parent_path
	if is_inside_tree():
		_update_parent_field()

"""
Reload the parent field based on the NodePath.
"""
func _update_parent_field() -> void:
	if _parent_path == null:
		_parent = null
	else:
		_parent = get_node(_parent_path)

func _ready() -> void:
	_update_parent_field()

func _process(_delta: float) -> void:
	position = _parent.position
	scale = _parent.scale
