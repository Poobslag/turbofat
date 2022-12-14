class_name FontFitLabel
extends Label
## This label changes its font dynamically based on the amount of text it needs to display. It chooses the largest font
## which will not overrun its boundaries.

## When calculating how much text we can accommodate, there is a 3 pixel gap between each row.
const FONT_GAP := 3

## Different fonts to try. Should be ordered from largest to smallest.
export (Array, Font) var fonts := [] setget set_fonts

var chosen_font_index := -1 setget set_chosen_font_index

func _ready() -> void:
	connect("resized", self, "_on_resized")
	pick_largest_font()
	
	# this class requires both autowrap and max_lines_visible to be set
	autowrap = true
	max_lines_visible = max(1, max_lines_visible)


## Sets the label's font to the largest font which will accommodate its text.
##
## If the label's text is modified this should be called manually. This class cannot respond to text changes or
## override set_text because of Godot #29390 (https://github.com/godotengine/godot/issues/29390)
func pick_largest_font() -> void:
	for i in range(fonts.size()):
		# start with the largest font, and try smaller and smaller fonts
		set_chosen_font_index(i)
		if _lines_fit():
			# this font is small enough to accommodate all of the text
			break


func set_chosen_font_index(new_index: int) -> void:
	chosen_font_index = new_index
	set("custom_fonts/font", fonts[chosen_font_index])


func _lines_fit() -> bool:
	max_lines_visible = (rect_size.y + FONT_GAP) / (get("custom_fonts/font").get_height() + FONT_GAP)
	return get_line_count() <= max_lines_visible


func set_fonts(new_fonts: Array) -> void:
	fonts = new_fonts
	pick_largest_font()


func _on_resized() -> void:
	pick_largest_font()
