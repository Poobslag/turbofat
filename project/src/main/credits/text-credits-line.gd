tool
class_name TextCreditsLine
extends CreditsLine
## A text line which scrolls vertically during the credits.

## If our text is too wide, we adjust our scale by this amount.
const SHRINK_FACTOR := 0.66667

## The maximum text width in units. We adjust our scale to make text fit in this width.
export (int, 50, 2000) var max_line_width := 472

export (String) var text: String setget set_text

onready var _label := $Label

func _ready() -> void:
	_refresh_text()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


## Update our text, adjusting our scale if necessary.
func _refresh_text() -> void:
	if not (is_inside_tree() and _label):
		return
	
	_label.text = PlayerData.creature_library.substitute_variables(text)
	var line_width: float = _label.get_font("font").get_string_size(_label.text).x
	if line_width > max_line_width:
		## If our text is too wide, we repeatedly adjust our scale until it fits.
		for _i in range(50):
			_label.rect_scale.x *= SHRINK_FACTOR
			if line_width * _label.rect_scale.x <= max_line_width:
				break
