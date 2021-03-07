extends Node2D
"""
Manages the overworld's ground textures, including the goop texture and goop viewports.
"""

onready var _screwport_texrect: TextureRect = $ScrewportTexrect
onready var _goop_texture_rect: ColorRect = $GoopViewport/GoopTextureRect
onready var _goop_viewport: Viewport = $GoopViewport

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")
	_refresh_goop_control_size()


func _process(_delta: float) -> void:
	# scroll the goop and ground textures as the camera scrolls
	var transform: Transform2D = get_canvas_transform()
	var new_offset := transform.get_origin() / (get_viewport().get_visible_rect().size * transform.get_scale())
	_goop_texture_rect.material.set_shader_param("offset", new_offset)
	_screwport_texrect.material.set_shader_param("red_texture_offset", Vector2(1, -1) * new_offset)


"""
Scales the goop texture based on the viewport size.
"""
func _refresh_goop_control_size() -> void:
	if not is_inside_tree():
		return
	
	var new_size: Vector2 = _screwport_texrect.get_viewport_rect().size / _screwport_texrect.rect_scale
	_goop_texture_rect.material.set_shader_param("squash_factor", Vector2(new_size.x * 0.5 / new_size.y, 1.0))
	_screwport_texrect.material.set_shader_param("green_texture_scale", new_size / _goop_viewport.size)


func _on_Viewport_size_changed() -> void:
	_refresh_goop_control_size()
