class_name SentenceLabel
extends Label
"""
A label which animates text in a way that mimics speech.

Text appears a letter at a time at a constant rate. Newlines cause a long pause. Slashes cause a shorter pause and are
hidden from the player. Slashes are referred to 'lull characters' throughout the code.

Dialog authors should use lull characters to mimic patterns of speech:
	'Despite the promise of info,/ I was unable to determine what,/ if anything,/ a 'butt/ onion'/ is supposed to be.'
"""

# How many seconds to delay when displaying a character.
var DEFAULT_PAUSE := 0.05

# How many seconds to delay when displaying whitespace or the special lull character, '/'.
var PAUSE_CHARACTERS := {
	" ": 0.00,
	"/": 0.40,
	"\n": 0.80,
}

# Stores the delay in seconds for each visible_characters index.
var _visible_character_pauses := {}

# The delay in seconds before displaying the next character.
var _pause := 0.0

# 1.0 = slow, 2.0 = normal, 3.0 = faster, 5.0 = fastest, 1000000.0 = fastestest
var _text_speed := 2.0

# The full text including lull characters, which are hidden from the user
var _text_with_lulls: String

func _process(delta: float) -> void:
	# clamped to prevent underflow (leaving the game open) or large values (a malicious string with tons of pauses)
	_pause = clamp(_pause - delta * _text_speed, -5, 5)
	
	while not is_all_text_visible() and _pause <= 0.0:
		# display the next character and increase the delay
		visible_characters += 1
		if _visible_character_pauses.has(visible_characters):
			_pause += _visible_character_pauses[visible_characters]
		else:
			_pause += DEFAULT_PAUSE


"""
Sets the label's text, returning 'false' if it causes the label to exceed max_lines_visible.
"""
func cram_text(text_with_lulls: String) -> bool:
	_text_with_lulls = text_with_lulls
	text = text_with_lulls.replace("/", "")
	return get_line_count() <= max_lines_visible


"""
Animates the label to gradually reveal the current text, mimicking speech.

This function also calculates the duration to pause for each character. All visible characters cause a short pause.
Newlines cause a long pause. Slashes cause a medium pause and are hidden from the player.

The text must first be assigned with the cram_text function to ensure it fits and to remove any lull characters.
"""
func play(initial_pause: float = 0) -> void:
	_visible_character_pauses.clear()
	visible_characters = 0
	_pause = initial_pause

	var visible_chars_to_left := 0
	for c in _text_with_lulls:
		# calculate the amount to pause after displaying this character
		if not _visible_character_pauses.has(visible_chars_to_left):
			_visible_character_pauses[visible_chars_to_left] = 0
		
		if c in PAUSE_CHARACTERS:
			_visible_character_pauses[visible_chars_to_left] += PAUSE_CHARACTERS[c]
		else:
			_visible_character_pauses[visible_chars_to_left] += DEFAULT_PAUSE
			visible_chars_to_left += 1
	_pause += _visible_character_pauses[0] if _visible_character_pauses.has(0) else DEFAULT_PAUSE


"""
Returns 'true' if the label's visible_characters value is large enough to show all characters.
"""
func is_all_text_visible() -> bool:
	return visible_characters >= get_total_character_count()


"""
Increases the label's visible_characters value to to show all characters.
"""
func make_all_text_visible() -> void:
	visible_characters = get_total_character_count()
