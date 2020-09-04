class_name NametagPanel
extends Panel
"""
Resizes and shows nametag labels.
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
var nametag_size: int

"""
Assigns the name label's text and updates our nametag_size field to the smallest name label which fit.
"""
func set_nametag_text(new_text: String) -> void:
	new_text = ChattableManager.substitute_variables(new_text, true)
	
	if new_text.empty():
		nametag_size = ChatTheme.NAMETAG_OFF
	else:
		nametag_size = ChatTheme.NAMETAG_XXL
		for new_nametag_size in _labels.keys():
			var label: Label = _labels[new_nametag_size]
			label.text = new_text
			if label.get_line_count() <= label.max_lines_visible:
				nametag_size = new_nametag_size
				break
	
	# show/hide labels based on the length of the name
	hide_labels()
	visible = nametag_size != ChatTheme.NAMETAG_OFF
	if visible:
		_labels[nametag_size].visible = true
		rect_size = _panel_sizes[nametag_size]


"""
Hides all labels. Labels are eventually shown when show_label() is invoked.
"""
func hide_labels() -> void:
	for label in _labels.values():
		label.visible = false


func set_bg_color(color: Color) -> void:
	get("custom_styles/panel").set("bg_color", color)
