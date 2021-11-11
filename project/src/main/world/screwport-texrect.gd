extends TextureRect
## A TextureRect with a ViewportTexture which moves with the camera.
##
## Updates its own position to stay centered on the screen. Updates the Viewport's canvas_transform to keep its
## contents aligned with the world.
##
## 'screwport-texrect' is a portmanteau of ScreenViewportTextureRect. The class name seemed too long for something
## so simple.

## the viewport in our viewport texture
var _viewport: Viewport

## the root node of the viewport which we can rescale
var _viewport_root: Node2D

func _ready() -> void:
	if not texture or not texture.is_class("ViewportTexture") or not texture.viewport_path:
		push_error("ViewportTexture with Viewport must be set.")
		return
	
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")
	_viewport = get_tree().current_scene.get_node(texture.viewport_path)
	_viewport.connect("size_changed", self, "_on_Viewport_size_changed")
	_viewport_root = _viewport.get_node("ViewportRoot")
	
	_rescale_and_reposition_viewport()


func _process(_delta: float) -> void:
	if not _viewport:
		return
	
	# wait until the viewport updates to reposition the texture
	call_deferred("_reposition_viewport")


## Rescales our target viewport based on our parent viewport.
##
## Our parent viewport changes its size and scale based on the window size. When the window is resized, our parent
## viewport often adopts nonsensical sizes like (70,400, 123) which cause problems if we try and reuse them for our
## target viewport. So we rescale the target viewport's boundaries based on our parent's viewport transform to prevent
## throwing errors or causing memory issues.
func _rescale_and_reposition_viewport() -> void:
	# Adjust the viewport and texture size to match the scaled viewport size.
	# This should match OS.get_window_size() if we're being rendered in the main viewport.
	_viewport.size = get_viewport_rect().size * get_viewport_transform().get_scale()
	rect_size = _viewport.size
	
	# If our parent viewport is very large, we scale the items in the target viewport large, but rescale the texture
	# itself to be small. This cancels out so that items render at an appropriate size.
	_viewport_root.scale = get_viewport_transform().get_scale()
	rect_scale = Vector2(1.0, 1.0) / _viewport_root.scale
	
	# Immediately update our position. This prevents a drifting effect when resizing the window.
	_reposition_viewport()


## Updates the texture position and viewport origin to remain centered on the screen.
func _reposition_viewport() -> void:
	# align ourselves with the upper-left corner of the screen
	rect_position -= get_global_transform_with_canvas().origin
	# align the viewport with our new position
	_viewport.canvas_transform.origin = -rect_position / rect_scale


func _on_Viewport_size_changed() -> void:
	_rescale_and_reposition_viewport()
