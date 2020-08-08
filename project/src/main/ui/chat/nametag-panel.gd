extends Panel
"""
Repositions and shows nametag labels.
"""

# The name is copied into multiple labels. We display the smallest label which fits.
onready var _labels := {
	ChatTheme.NAMETAG_SMALL: $Small,
	ChatTheme.NAMETAG_MEDIUM: $Medium,
	ChatTheme.NAMETAG_LARGE: $Large,
	ChatTheme.NAMETAG_XL: $ExtraLarge,
	ChatTheme.NAMETAG_XXL: $ExtraExtraLarge,
}

# Longer names are displayed in bigger panels
onready var _panel_sizes := {
	ChatTheme.NAMETAG_SMALL: Vector2(180, 60),
	ChatTheme.NAMETAG_MEDIUM: Vector2(360, 60),
	ChatTheme.NAMETAG_LARGE: Vector2(360, 60),
	ChatTheme.NAMETAG_XL: Vector2(240, 60),
	ChatTheme.NAMETAG_XXL: Vector2(360, 60),
}

# size of the nametag needed to display the name text
var _nametag_size: int

"""
Assigns the name label's text and updates our _nametag_size field to the smallest name label which fit.
"""
func set_nametag_text(new_text: String) -> void:
	if new_text.empty():
		_nametag_size = ChatTheme.NAMETAG_OFF
	else:
		_nametag_size = ChatTheme.NAMETAG_XXL
		for new_nametag_size in _labels.keys():
			var label: Label = _labels[new_nametag_size]
			label.text = new_text
			if label.get_line_count() <= label.max_lines_visible:
				_nametag_size = new_nametag_size
				break
	
	# show/hide labels based on the length of the name
	hide_labels()
	visible = _nametag_size != ChatTheme.NAMETAG_OFF
	if visible:
		_labels[_nametag_size].visible = true
		rect_size = _panel_sizes[_nametag_size]


"""
Hides all labels. Labels are eventually shown when show_label() is invoked.
"""
func hide_labels() -> void:
	for label in _labels.values():
		label.visible = false


func set_bg_color(color: Color) -> void:
	get("custom_styles/panel").set("bg_color", color)


"""
Recolors and repositions the nametag based on the current accent definition.

Parameters:
	'chat_theme': metadata about the chat window's appearance.
	
	'nametag_right': true/false if the nametag should be drawn on the right/left side of the frame.
"""
func show_label(chat_theme: ChatTheme, nametag_right: bool) -> void:
	set_bg_color(chat_theme.border_color)
	_labels[_nametag_size].set("custom_colors/font_color", Color.black if chat_theme.dark else Color.white)
	
	rect_position.y = 2 - rect_size.y
	if nametag_right:
		rect_position.x = get_parent().rect_size.x - rect_size.x - 12
	else:
		rect_position.x = 12
