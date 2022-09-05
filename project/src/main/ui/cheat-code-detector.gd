class_name CheatCodeDetector
extends Node
## Detects when the player enters cheat codes.
##
## When the player types a key, this class checks whether the player finished typing a cheat code. If a cheat code was
## typed, this class emits a signal which can be used to activate the cheat code. Any gameplay effects and sound
## effects are the responsibility of the class receiving the signal.
##
## It's recommended the class receiving a cheat code signal play an audio cue. The
## res://assets/main/ui/cheat-disable.wav and res://assets/main/ui/cheat-enable.wav sound files exist for this purpose.

## emitted when a cheat is entered.
signal cheat_detected(cheat, detector)

## The maximum length of cheat codes. Entered keys are stored in a buffer, and we don't want the buffer to grow to a
## ridiculous size.
const MAX_LENGTH := 32

## Dictionary of key scancodes used in cheat codes, and their alphanumeric representation.
const CODE_KEYS := {
	KEY_SPACE:" ", KEY_APOSTROPHE:"'", KEY_COMMA:",", KEY_MINUS:"-", KEY_PERIOD:".", KEY_SLASH:"/",
	KEY_0:"0", KEY_1:"1", KEY_2:"2", KEY_3:"3", KEY_4:"4", KEY_5:"5", KEY_6:"6", KEY_7:"7", KEY_8:"8", KEY_9:"9",
	KEY_SEMICOLON:";", KEY_EQUAL:"=",
	
	KEY_A:"a", KEY_B:"b", KEY_C:"c", KEY_D:"d", KEY_E:"e", KEY_F:"f", KEY_G:"g", KEY_H:"h", KEY_I:"i",
	KEY_J:"j", KEY_K:"k", KEY_L:"l", KEY_M:"m", KEY_N:"n", KEY_O:"o", KEY_P:"p", KEY_Q:"q", KEY_R:"r",
	KEY_S:"s", KEY_T:"t", KEY_U:"u", KEY_V:"v", KEY_W:"w", KEY_X:"x", KEY_Y:"y", KEY_Z:"z",
	
	KEY_BRACKETLEFT:"[", KEY_BACKSLASH:"\\", KEY_BRACKETRIGHT:"]", KEY_QUOTELEFT:"`",
}

## List of cheat codes. Cheat codes should be lower-case, and should not be contained within one another or the shorter
## cheat code will take precedence.
export (Array, String) var codes := []

## Buffer of key strings which were previously pressed.
var _previous_keypresses := ""


## Plays the sound effect for enabling/disabling a cheat.
func play_cheat_sound(enabled: bool) -> void:
	var cheat_sound := $CheatEnableSound if enabled else $CheatDisableSound
	cheat_sound.play()


## Processes an input event, delegating to the appropriate 'key_pressed', 'key_just_pressed', 'key_released',
## 'key_just_released' functions.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.scancode in CODE_KEYS:
		var key_string: String = CODE_KEYS[event.scancode]
		if event.pressed and not event.is_echo():
			_key_just_pressed(key_string)


## Called for the first frame when a key is pressed.
##
## Parameters:
## 	'key_string': An single-character alphanumeric representation of the pressed key
func _key_just_pressed(key_string: String) -> void:
	_previous_keypresses += key_string
	# remove the oldest keypresses so the buffer doesn't grow infinitely
	_previous_keypresses = _previous_keypresses.right(_previous_keypresses.length() - MAX_LENGTH)
	for code in codes:
		if code == _previous_keypresses.right(_previous_keypresses.length() - code.length()):
			# Clear the keypress buffer, otherwise a keypress could count towards two different cheats
			_previous_keypresses = ""
			emit_signal("cheat_detected", code, self)
