class_name RectFitLabel
extends Label
"""
This label changes its size dynamically based on the amount of text it needs to display. It chooses the smallest size
where the text does not overrun its boundaries.
"""

# When calculating how much text we can accommodate, there is a 3 pixel gap between each row.
const FONT_GAP := 3

# Different sizes to try. Should be ordered from smallest to largest.
export(Array, Vector2) var sizes := [] setget set_sizes

var chosen_size_index := -1 setget set_chosen_size_index

func _ready() -> void:
	pick_smallest_size()
	
	# this class requires both autowrap and max_lines_visible to be set
	autowrap = true
	max_lines_visible = max(1, max_lines_visible)


"""
Sets the label's size to the smallest size which will accommodate its text.

If the label's text is modified this should be called manually. This class cannot respond to text changes or override
set_text because of Godot #29390 (https://github.com/godotengine/godot/issues/29390)
"""
func pick_smallest_size() -> void:
	for i in range(sizes.size()):
		# start with the smallest size, and try larger and larger sizes
		set_chosen_size_index(i)
		if _lines_fit():
			# this size is large enough to accommodate all of the text
			break


func set_chosen_size_index(new_index: int) -> void:
	chosen_size_index = new_index
	
	# godot cannot shrink labels containing text. temporarily empty the label
	var old_text := text
	text = ""
	
	# Workaround for Godot #19329; keeping a control centered in its parent is a hassle
	# https://github.com/godotengine/godot/issues/19329
	margin_left = -sizes[chosen_size_index].x / 2
	margin_right = sizes[chosen_size_index].x / 2
	margin_top = -sizes[chosen_size_index].y / 2
	margin_bottom = sizes[chosen_size_index].y / 2
	
	text = old_text


func _lines_fit() -> bool:
	max_lines_visible = (rect_size.y + FONT_GAP) / (get("custom_fonts/font").get_height() + FONT_GAP)
	return get_line_count() <= max_lines_visible


func set_sizes(new_sizes: Array) -> void:
	sizes = new_sizes
	pick_smallest_size()
