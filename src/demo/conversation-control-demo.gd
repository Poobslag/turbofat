extends Control
"""
A demo which shows off the conversation window.

Keys:
	'[', ']': Change the accent texture
	arrows: Change the color and scale
	[D]: Toggle 'dark mode' for the accent
	[S]: Swap the accent's colors
	[P]: Print the json accent definition
"""

const COLORS := [
	"b23823", "eeda4d", "41a740", "b47922", "6f83db",
	"a854cb", "f57e7d", "f9bb4a", "8fea40", "feceef",
	"b1edee", "f9f7d9", "1a1a1e", "7a8289", "0b45a6"
]

const SCALES := [
	0.8, 1.0, 1.2, 1.3, 1.5, 2.0, 2.5
]

# these fields store the results of the user's input
var _current_texture_index := 0
var _current_color_index := 0
var _current_scale_index := 3
var _current_accent_swapped := false
var _current_dark := false

func _ready():
	_update_accent_def()


func _input(event: InputEvent) -> void:
	var just_pressed := event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_D) and just_pressed:
		_current_dark = not _current_dark
		_update_accent_def()
	if Input.is_key_pressed(KEY_S) and just_pressed:
		_current_accent_swapped = not _current_accent_swapped
		_update_accent_def()
	if Input.is_key_pressed(KEY_BRACERIGHT) and just_pressed:
		_current_texture_index += 1
		_update_accent_def()
	if Input.is_key_pressed(KEY_BRACELEFT) and just_pressed:
		_current_texture_index -= 1
		_update_accent_def()
	if Input.is_key_pressed(KEY_RIGHT) and just_pressed:
		_current_color_index += 1
		_update_accent_def()
	if Input.is_key_pressed(KEY_LEFT) and just_pressed:
		_current_color_index -= 1
		_update_accent_def()
	if Input.is_key_pressed(KEY_UP) and just_pressed:
		_current_scale_index += 1
		_update_accent_def()
	if Input.is_key_pressed(KEY_DOWN) and just_pressed:
		_current_scale_index -= 1
		_update_accent_def()
	if Input.is_key_pressed(KEY_P) and just_pressed:
		print(to_json(_get_accent_def()))


"""
Configures the conversation window's appearance based on the user's input.
"""
func _update_accent_def():
	$ConversationControl.set_accent_def(_get_accent_def())


"""
Generates a new accent definition generated based on the user's input.
"""
func _get_accent_def() -> Dictionary:
	return {
		"accent_texture" : _current_texture_index,
		"accent_scale" : SCALES[clamp(_current_scale_index, 0, SCALES.size() - 1)],
		"accent_swapped" : _current_accent_swapped,
		"color" : COLORS[clamp(_current_color_index, 0, COLORS.size() - 1)],
		"dark" : _current_dark,
	}
