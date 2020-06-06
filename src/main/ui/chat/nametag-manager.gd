extends Sprite
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

# There are two nametag textures; one for small names, and four for big names
onready var _textures := {
	ChatTheme.NAMETAG_SMALL: preload("res://assets/main/ui/chat/nametag-small-sheet.png"),
	ChatTheme.NAMETAG_MEDIUM: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
	ChatTheme.NAMETAG_LARGE: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
	ChatTheme.NAMETAG_XL: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
	ChatTheme.NAMETAG_XXL: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
}

# size of the nametag needed to display the name text
var _nametag_size: int

"""
Assigns the name label's text and updates our _nametag_size field to the smallest name label which fit.
"""
func set_nametag_text(name: String) -> void:
	if name.empty():
		_nametag_size = ChatTheme.NAMETAG_OFF
	else:
		_nametag_size = ChatTheme.NAMETAG_XXL
		for new_nametag_size in _labels.keys():
			var label: Label = _labels[new_nametag_size]
			label.text = name
			if label.get_line_count() <= label.max_lines_visible:
				_nametag_size = new_nametag_size
				break


"""
Hides all labels. Labels are eventually shown when show_label() is invoked.
"""
func hide_labels() -> void:
	for label in _labels.values():
		label.visible = false


"""
Recolors and repositions the nametag based on the current accent definition.

Parameters:
	'chat_line_size': The size of the chat line window. This is needed for the nametag to reposition itself around it.
	
	'nametag_right': true/false if the nametag should be drawn on the right/left side of the frame.
"""
func show_label(chat_theme: ChatTheme, nametag_right: bool, chat_line_size: int) -> void:
	hide_labels()
	
	if _nametag_size == ChatTheme.NAMETAG_OFF:
		visible = false
		# No nametag label to show.
		return
	
	visible = true
	frame = randi() % 4
	flip_h = randf() > 0.5
	flip_v = randf() > 0.5
	self_modulate = chat_theme.border_color
	texture = _textures[_nametag_size]

	_labels[_nametag_size].visible = true
	_labels[_nametag_size].set("custom_colors/font_color", Color.black if chat_theme.dark else Color.white)
	
	if nametag_right:
		if _nametag_size == ChatTheme.NAMETAG_SMALL:
			rotation_degrees = 3
			match(chat_line_size):
				ChatTheme.LINE_SMALL: position = Vector2(493, -420)
				ChatTheme.LINE_MEDIUM: position = Vector2(942, -439)
				ChatTheme.LINE_LARGE: position = Vector2(883, -550)
				ChatTheme.LINE_XL: position = Vector2(1412, -550)
		else:
			rotation_degrees = 1
			match(chat_line_size):
				ChatTheme.LINE_SMALL: position = Vector2(126, -431)
				ChatTheme.LINE_MEDIUM: position = Vector2(558, -448)
				ChatTheme.LINE_LARGE: position = Vector2(476, -553)
				ChatTheme.LINE_XL: position = Vector2(957, -553)
	else:
		if _nametag_size == ChatTheme.NAMETAG_SMALL:
			rotation_degrees = -3
			match(chat_line_size):
				ChatTheme.LINE_SMALL: position = Vector2(-497, -410)
				ChatTheme.LINE_MEDIUM: position = Vector2(-937, -439)
				ChatTheme.LINE_LARGE: position = Vector2(-947, -550)
				ChatTheme.LINE_XL: position = Vector2(-1437, -530)
		else:
			rotation_degrees = -1
			match(chat_line_size):
				ChatTheme.LINE_SMALL: position = Vector2(-151, -423)
				ChatTheme.LINE_MEDIUM: position = Vector2(-550, -431)
				ChatTheme.LINE_LARGE: position = Vector2(-550, -561)
				ChatTheme.LINE_XL: position = Vector2(-1072, -562)
