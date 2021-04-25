tool
extends TileMap
"""
Updates the goop ground map shader with its view_to_local shader parameter.

The view_to_local shader parameter changes whenever the tilemap moves visually in the viewport, so we need to update
it whenever the camera moves.
"""

var _goop_material: ShaderMaterial = tile_set.tile_get_material(0)

# The shader's view_to_local shader parameter. We cache this so that we don't need to set a shader parameter every
# frame.
var _view_to_local: Transform2D

func _ready() -> void:
	_refresh_view_to_local()


func _process(_delta: float) -> void:
	_refresh_view_to_local()


"""
Updates the shader's view_to_local shader parameter.

This parameter will change whenever the tilemap moves visually in the viewport.
"""
func _refresh_view_to_local() -> void:
	var local_to_view: Transform2D = get_viewport_transform() * global_transform
	var new_view_to_local: Transform2D = local_to_view.affine_inverse()
	if new_view_to_local != _view_to_local:
		_view_to_local = new_view_to_local
		_goop_material.set_shader_param("view_to_local", _view_to_local)
