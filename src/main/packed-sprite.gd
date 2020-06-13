class_name PackedSprite
extends Sprite
"""
A sprite whose contents are packed with Aseprite.

Aseprite can export packed and trimmed sprite sheets. These sprite sheets are much smaller than grid-based sheets
because they remove the whitespace for each frame. However, they require spatial data indicating the position of each
frame within the sprite sheet, as well as the position where it should be drawn.

This spatial data is available in a separate Aseprite json file.
"""

# the path of the Aseprite json file containing spatial data for the packed texture
export (String, FILE) var json_path setget set_json_path

# The frame currently being shown. This is independent of the Sprite.frame property because Godot has business rules
# governing the behavior of hframes, vframes, and frame. This class is unable to conform to those business rules.
export (int) var json_frame := 0 setget set_json_frame

# Vector2 instances parsed from the Aseprite json file containing offsets for each frame
var _frame_offsets: Array = []

# Rect2 instances parsed from the Aseprite json file containing region_rects for each frame
var _frame_region_rects: Array = []

func _ready() -> void:
	region_enabled = true
	centered = false
	hframes = 1
	vframes = 1
	frame = 0
	
	_load_frame_data()
	_refresh_region()


"""
Returns the number of animation frames parsed from the Aseprite json file.
"""
func get_json_frame_count() -> int:
	return _frame_region_rects.size()


"""
Sets the currently displayed frame.

Updates our region and offset based on the contents of the Aseprite json file.
"""
func set_json_frame(new_json_frame: int) -> void:
	json_frame = new_json_frame
	_refresh_region()


"""
Sets the path of the Aseprite json file.

Loads the file and recalculates the frame data. Updates our region and offset based on the file contents.
"""
func set_json_path(new_json_path: String) -> void:
	json_path = new_json_path
	_load_frame_data()
	_refresh_region()


"""
Loads the Aseprite json file.

Stores the offset and region_rect for each frame.
"""
func _load_frame_data() -> void:
	if not json_path:
		return
	
	_frame_offsets.clear()
	_frame_region_rects.clear()
	var json: String = FileUtils.get_file_as_text(json_path)
	var json_items: Dictionary = parse_json(json)
	var frame_datas: Array
	if json_items["frames"] is Array:
		frame_datas = json_items["frames"]
	elif json_items["frames"] is Dictionary:
		frame_datas = json_items["frames"].values()
	for frame_data in frame_datas:
		var frame_dict: Dictionary = frame_data["frame"]
		_frame_region_rects.append(Rect2(frame_dict.x, frame_dict.y, frame_dict.w, frame_dict.h))
		
		var sprite_source_dict: Dictionary = frame_data["spriteSourceSize"]
		_frame_offsets.append(Vector2(sprite_source_dict.x, sprite_source_dict.y))


"""
Refreshes the currently displayed region_rect and offset.

The region_rect and offset are selected based on the current json_frame, and calculated based on the contents of the
Aseprite json file.
"""
func _refresh_region() -> void:
	if not _frame_region_rects:
		return
	
	region_rect = _frame_region_rects[json_frame]
	offset = _frame_offsets[json_frame]
