extends Node
"""
Updates spatial parameters for the overworld goop shader. 

The goop shader defines a 'view_to_local' shader parameter which needs to be updated as the viewport's extents change,
so this node is responsible for updating it.
"""

# the tileset id of the tile whose shader needs to be updated
export (int) var goop_material_index: int

# the goop material whose shader needs to be updated
var _goop_material: ShaderMaterial

# The shader's view_to_local shader parameter. We cache this so that we don't need to set the shader parameter every
# frame.
var _view_to_local: Transform2D

onready var _tile_map: TileMap = get_parent()

func _ready() -> void:
	_goop_material = _tile_map.tile_set.tile_get_material(goop_material_index)
	_refresh_view_to_local()


func _process(_delta: float) -> void:
	# wait until the viewport updates to update the shader parameters
	call_deferred('_refresh_view_to_local')


"""
Updates the shader's view_to_local shader parameter.

This parameter will change whenever the tilemap moves visually in the viewport.
"""
func _refresh_view_to_local() -> void:
	var local_to_view: Transform2D = _tile_map.get_viewport_transform() * _tile_map.global_transform
	var new_view_to_local: Transform2D = local_to_view.affine_inverse()
	if new_view_to_local != _view_to_local:
		_view_to_local = new_view_to_local
		_goop_material.set_shader_param("view_to_local", _view_to_local)
