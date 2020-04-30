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
	[Shift]: Squish the window to the side
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
var _squished := false

func _ready() -> void:
	_play_chat_event()


func _input(event: InputEvent) -> void:
	match Global.key_scancode(event):
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			if Input.is_key_pressed(KEY_SHIFT):
				_name_index = Global.key_num(event)
			else:
				_sentence_index = Global.key_num(event)
			_play_chat_event()
		KEY_A:
			if $ChatFrame.chat_window_showing():
				$ChatFrame.pop_out()
			else:
				_play_chat_event()
		KEY_D:
			_dark = not _dark
			_play_chat_event()
		KEY_L:
			_nametag_right = not _nametag_right
			_play_chat_event()
		KEY_P:
			print(to_json(_get_accent_def()))
		KEY_S:
			_accent_swapped = not _accent_swapped
			_play_chat_event()
		KEY_BRACERIGHT:
			_texture_index += 1
			_play_chat_event()
		KEY_BRACELEFT:
			_texture_index -= 1
			_play_chat_event()
		KEY_RIGHT:
			_color_index += 1
			_play_chat_event()
		KEY_LEFT:
			_color_index -= 1
			_play_chat_event()
		KEY_UP:
			_scale_index += 1
			_play_chat_event()
		KEY_DOWN:
			_scale_index -= 1
			_play_chat_event()
		KEY_SHIFT:
			_squished = !_squished
			_play_chat_event()


"""
Configures the chat window's appearance based on the user's input.
"""
func _play_chat_event() -> void:
	$ChatFrame.play_chat_event(NAMES[_name_index], SENTENCES[_sentence_index], _get_accent_def(), _nametag_right, _squished)


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
