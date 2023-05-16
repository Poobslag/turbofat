extends Button
## This button changes its font dynamically based on the amount of text it needs to display. It chooses the largest
## font which will not overrun its boundaries.

## extra space needed on the left and right of the button's text
const PADDING := 6

## Different font sizes to try. Should be ordered from largest to smallest.
@export var font_sizes: Array[float]: set = set_font_sizes

func _ready() -> void:
	SystemData.misc_settings.locale_changed.connect(_on_MiscSettings_locale_changed)
	pick_largest_font_size()


func set_font_sizes(new_font_sizes: Array) -> void:
	font_sizes = new_font_sizes
	pick_largest_font_size()


## Sets the label's font to the largest font which will accommodate its text.
##
## If the label's text is modified this should be called manually. This class cannot respond to text changes or
## override set_text because of Godot #29390 (https://github.com/godotengine/godot/issues/29390)
func pick_largest_font_size() -> void:
	# our shown text is translated; the translated text needs to fit in the button
	var shown_text := tr(text)
	
	var chosen_font_size: float
	for i in range(font_sizes.size()):
		# start with the largest font, and try smaller and smaller fonts
		chosen_font_size = font_sizes[i]
		var string_size := get_theme_font("font").get_string_size(shown_text, alignment, -1, chosen_font_size)
		if string_size.x < size.x - 2 * PADDING:
			# this font is small enough to accommodate all of the text
			break
	
	set("theme_override_font_sizes/font_size", chosen_font_size)


func _on_MiscSettings_locale_changed(_value: String) -> void:
	pick_largest_font_size()
