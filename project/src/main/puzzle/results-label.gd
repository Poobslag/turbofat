class_name ResultsLabel
extends RichTextLabel
## Results label which reveals its contents line by line.

## emitted when new characters appear in the window. newlines are stripped from the signal
signal text_shown(new_text)

## unshown character which causes the output to pause for 0.2 beats
const LULL_CHARACTER := '|'

## Delay in seconds before displaying the next character
var _pause := 0.0

## timing at which messages appear. defaults to 136 bpm
var _beat_duration := 60 / 136.0

## 1.0 = normal, 2.0 = fastest, 6.0 = fastestestest, 1000000.0 = fastestest
var _text_speed := 1.0

## These two fields are used to track unshown text which is gradually revealed. RichTextLabel defines a
## 'visible_characters' field which supports this capability, but it does not mesh well with the scroll bar or the
## 'scroll_following' property. So we reimplement the concept of invisible characters our own way.
var _unshown_text := ""
var _unshown_index := 0

## plays a typewriter sound as text appears
@onready var _bebebe_sound: AudioStreamPlayer = $BebebeSound

func _ready() -> void:
	hide_text()


func _process(delta: float) -> void:
	# clamped to prevent underflow (leaving the game open) or large values (a malicious string with tons of pauses)
	_pause = clamp(_pause - delta * _text_speed, -5, 5)
	
	var new_text := ""
	while _unshown_index < _unshown_text.length() and _pause <= 0.0:
		# continue showing characters until we hit a pause
		var unshown_char := _unshown_text[_unshown_index]
		if unshown_char == LULL_CHARACTER:
			_pause += 0.2 * _beat_duration
		else:
			text += unshown_char
			if unshown_char != '\n':
				# strip newlines from the results. newlines shouldn't play a
				# sound, and recipients don't care about them
				new_text += unshown_char
		_unshown_index += 1
	
	if new_text:
		# play a sound; repeatedly increase the pitch for a 'counting up' sound
		_bebebe_sound.volume_db = randf_range(-7.0, -12.0)
		_bebebe_sound.pitch_scale = lerp(_bebebe_sound.pitch_scale, 3.0, 0.004)
		_bebebe_sound.play()
		emit_signal("text_shown", new_text)


## Reveals the label and empties its contents, gradually appending text over time.
##
## The text can include lull characters, '|', which are hidden from the player but result in a brief delay to mimic
## patterns of speech:
## 	'Despite the promise of info,| I was unable to determine what,| if anything,| a 'butt| onion'| is supposed to be.'
func show_text(text_with_lulls: String) -> void:
	# reset text state before showing new text
	hide_text()
	
	_unshown_text = text_with_lulls
	show()


## Hides the label and empties its contents.
func hide_text() -> void:
	text = ""
	_unshown_text = ""
	_bebebe_sound.pitch_scale = 0.6
	_unshown_index = 0
	_pause = 0.0
	hide()
