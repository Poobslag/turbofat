extends Sprite
"""
Repositions and shows nametag labels.
"""

const ChatAppearance := preload("res://src/main/ui/chat/chat-appearance.gd")

# The name is copied into multiple labels. We display the smallest label which fits.
onready var _labels := {
	ChatAppearance.NAMETAG_SMALL: $Small,
	ChatAppearance.NAMETAG_MEDIUM: $Medium,
	ChatAppearance.NAMETAG_LARGE: $Large,
	ChatAppearance.NAMETAG_XL: $ExtraLarge,
	ChatAppearance.NAMETAG_XXL: $ExtraExtraLarge,
}

# There are two nametag textures; one for small names, and four for big names
onready var _textures := {
	ChatAppearance.NAMETAG_SMALL: preload("res://assets/main/ui/chat/nametag-small-sheet.png"),
	ChatAppearance.NAMETAG_MEDIUM: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
	ChatAppearance.NAMETAG_LARGE: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
	ChatAppearance.NAMETAG_XL: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
	ChatAppearance.NAMETAG_XXL: preload("res://assets/main/ui/chat/nametag-large-sheet.png"),
}

# size of the nametag needed to display the name text
var _nametag_size: int

"""
Assigns the name label's text and updates our _nametag_size field to the smallest name label which fit.
"""
func set_nametag_text(name: String) -> void:
	if name.empty():
		_nametag_size = ChatAppearance.NAMETAG_OFF
	else:
		_nametag_size = ChatAppearance.NAMETAG_XXL
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
	'sentence_size': The size of the sentence window. This is needed for the nametag to reposition itself around it.
	
	'nametag_right': true/false if the nametag should be drawn on the right/left side of the frame.
"""
func show_label(chat_appearance: ChatAppearance, nametag_right: bool, sentence_size: int) -> void:
	hide_labels()
	
	if _nametag_size == ChatAppearance.NAMETAG_OFF:
		visible = false
		# No nametag label to show.
		return
	
	visible = true
	frame = randi() % 4
	flip_h = randf() > 0.5
	flip_v = randf() > 0.5
	self_modulate = chat_appearance.border_color
	texture = _textures[_nametag_size]

	_labels[_nametag_size].visible = true
	_labels[_nametag_size].set("custom_colors/font_color", Color.black if chat_appearance.dark else Color.white)
	
	if nametag_right:
		if _nametag_size == ChatAppearance.NAMETAG_SMALL:
			rotation_degrees = 3
			match(sentence_size):
				ChatAppearance.SENTENCE_SMALL: position = Vector2(493, -420)
				ChatAppearance.SENTENCE_MEDIUM: position = Vector2(942, -439)
				ChatAppearance.SENTENCE_LARGE: position = Vector2(883, -550)
				ChatAppearance.SENTENCE_XL: position = Vector2(1412, -550)
		else:
			rotation_degrees = 1
			match(sentence_size):
				ChatAppearance.SENTENCE_SMALL: position = Vector2(126, -431)
				ChatAppearance.SENTENCE_MEDIUM: position = Vector2(558, -448)
				ChatAppearance.SENTENCE_LARGE: position = Vector2(476, -553)
				ChatAppearance.SENTENCE_XL: position = Vector2(957, -553)
	else:
		if _nametag_size == ChatAppearance.NAMETAG_SMALL:
			rotation_degrees = -3
			match(sentence_size):
				ChatAppearance.SENTENCE_SMALL: position = Vector2(-497, -410)
				ChatAppearance.SENTENCE_MEDIUM: position = Vector2(-937, -439)
				ChatAppearance.SENTENCE_LARGE: position = Vector2(-947, -550)
				ChatAppearance.SENTENCE_XL: position = Vector2(-1437, -530)
		else:
			rotation_degrees = -1
			match(sentence_size):
				ChatAppearance.SENTENCE_SMALL: position = Vector2(-151, -423)
				ChatAppearance.SENTENCE_MEDIUM: position = Vector2(-550, -431)
				ChatAppearance.SENTENCE_LARGE: position = Vector2(-550, -561)
				ChatAppearance.SENTENCE_XL: position = Vector2(-1072, -562)
