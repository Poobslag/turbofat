extends Label
"""
Label which displays the text of a chat choice button.

We cannot use the button's text property because it does not support multiline text.

This label changes its font dynamically based on the amount of text it needs to display. It chooses the largest font
which will not overrun its boundaries.
"""

# When calculating how much text we can accommodate, there is a 3 pixel gap between each row.
const FONT_GAP := 3

# List of possible fonts ordered from largest to smallest
onready var _fonts := [
	preload("res://assets/ui/blogger-sans-medium-30.tres"),
	preload("res://assets/ui/blogger-sans-medium-24.tres"),
	preload("res://assets/ui/blogger-sans-medium-18.tres"),
	preload("res://assets/ui/blogger-sans-medium-14.tres"),
	preload("res://assets/ui/blogger-sans-medium-12.tres")
]

"""
Sets the label's font to the largest font which will accommodate its text.
"""
func pick_largest_font() -> void:
	if not _fonts:
		return
		
	for font in _fonts:
		# start with the largest font, and try smaller and smaller fonts
		max_lines_visible = (rect_size.y + FONT_GAP) / (font.get_height() + FONT_GAP)
		set("custom_fonts/font", font)
		if get_line_count() <= max_lines_visible:
			# this font is small enough to accommodate all of the text
			break


func _ready() -> void:
	pick_largest_font()


func _on_resized() -> void:
	pick_largest_font()
