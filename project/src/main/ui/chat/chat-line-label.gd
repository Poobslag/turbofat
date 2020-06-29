class_name ChatLineLabel
extends RectFitLabel
"""
A label which animates text in a way that mimics speech.

Text appears a letter at a time at a constant rate. Newlines cause a long pause. Slashes cause a shorter pause and are
hidden from the player. Slashes are referred to 'lull characters' throughout the code.

Dialog authors should use lull characters to mimic patterns of speech:
	'Despite the promise of info,/ I was unable to determine what,/ if anything,/ a 'butt/ onion'/ is supposed to be.'
"""

# emitted after the full dialog chat line is typed out onscreen
signal all_text_shown

# How many seconds to delay when displaying a character.
const DEFAULT_PAUSE := 0.05

# How many seconds to delay when displaying whitespace or the special lull character, '/'.
const PAUSE_CHARACTERS := {
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

func _ready() -> void:
	# hidden by default to avoid firing signals and playing sounds
	hide_message()


func _process(delta: float) -> void:
	# clamped to prevent underflow (leaving the game open) or large values (a malicious string with tons of pauses)
	_pause = clamp(_pause - delta * _text_speed, -5, 5)
	
	var newly_visible_characters := 0
	while not is_all_text_visible() and _pause <= 0.0:
		# display the next character and increase the delay
		visible_characters += 1
		newly_visible_characters += 1
		if _visible_character_pauses.has(visible_characters):
			_pause += _visible_character_pauses[visible_characters]
		else:
			_pause += DEFAULT_PAUSE
	
	if newly_visible_characters > 0:
		# the number of visible letters increased. play a sound effect
		$BebebeSound.volume_db = rand_range(-22.0, -12.0)
		$BebebeSound.pitch_scale = rand_range(0.95, 1.05)
		$BebebeSound.play()
		if is_all_text_visible():
			emit_signal("all_text_shown")


"""
Animates the label to gradually reveal the current text, mimicking speech.

This function also calculates the duration to pause for each character. All visible characters cause a short pause.
Newlines cause a long pause. Slashes cause a medium pause and are hidden from the player.

Returns a ChatTheme.ChatLineSize corresponding to the required chat frame size.
"""
func show_message(text_with_lulls: String, initial_pause: float = 0.0) -> int:
	# clear any pauses and data related to the old message
	hide_message()
	
	visible = true
	set_process(true)
	text = text_with_lulls.replace("/", "")
	pick_smallest_size()
	_calculate_pauses(text_with_lulls)
	return chosen_size_index


"""
Recolors the chat line label based on the specified chat appearance.
"""
func update_appearance(chat_theme: ChatTheme) -> void:
	set("custom_colors/font_color", chat_theme.border_color)


func _calculate_pauses(text_with_lulls: String, initial_pause: float = 0.0) -> void:
	var visible_chars_to_left := 0
	for c in text_with_lulls:
		# calculate the amount to pause after displaying this character
		if not _visible_character_pauses.has(visible_chars_to_left):
			_visible_character_pauses[visible_chars_to_left] = 0
		
		if c in PAUSE_CHARACTERS:
			_visible_character_pauses[visible_chars_to_left] += PAUSE_CHARACTERS[c]
		else:
			_visible_character_pauses[visible_chars_to_left] += DEFAULT_PAUSE
			visible_chars_to_left += 1
	_pause = initial_pause
	_pause += _visible_character_pauses[0] if _visible_character_pauses.has(0) else DEFAULT_PAUSE


"""
Hides the message and clears any stored data about its state.
"""
func hide_message() -> void:
	_visible_character_pauses.clear()
	visible_characters = 0
	_pause = 0
	visible = false
	set_process(false)


"""
Returns 'true' if the label's visible_characters value is large enough to show all characters.
"""
func is_all_text_visible() -> bool:
	return visible_characters >= get_total_character_count()


"""
Increases the label's visible_characters value to to show all characters.
"""
func make_all_text_visible() -> void:
	if visible_characters < get_total_character_count():
		visible_characters = get_total_character_count()
		emit_signal("all_text_shown")
