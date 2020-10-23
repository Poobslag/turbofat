tool
class_name PackedSprite
extends Node2D
"""
A sprite whose contents are packed with Aseprite.

Aseprite can export packed and trimmed sprite sheets. These sprite sheets are much smaller than grid-based sheets
because they remove the whitespace for each frame. However, they require spatial data indicating the position of each
frame within the sprite sheet, as well as the position where it should be drawn.

This spatial data is available in a separate Aseprite json file.
"""

signal frame_changed

export (Texture) var texture: Texture

# the path of the Aseprite json file containing spatial data for the packed texture
export (String, FILE) var frame_data setget set_frame_data

# our width/height. affects our position when we're centered
export (Vector2) var rect_size := Vector2(100, 100) setget set_rect_size

export (int) var frame: int setget set_frame

export (bool) var centered: bool = true setget set_centered

export (Vector2) var offset: Vector2 setget set_offset

# the number of animation frames parsed from the Aseprite json file.
var frame_count setget ,get_frame_count

# Rect2 instances representing sprite sheet regions where each frame can be read
var _frame_src_rects: Array = []

# Rect2 instances representing screen regions where each frame should be drawn
var _frame_dest_rects: Array = []

"""
Sets the path of the Aseprite json file.

Loads the file and recalculates the frame data. Updates our region and offset based on the file contents.
"""
func set_frame_data(new_frame_data: String) -> void:
	frame_data = new_frame_data
	_frame_src_rects = ResourceCache.get_frame_src_rects(frame_data)
	_frame_dest_rects = ResourceCache.get_frame_dest_rects(frame_data)
	update()


func get_frame_count() -> int:
	return _frame_dest_rects.size()


func set_rect_size(new_rect_size: Vector2) -> void:
	rect_size = new_rect_size
	update()


func set_frame(new_frame: int) -> void:
	frame = new_frame
	update()
	emit_signal("frame_changed")


func set_centered(new_centered: bool) -> void:
	centered = new_centered
	update()


func set_offset(new_offset: Vector2) -> void:
	offset = new_offset
	update()


func _draw() -> void:
	if not _frame_dest_rects:
		# frame data not loaded
		return
	
	var rect: Rect2 = _frame_dest_rects[min(frame, _frame_dest_rects.size() - 1)]
	rect.position += offset
	if centered:
		rect.position -= rect_size * 0.5
	if frame < 0 or frame >= _frame_src_rects.size():
		push_warning("Frame data '%s' does not define a frame #%s" % [frame_data, frame])
	else:
		draw_texture_rect_region(texture, rect, _frame_src_rects[frame])
