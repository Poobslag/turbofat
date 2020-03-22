"""
A SmoothPath which renders an outline around another SmoothPath. Tracks the target path's curves and updates this
outline's curves accordingly.
"""
tool
extends SmoothPath

# the path of the SmoothPath which we're drawing an outline around
export (NodePath) var _parent_path_path: NodePath setget set_parent_path

# the SmoothPath which we're drawing an outline around
var _parent_path: SmoothPath

func set_parent_path(parent_path_path: NodePath) -> void:
	_parent_path_path = parent_path_path
	if is_inside_tree():
		_update_parent_field()

func _update_parent_field() -> void:
	if _parent_path_path != null:
		_parent_path = get_node(_parent_path_path)

func _ready() -> void:
	_update_parent_field()

func _process(delta: float) -> void:
	if _parent_path != null:
		curve = _parent_path.curve
		update()
