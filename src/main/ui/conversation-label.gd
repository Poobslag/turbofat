extends Label
"""
A label which animates conversation text in a way that mimics speech.

Text appears a letter at a time at a constant rate. Newlines cause a long pause. Slashes cause a shorter pause and are
hidden from the player.

Dialog authors should use slashes to mimic patterns of speech:
	'Despite the promise of info,/ I was unable to determine what,/ if anything,/ a 'butt/ onion'/ is supposed to be.'
"""

# How many seconds to delay when displaying a glyph.
var DEFAULT_GLYPH_DELAY := 0.05

# How many seconds to delay when displaying whitespace or the special pause character, '/'.
var SPECIAL_GLYPH_DELAYS := {
	" ": 0.00,
	"/": 0.40,
	"\n": 0.80,
}

# Stores the delay in seconds for each visible_characters index.
var _visible_character_delays := {}

# The delay in seconds before we'll display the next glyph.
var _glyph_delay := 0.0

# 1.0 = slow, 2.0 = normal, 3.0 = faster, 5.0 = fastest, 1000000.0 = fastestest
var _text_speed := 2.0

func _process(delta: float) -> void:
	# clamped to prevent underflow
	_glyph_delay = clamp(_glyph_delay - delta * _text_speed, -3600, 3600)
	
	while visible_characters < get_total_character_count() and _glyph_delay <= 0.0:
		# display the next character and increase the delay
		visible_characters += 1
		if _visible_character_delays.has(visible_characters):
			_glyph_delay += _visible_character_delays[visible_characters]
		else:
			_glyph_delay += DEFAULT_GLYPH_DELAY


"""
Animates the conversation label to gradually reveal the specified text, mimicking speech.
"""
func play_text(text_with_pauses: String) -> void:
	_visible_character_delays.clear()
	visible_characters = 0
	text = text_with_pauses.replace("/", "")
	
	var visible_chars_to_left = 0
	for i in range(text_with_pauses.length()):
		if not _visible_character_delays.has(visible_chars_to_left):
			_visible_character_delays[visible_chars_to_left] = 0
		if text_with_pauses[i] in [" ", "\n", "/"]:
			_visible_character_delays[visible_chars_to_left] += SPECIAL_GLYPH_DELAYS[text_with_pauses[i]]
		else:
			_visible_character_delays[visible_chars_to_left] += DEFAULT_GLYPH_DELAY
			visible_chars_to_left += 1
	_glyph_delay = _visible_character_delays[0] if _visible_character_delays.has(0) else DEFAULT_GLYPH_DELAY
