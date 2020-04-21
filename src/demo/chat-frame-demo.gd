extends Control
"""
A demo which shows off the chat window.

Keys:
	[0-9]: Prints a sentence; 1 = short, 9 = long, 0 = longest
	SHIFT+[0-9]: Changes the name; 1 = short, 9 = long, 0 = longest
	'[', ']': Change the accent texture
	Arrows: Change the color and scale
	[A]: Make the chat window appear/disappear
	[D]: Toggle 'dark mode' for the accent
	[L]: Toggle 'left' and 'right' for the nametag position
	[P]: Print the json accent definition
	[S]: Swap the accent's colors
"""

const SENTENCES := [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
	"Lorem",
	"Lorem ipsum dolor",
	"Lorem ipsum dolor sit amet",
	"Lorem ipsum dolor sit amet, consectetur",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim "
]

const NAMES := [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
	"",
	"Lo",
	"Lorem",
	"Lorem ipsum",
	"Lorem ipsum dolor",
	"Lorem ipsum dolor sit amet",
	"Lorem ipsum dolor sit amet, consectetur",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid"
]

const COLORS := [
	"b23823", "eeda4d", "41a740", "b47922", "6f83db",
	"a854cb", "f57e7d", "f9bb4a", "8fea40", "feceef",
	"b1edee", "f9f7d9", "1a1a1e", "7a8289", "0b45a6"
]

# 10 scales ranging from [0.25, 1.00] including 0.50
const SCALES := [
	0.25, 0.29, 0.33, 0.38, 0.44, 0.50, 0.57, 0.66, 0.75, 0.87, 1.00
]

# these fields store the results of the user's input
var _name_index := 4
var _texture_index := 0
var _color_index := 0
var _scale_index := 5
var _sentence_index := 4
var _accent_swapped := false
var _dark := false
var _nametag_right := false

func _ready():
	_play_text()


func _input(event: InputEvent) -> void:
	if Global.is_num_just_pressed():
		if Input.is_key_pressed(KEY_SHIFT):
			_name_index = Global.get_num_just_pressed()
			_play_text()
		else:
			_sentence_index = Global.get_num_just_pressed()
			_play_text()
	if Input.is_key_pressed(KEY_A) and not event.is_echo():
		if $ChatFrame.chat_window_showing():
			$ChatFrame.pop_out()
		else:
			_play_text()
	if Input.is_key_pressed(KEY_D) and not event.is_echo():
		_dark = not _dark
		_play_text()
	if Input.is_key_pressed(KEY_L) and not event.is_echo():
		_nametag_right = not _nametag_right
		_play_text()
	if Input.is_key_pressed(KEY_P) and not event.is_echo():
		print(to_json(_get_accent_def()))
	if Input.is_key_pressed(KEY_S) and not event.is_echo():
		_accent_swapped = not _accent_swapped
		_play_text()
	if Input.is_key_pressed(KEY_BRACERIGHT) and not event.is_echo():
		_texture_index += 1
		_play_text()
	if Input.is_key_pressed(KEY_BRACELEFT) and not event.is_echo():
		_texture_index -= 1
		_play_text()
	if Input.is_key_pressed(KEY_RIGHT) and not event.is_echo():
		_color_index += 1
		_play_text()
	if Input.is_key_pressed(KEY_LEFT) and not event.is_echo():
		_color_index -= 1
		_play_text()
	if Input.is_key_pressed(KEY_UP) and not event.is_echo():
		_scale_index += 1
		_play_text()
	if Input.is_key_pressed(KEY_DOWN) and not event.is_echo():
		_scale_index -= 1
		_play_text()


"""
Configures the chat window's appearance based on the user's input.
"""
func _play_text() -> void:
	$ChatFrame.play_text(NAMES[_name_index], SENTENCES[_sentence_index], _get_accent_def(), _nametag_right)


"""
Generates a new accent definition generated based on the user's input.
"""
func _get_accent_def() -> Dictionary:
	return {
		"accent_texture": _texture_index,
		"accent_scale": SCALES[clamp(_scale_index, 0, SCALES.size() - 1)],
		"accent_swapped": _accent_swapped,
		"color": COLORS[clamp(_color_index, 0, COLORS.size() - 1)],
		"dark": _dark
	}
