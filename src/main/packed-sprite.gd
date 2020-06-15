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

func _ready() -> void:
	_load_frame_data()


"""
Sets the path of the Aseprite json file.

Loads the file and recalculates the frame data. Updates our region and offset based on the file contents.
"""
func set_frame_data(new_frame_data: String) -> void:
	frame_data = new_frame_data
	_load_frame_data()


func get_frame_count() -> int:
	return _frame_dest_rects.size()


func set_rect_size(new_rect_size: Vector2) -> void:
	rect_size = new_rect_size
	update()


func set_frame(new_frame: int) -> void:
	frame = new_frame
	update()


func set_centered(new_centered: bool) -> void:
	centered = new_centered
	update()


func set_offset(new_offset: Vector2) -> void:
	offset = new_offset
	update()


static func json_to_rect2(json: Dictionary) -> Rect2:
	return Rect2(json.x, json.y, json.w, json.h)


"""
Loads the Aseprite json file.

Stores the offset and region_rect for each frame.
"""
func _load_frame_data() -> void:
	if not frame_data:
		return
	
	# read json frame data from resource
	var json: String = get_file_as_text(frame_data)
	var json_root: Dictionary = parse_json(json)
	var json_frames: Array
	if json_root["frames"] is Array:
		json_frames = json_root["frames"]
	elif json_root["frames"] is Dictionary:
		json_frames = json_root["frames"].values()
	
	# store json frame data as Rect2 instances
	_frame_src_rects.clear()
	_frame_dest_rects.clear()
	for json_frame in json_frames:
		_frame_src_rects.append(json_to_rect2(json_frame["frame"]))
		_frame_dest_rects.append(json_to_rect2(json_frame["spriteSourceSize"]))


func _draw() -> void:
	if not _frame_dest_rects:
		# frame data not loaded
		return
	
	var rect: Rect2 = _frame_dest_rects[min(frame, _frame_dest_rects.size() - 1)]
	rect.position += offset
	if centered:
		rect.position -= rect_size * 0.5
	draw_texture_rect_region(texture, rect, _frame_src_rects[frame])


static func get_file_as_text(path: String) -> String:
	var text: String
	var f := File.new()
	if not f.file_exists(path):
		push_error("File not found: %s" % path)
	else:
		f.open(path, f.READ)
		text = f.get_as_text()
		f.close()
	return text
