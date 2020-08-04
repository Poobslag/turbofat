class_name TutorialMessage
extends RichTextLabel
"""
A label which animates text in a way that mimics speech.

Text appears a letter at a time at a constant rate. Newlines cause a long pause. Slashes cause a shorter pause and are
hidden from the player. Slashes are referred to 'lull characters' throughout the code.

Dialog authors should use lull characters to mimic patterns of speech:
	'Despite the promise of info,/ I was unable to determine what,/ if anything,/ a 'butt/ onion'/ is supposed to be.'
"""

var PAUSE_CHARACTERS := {
	" ": 0.00,
	"/": 0.40,
	"\n": 0.40,
}

# The delay in seconds before displaying the next character
var _pause := 0.0

# timing at which letters appear
var DEFAULT_PAUSE := 0.05

# 1.0 = normal, 2.0 = fastest, 6.0 = fastestestest, 1000000.0 = fastestest
var _text_speed := 2.0

# huge font used for easter eggs
var _huge_font := preload("res://src/main/ui/blogger-sans-bold-72.tres")

# normal font used for regular dialog
var _normal_font := preload("res://src/main/ui/blogger-sans-medium-30.tres")

# stores pauses for each index in the text message.
var _pauses := {}

# Counts down after all text is shown. When it reaches zero the message pops out.
var _pop_out_timer := 0.0

func _ready() -> void:
	set("custom_fonts/normal_font", _normal_font)
	hide_text()


func _process(delta: float) -> void:
	# clamped to prevent underflow (leaving the game open) or large values (a malicious string with tons of pauses)
	_pause = clamp(_pause - delta * _text_speed, -5, 5)
	
	var play_sound: bool = false
	while visible_characters < get_total_character_count() and _pause <= 0.0:
		# display the next character and increase the delay
		visible_characters += 1
		play_sound = true
		if _pauses.has(visible_characters):
			_pause += _pauses[visible_characters]
		else:
			_pause += DEFAULT_PAUSE
	
	if visible_characters >= get_total_character_count() and _pop_out_timer > 0:
		_pop_out_timer -= delta
		if _pop_out_timer <= 0:
			$Tween.pop_out()
	
	if play_sound:
		$BebebeSound.volume_db = rand_range(-22.0, -12.0)
		$BebebeSound.pitch_scale = rand_range(0.95, 1.05)
		$BebebeSound.play()


"""
Sets the pop out timer property.

This timer counts down after all text is shown. When it reaches zero the message pops out.
"""
func set_pop_out_timer(new_pop_out_timer: float) -> void:
	_pop_out_timer = new_pop_out_timer


"""
Gradually reveals a message one letter at a time.

The text can include lull characters, '/', which are hidden from the player but result in a brief delay.
"""
func append_message(text_with_lulls: String) -> void:
	_append_message_with_font(text_with_lulls, _normal_font)


"""
Gradually reveals a message one letter at a time, with a huge font.

The text can include lull characters, '/', which are hidden from the player but result in a brief delay.
"""
func append_big_message(text_with_lulls: String) -> void:
	_append_message_with_font(text_with_lulls, _huge_font)


func _append_message_with_font(text_with_lulls, font) -> void:
	# remove the pop out timer. otherwise a new message would inherit the timer from an old message
	_pop_out_timer = 0
	if not visible:
		$Tween.pop_in()
	
	if get("custom_fonts/normal_font") != font:
		hide_text()
		set("custom_fonts/normal_font", font)
		visible_characters = 0
	
	var message_waiting := visible_characters >= get_total_character_count()
	if message_waiting:
		# not displaying any messages; reset the 'pause' field so this one shows right away
		_pause = 0.0
	
	# Workaround for Godot #36381; store total_character_count before its value is reset to 0
	var total_character_count := get_total_character_count()
	
	if text:
		# separate consecutive messages with newlines
		text += "\n\n"
		_pauses[total_character_count] = 0.8
	
	for c in text_with_lulls:
		# calculate the amount to pause after displaying this character
		if not _pauses.has(total_character_count):
			_pauses[total_character_count] = 0
		
		if c in PAUSE_CHARACTERS:
			_pauses[total_character_count] += PAUSE_CHARACTERS[c]
		else:
			_pauses[total_character_count] += DEFAULT_PAUSE
		if not c in ["\n", "/"]:
			total_character_count += 1
	
	if message_waiting:
		_pause += _pauses[visible_characters] if _pauses.has(visible_characters) else DEFAULT_PAUSE
	
	text += text_with_lulls.replace("/", "")
	show()


"""
Hides the label and empties its contents.
"""
func hide_text() -> void:
	text = ""
	_pause = 0.0
	visible_characters = 0
	_pauses.clear()
	hide()


func _on_Tween_pop_out_completed() -> void:
	hide_text()
