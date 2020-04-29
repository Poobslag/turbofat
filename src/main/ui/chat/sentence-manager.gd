extends Control
"""
Repositions and shows 'sentence labels', labels which show the words being spoken

Also schedules the 'bebebe' sound effects which play as text appears.

Note: SentenceSprite does not contain its own labels to prevent the labels from being distorted as the sprite grows
	and shrinks. Stationary text is easier to read.
"""

signal all_text_shown

# size of the sentence window needed to display the sentence text
var sentence_size: int = ChatAppearance.SentenceSize.EXTRA_LARGE

# Cached number of visible characters for the currently active label. If this increases, we need to play sfx.
var _prev_visible_characters := 0

# The dialog is copied into multiple labels. We display the smallest label which fits.
onready var _sentence_labels := {
	ChatAppearance.SentenceSize.SMALL: $Small,
	ChatAppearance.SentenceSize.MEDIUM: $Medium,
	ChatAppearance.SentenceSize.LARGE: $Large,
	ChatAppearance.SentenceSize.EXTRA_LARGE: $ExtraLarge,
}

func _process(_delta: float) -> void:
	var visible_characters := _sentence_label().visible_characters
	if visible_characters > _prev_visible_characters:
		if label_showing():
			# the number of visible letters increased. play a sound effect
			$BebebeSound.volume_db = rand_range(-22.0, -12.0)
			$BebebeSound.pitch_scale = rand_range(0.95, 1.05)
			$BebebeSound.play()
		_prev_visible_characters = visible_characters
		if _sentence_label().is_all_text_visible():
			emit_signal("all_text_shown")


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

This also prevents further 'bebebe' sounds from playing.
"""
func hide_labels() -> void:
	for next_sentence_size in ChatAppearance.SentenceSize.values():
		_sentence_labels[next_sentence_size].visible = false


"""
Recolors and resizes the sentence window based on the specified chat appearance.

This also causes the label to start showing the words being spoken, and causes 'bebebe' sounds to play as the label is
typed out on screen.
"""
func show_label(chat_appearance: ChatAppearance, pause: float = 0) -> void:
	_prev_visible_characters = 0
	_sentence_label().visible = true
	_sentence_label().set("custom_colors/font_color", chat_appearance.border_color)
	_sentence_label().play(pause)


"""
Returns 'true' if the currently active SentenceLabel is being shown onscreen.
"""
func label_showing() -> bool:
	return _sentence_label().visible


func is_all_text_visible() -> bool:
	return _sentence_label().is_all_text_visible()


func make_all_text_visible() -> void:
	_sentence_label().make_all_text_visible()


"""
Returns the currently active SentenceLabel.
"""
func _sentence_label() -> SentenceLabel:
	return _sentence_labels[sentence_size]
