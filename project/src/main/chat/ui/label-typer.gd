class_name LabelTyper
extends Node
## Animates a Label to gradually reveal text, mimicking speech.

signal all_text_shown

## How many seconds to delay when displaying a character.
const DEFAULT_PAUSE := 0.05

## How many seconds to delay when displaying whitespace or the special lull character, '|'.
const PAUSE_CHARACTERS := {
	" ": 0.00,
	"|": 0.40,
	"\n": 0.80,
}

## Stores the delay in seconds for each visible_characters index.
var _visible_character_pauses := {}

## Delay in seconds before displaying the next character.
var _pause := 0.0

## 1.0 = slow, 2.0 = normal, 3.0 = faster, 5.0 = fastest, 1000000.0 = fastestest
var _text_speed := 2.0

onready var _label := get_parent()
## plays a typewriter sound as text appears
onready var _bebebe_sound: AudioStreamPlayer = $BebebeSound

func _process(delta: float) -> void:
	# clamped to prevent underflow (leaving the game open) or large values (a malicious string with tons of pauses)
	_pause = clamp(_pause - delta * _text_speed, -5, 5)
	
	var newly_visible_characters := 0
	while not is_all_text_visible() and _pause <= 0.0:
		# display the next character and increase the delay
		_label.visible_characters += 1
		newly_visible_characters += 1
		if _visible_character_pauses.has(_label.visible_characters):
			_pause += _visible_character_pauses[_label.visible_characters]
		else:
			_pause += DEFAULT_PAUSE
	
	if newly_visible_characters > 0:
		# the number of visible letters increased. play a sound effect
		_bebebe_sound.volume_db = rand_range(-22.0, -12.0)
		_bebebe_sound.pitch_scale = rand_range(0.95, 1.05)
		_bebebe_sound.play()
		if is_all_text_visible():
			emit_signal("all_text_shown")


## Animates the label to gradually reveal the current text, mimicking speech.
##
## This function also calculates the duration to pause for each character. All visible characters cause a short pause.
## Newlines cause a long pause. Slashes cause a medium pause and are hidden from the player.
func show_message(text_with_lulls: String, initial_pause: float = 0.0) -> void:
	# clear any pauses and data related to the old message
	hide_message()
	
	_label.visible = true
	set_process(true)
	_label.text = text_with_lulls.replace("|", "")
	_calculate_pauses(text_with_lulls, initial_pause)


## Returns 'true' if the label's visible_characters value is large enough to show all characters.
func is_all_text_visible() -> bool:
	return _label.visible_characters >= _label.get_total_character_count()


## Hides the message and clears any stored data about its state.
func hide_message() -> void:
	_visible_character_pauses.clear()
	_label.visible_characters = 0
	_pause = 0
	_label.visible = false
	set_process(false)


## Increases the label's visible_characters value to to show all characters.
func make_all_text_visible() -> void:
	if _label.visible_characters < _label.get_total_character_count():
		_label.visible_characters = _label.get_total_character_count()
		emit_signal("all_text_shown")


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
