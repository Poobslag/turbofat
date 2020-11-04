class_name NametagPanel
extends Panel
"""
Resizes and shows nametag labels.
"""

export (Array, Vector2) var panel_sizes: Array

# size of the nametag needed to display the name text
var nametag_size: int

# The name is copied into multiple labels. We display the smallest label which fits.
onready var _labels := {
	ChatTheme.NAMETAG_SMALL: $Small,
	ChatTheme.NAMETAG_MEDIUM: $Medium,
	ChatTheme.NAMETAG_LARGE: $Large,
	ChatTheme.NAMETAG_XL: $ExtraLarge,
	ChatTheme.NAMETAG_XXL: $ExtraExtraLarge,
}

func refresh_creature(creature: Creature) -> void:
	set_nametag_text(creature.creature_name)
	refresh_chat_theme(ChatTheme.new(creature.chat_theme_def))


func refresh_chat_theme(chat_theme: ChatTheme) -> void:
	set_bg_color(chat_theme.border_color)
	set_font_color(chat_theme.nametag_font_color)


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
		rect_size = panel_sizes[nametag_size - 1]


"""
Hides all labels. Labels are eventually shown when show_label() is invoked.
"""
func hide_labels() -> void:
	for label in _labels.values():
		label.visible = false


func set_bg_color(color: Color) -> void:
	get("custom_styles/panel").set("bg_color", color)


func set_font_color(color: Color) -> void:
	for label in _labels.values():
		label.set("custom_colors/font_color", color)
