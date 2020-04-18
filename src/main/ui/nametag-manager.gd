extends Sprite
"""
Repositions and shows nametag labels.
"""

const ChatAppearance := preload("res://src/main/ui/chat-appearance.gd")

# The name is copied into multiple labels. We display the smallest label which fits.
onready var _labels := {
	ChatAppearance.NametagSize.SMALL: $Small,
	ChatAppearance.NametagSize.MEDIUM: $Medium,
	ChatAppearance.NametagSize.LARGE: $Large,
	ChatAppearance.NametagSize.EXTRA_LARGE: $ExtraLarge,
	ChatAppearance.NametagSize.EXTRA_EXTRA_LARGE: $ExtraExtraLarge
}

# There are two nametag textures; one for small names, and four for big names
onready var _textures := {
	ChatAppearance.NametagSize.SMALL: preload("res://assets/ui/chat/nametag-small-sheet.png"),
	ChatAppearance.NametagSize.MEDIUM: preload("res://assets/ui/chat/nametag-large-sheet.png"),
	ChatAppearance.NametagSize.LARGE: preload("res://assets/ui/chat/nametag-large-sheet.png"),
	ChatAppearance.NametagSize.EXTRA_LARGE: preload("res://assets/ui/chat/nametag-large-sheet.png"),
	ChatAppearance.NametagSize.EXTRA_EXTRA_LARGE: preload("res://assets/ui/chat/nametag-large-sheet.png")
}

# size of the nametag needed to display the name text
var _nametag_size: int

"""
Assigns the name label's text and updates our _nametag_size field to the smallest name label which fit.
"""
func set_nametag_text(name: String) -> void:
	_nametag_size = ChatAppearance.NametagSize.EXTRA_EXTRA_LARGE
	for new_nametag_size in ChatAppearance.NametagSize.values():
		var label = _labels[new_nametag_size]
		label.text = name
		if label.get_line_count() <= label.max_lines_visible:
			_nametag_size = new_nametag_size
			break


"""
Hides all labels. Labels are eventually shown when show_label() is invoked.
"""
func hide_labels() -> void:
	for nametag_size in ChatAppearance.NametagSize.values():
		_labels[nametag_size].visible = false


"""
Recolors and repositions the nametag based on the current accent definition.

Parameters:
	'sentence_size': The size of the sentence window. This is needed for the nametag to reposition itself around it.
"""
func show_label(chat_appearance: ChatAppearance, sentence_size: int):
	frame = randi() % 4
	flip_h = randf() > 0.5
	flip_v = randf() > 0.5
	self_modulate = chat_appearance.border_color
	texture = _textures[_nametag_size]

	_labels[_nametag_size].visible = true
	_labels[_nametag_size].set("custom_colors/font_color", Color.black if chat_appearance.dark else Color.white)
	
	if chat_appearance.nametag_right:
		if _nametag_size == ChatAppearance.NametagSize.SMALL:
			rotation_degrees = 3
			match(sentence_size):
				ChatAppearance.SentenceSize.SMALL: position = Vector2(493, -420)
				ChatAppearance.SentenceSize.MEDIUM: position = Vector2(942, -439)
				ChatAppearance.SentenceSize.LARGE: position = Vector2(883, -550)
				ChatAppearance.SentenceSize.EXTRA_LARGE: position = Vector2(1412, -550)
		else:
			rotation_degrees = 1
			match(sentence_size):
				ChatAppearance.SentenceSize.SMALL: position = Vector2(126, -431)
				ChatAppearance.SentenceSize.MEDIUM: position = Vector2(558, -448)
				ChatAppearance.SentenceSize.LARGE: position = Vector2(476, -553)
				ChatAppearance.SentenceSize.EXTRA_LARGE: position = Vector2(957, -553)
	else:
		if _nametag_size == ChatAppearance.NametagSize.SMALL:
			rotation_degrees = -3
			match(sentence_size):
				ChatAppearance.SentenceSize.SMALL: position = Vector2(-497, -410)
				ChatAppearance.SentenceSize.MEDIUM: position = Vector2(-937, -439)
				ChatAppearance.SentenceSize.LARGE: position = Vector2(-947, -550)
				ChatAppearance.SentenceSize.EXTRA_LARGE: position = Vector2(-1437, -530)
		else:
			rotation_degrees = -1
			match(sentence_size):
				ChatAppearance.SentenceSize.SMALL: position = Vector2(-151, -423)
				ChatAppearance.SentenceSize.MEDIUM: position = Vector2(-550, -431)
				ChatAppearance.SentenceSize.LARGE: position = Vector2(-550, -561)
				ChatAppearance.SentenceSize.EXTRA_LARGE: position = Vector2(-1072, -562)
