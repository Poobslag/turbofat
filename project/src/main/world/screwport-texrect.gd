extends TextureRect
"""
A TextureRect with a ViewportTexture which moves with the camera.

Updates its own position to stay centered on the screen. Updates the Viewport's canvas_transform to keep its contents
aligned with the world.

'screwport-texrect' is a portmanteau of ScreenViewportTextureRect. The class name seemed too long for something
so simple.
"""

# the viewport in our viewport texture
var _viewport: Viewport

func _ready() -> void:
	if not texture or not texture.is_class("ViewportTexture") or not texture.viewport_path:
		push_error("ViewportTexture with Viewport must be set.")
		return
	
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")
	_viewport = get_tree().current_scene.get_node(texture.viewport_path)
	_viewport.connect("size_changed", self, "_on_Viewport_size_changed")
	_refresh_viewport_size()


func _process(_delta: float) -> void:
	if not _viewport:
		return

	# align ourselves with the upper-left corner of the screen
	rect_position -= get_global_transform_with_canvas().origin
	# align the viewport with our new position
	_viewport.canvas_transform.origin = -rect_position / rect_scale


func _refresh_viewport_size() -> void:
	_viewport.size = get_viewport_rect().size / rect_scale
	rect_size = _viewport.size


func _on_Viewport_size_changed() -> void:
	_refresh_viewport_size()
