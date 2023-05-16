class_name FontFitLabel
extends Label
## This label changes its font dynamically based on the amount of text it needs to display. It chooses the largest font
## which will not overrun its boundaries.

## Different fonts to try. Should be ordered from largest to smallest.
@export var _fonts: Array[Font]

@export var font_sizes: Array[float]: set = set_font_sizes

var chosen_font_size_index := -1: set = set_chosen_font_size_index

func _ready() -> void:
	connect("resized", Callable(self, "_on_resized"))
	pick_largest_font_size()
	
	# this class requires both autowrap_mode and max_lines_visible to be set
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	max_lines_visible = max(1, max_lines_visible)


## Sets the label's font to the largest font which will accommodate its text.
##
## If the label's text is modified this should be called manually. This class cannot respond to text changes or
## override set_text because of Godot #29390 (https://github.com/godotengine/godot/issues/29390)
func pick_largest_font_size() -> void:
	for i in range(font_sizes.size()):
		set_chosen_font_size_index(i)
		# start with the largest font, and try smaller and smaller fonts
		if _lines_fit():
			# this font is small enough to accommodate all of the text, or there are no options left
			break


func set_chosen_font_size_index(new_index: int) -> void:
	chosen_font_size_index = new_index
	set("theme_override_font_sizes/font_size", font_sizes[chosen_font_size_index])


func _lines_fit() -> bool:
	max_lines_visible = (size.y + get_theme_constant("line_spacing")) \
			/ (get_theme_font("font").get_height(font_sizes[chosen_font_size_index]) + get_theme_constant("line_spacing"))
	return get_line_count() <= max_lines_visible


func set_font_sizes(new_font_sizes: Array) -> void:
	font_sizes = new_font_sizes
	pick_largest_font_size()


func _on_resized() -> void:
	pick_largest_font_size()
