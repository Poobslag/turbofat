extends Control
"""
Repositions and shows 'sentence labels', labels which show the words being spoken

Note: SentenceSprite does not contain its own labels to prevent the labels from being distorted as the sprite grows
	and shrinks. Stationary text is easier to read.
"""

# size of the sentence window needed to display the sentence text
var sentence_size: int = ChatAppearance.SentenceSize.EXTRA_LARGE

# The dialog is copied into multiple labels. We display the smallest label which fits.
onready var _sentence_labels := {
	ChatAppearance.SentenceSize.SMALL: $Small,
	ChatAppearance.SentenceSize.MEDIUM: $Medium,
	ChatAppearance.SentenceSize.LARGE: $Large,
	ChatAppearance.SentenceSize.EXTRA_LARGE: $ExtraLarge,
}

"""
Assigns the sentence label's text and updates our sentence_size field to the smallest chat label which fit.
"""
func set_text(text: String) -> void:
	# default to the biggest window we have, in case the text doesn't fit anywhere
	sentence_size = ChatAppearance.SentenceSize.EXTRA_LARGE
	for new_sentence_size in ChatAppearance.SentenceSize.values():
		if _sentence_labels[new_sentence_size].cram_text(text):
			sentence_size = new_sentence_size
			break


"""
Hides all labels. Labels are eventually shown when show_label() is invoked.
"""
func hide_labels() -> void:
	for next_sentence_size in ChatAppearance.SentenceSize.values():
		_sentence_labels[next_sentence_size].visible = false


"""
Recolors and resizes the sentence window based on the specified chat appearance.
"""
func show_label(chat_appearance: ChatAppearance, pause: float = 0):
	_sentence_labels[sentence_size].visible = true
	_sentence_labels[sentence_size].set("custom_colors/font_color", chat_appearance.border_color)
	_sentence_labels[sentence_size].play(pause)
