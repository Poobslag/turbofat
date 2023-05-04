@tool
class_name PackedSprite
extends Node2D
## Sprite whose contents are packed with Aseprite.
##
## Aseprite can export packed and trimmed sprite sheets. These sprite sheets are much smaller than grid-based sheets
## because they remove the whitespace for each frame. However, they require spatial data indicating the position of
## each frame within the sprite sheet, as well as the position where it should be drawn.
##
## This spatial data is available in a separate Aseprite json file.

signal frame_changed

@export var texture: Texture2D

## path of the Aseprite json file containing spatial data for the packed texture
@export_file var frame_data : set = set_frame_data

## our width/height. affects our position when we're centered
@export var size := Vector2(100, 100): set = set_rect_size

@export var frame: int: set = set_frame

@export var centered: bool = true: set = set_centered

@export var offset: Vector2: set = set_offset

## number of animation frames parsed from the Aseprite json file.
var frame_count : get = get_frame_count

## Rect2 instances representing sprite sheet regions where each frame can be read
var _frame_src_rects := []

## Rect2 instances representing screen regions where each frame should be drawn
var _frame_dest_rects := []

## Sets the path of the Aseprite json file.
##
## Loads the file and recalculates the frame data. Updates our region and offset based on the file contents.
func set_frame_data(new_frame_data: String) -> void:
	frame_data = new_frame_data
	if Engine.is_editor_hint():
		_load_rects_from_json()
	else:
		_frame_src_rects = ResourceCache.get_frame_src_rects(frame_data)
		_frame_dest_rects = ResourceCache.get_frame_dest_rects(frame_data)

		if _frame_src_rects.is_empty():
			# if the ResourceCache is unavailable (possibly during demos) we load things the slow way
			_load_rects_from_json()
	queue_redraw()


func get_frame_count() -> int:
	return _frame_dest_rects.size()


func set_rect_size(new_rect_size: Vector2) -> void:
	if size == new_rect_size:
		return
	size = new_rect_size
	queue_redraw()


func set_frame(new_frame: int) -> void:
	if frame == new_frame:
		return
	frame = new_frame
	queue_redraw()
	emit_signal("frame_changed")


func set_centered(new_centered: bool) -> void:
	if centered == new_centered:
		return
	centered = new_centered
	queue_redraw()


func set_offset(new_offset: Vector2) -> void:
	if offset == new_offset:
		return
	offset = new_offset
	queue_redraw()


func _draw() -> void:
	if _frame_dest_rects.is_empty():
		# frame data not loaded
		return
	
	var rect: Rect2 = _frame_dest_rects[min(frame, _frame_dest_rects.size() - 1)]
	rect.position += offset
	if centered:
		rect.position -= size * 0.5
	if frame < 0 or frame >= _frame_src_rects.size():
		push_warning("Frame data '%s' does not define a frame #%s" % [frame_data, frame])
	else:
		draw_texture_rect_region(texture, rect, _frame_src_rects[frame])


## Loads sprite sheet regions and screen regions from a json file.
##
## This is slow and should only be used for editor tools where the ResourceCache is inaccessible.
func _load_rects_from_json() -> void:
	if not frame_data:
		return
	
	# parse json
	var json: String = FileUtils.get_file_as_text(frame_data)
	var json_root: Dictionary = JSON.parse_string(json)
	if not json_root.has("frames"):
		# the specified json resource is not an Aseprite json resource; do nothing
		return
	
	# extract frame data from json
	var json_frames: Array
	if json_root["frames"] is Array:
		json_frames = json_root["frames"]
	elif json_root["frames"] is Dictionary:
		json_frames = json_root["frames"].values()
	else:
		push_warning("Invalid frame data in file '%s'" % frame_data)
	
	# store json frame data as Rect2 instances
	_frame_src_rects.clear()
	_frame_dest_rects.clear()
	for json_frame in json_frames:
		_frame_src_rects.append(Utils.json_to_rect2(json_frame["frame"]))
		_frame_dest_rects.append(Utils.json_to_rect2(json_frame["spriteSourceSize"]))
