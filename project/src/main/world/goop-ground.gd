extends Node2D
"""
Manages the overworld's ground textures, including the goop texture and goop viewports.
"""

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")
	_refresh_goop_control_size()


func _process(_delta: float) -> void:
	# scroll the goop and ground textures as the camera scrolls
	var transform: Transform2D = get_canvas_transform()
	var new_offset := transform.get_origin() / (get_viewport().get_visible_rect().size * transform.get_scale())
	$GoopViewport/GoopTextureRect.material.set_shader_param("offset", new_offset)
	$ScrewportTexrect.material.set_shader_param("red_texture_offset", Vector2(1, -1) * new_offset)


"""
Scales the goop texture based on the viewport size.
"""
func _refresh_goop_control_size() -> void:
	var new_size: Vector2 = $ScrewportTexrect.get_viewport_rect().size / $ScrewportTexrect.rect_scale
	$GoopViewport/GoopTextureRect.material.set_shader_param("squash_factor",
			Vector2(new_size.x * 0.5 / new_size.y, 1.0))
	$ScrewportTexrect.material.set_shader_param("green_texture_scale",
			new_size / $GoopViewport.size)


func _on_Viewport_size_changed() -> void:
	_refresh_goop_control_size()
