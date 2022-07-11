extends Node
## A demo which shows off the chat window.
##
## Keys:
## 	[0-9]: Prints a chat line; 1 = short, 9 = long, 0 = longest
## 	SHIFT+[0-9]: Changes the name; 1 = short, 9 = long, 0 = longest
## 	'[', ']': Change the accent texture
## 	Arrows: Change the color and scale
## 	[A]: Make the chat window appear/disappear
## 	[D]: Toggle 'dark mode' for the accent
## 	[L]: Toggle between 'left', 'right' and 'no preference' for the nametag position
## 	[P]: Print the json accent definition
## 	[R]: Generate a random accent definition
## 	[S]: Swap the accent's colors
## 	[Z]: Squish the window to the side

const TEXTS := [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore" \
		+ " magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea" \
		+ " commodo consequat.",
	"Lorem",
	"Lorem ipsum dolor",
	"Lorem ipsum dolor sit amet",
	"Lorem ipsum dolor sit amet, consectetur",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore" \
		+ " magna aliqua. Ut enim ad minim",
]

const NAMES := [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore" \
		+ " magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea" \
		+ " commodo consequat.",
	"",
	"Lo",
	"Lorem",
	"Lorem ipsum",
	"Lorem ipsum dolor",
	"Lorem ipsum dolor sit amet",
	"Lorem ipsum dolor sit amet, consectetur",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid",
]

const COLORS := [
	"b23823", "eeda4d", "41a740", "b47922", "6f83db",
	"a854cb", "f57e7d", "f9bb4a", "8fea40", "feceef",
	"b1edee", "f9f7d9", "1a1a1e", "7a8289", "0b45a6",
]

const SCALES := [
	0.50, 0.58, 0.67, 0.75, 0.88,
	1.00, 1.15, 1.33, 1.50, 1.75,
	2.00, 2.30, 2.66, 3.00, 3.50,
	4.00, 4.60, 5.33, 6.00, 7.00,
	8.00
]

## these fields store the results of the user's input
var _name_index := 4
var _text_index := 4

var _color_index := 0
var _scale_index := 5
var _accent_swapped := false
var _texture_index := 0
var _dark := false

var _nametag_side: int = ChatEvent.NametagSide.LEFT
var _squished := false

func _ready() -> void:
	_play_chat_event()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			if Input.is_key_pressed(KEY_SHIFT):
				_name_index = Utils.key_num(event)
			else:
				_text_index = Utils.key_num(event)
			_play_chat_event()
		KEY_A:
			if $ChatFrame.is_chat_window_showing():
				$ChatFrame.pop_out()
			else:
				_play_chat_event()
		KEY_D:
			_dark = not _dark
			_play_chat_event()
		KEY_L:
			_nametag_side = (_nametag_side + 1) % 3
			_play_chat_event()
		KEY_P:
			print(to_json(_get_chat_theme_def()))
		KEY_R:
			_color_index = randi() % COLORS.size()
			_scale_index = randi() % SCALES.size()
			_accent_swapped = randf() > 0.5
			_texture_index = randi() % ChatLinePanel.CHAT_TEXTURE_COUNT
			_dark = randf() > 0.5
			_play_chat_event()
		KEY_S:
			_accent_swapped = not _accent_swapped
			_play_chat_event()
		KEY_BRACKETRIGHT:
			_texture_index = wrapi(_texture_index + 1, 0, ChatLinePanel.CHAT_TEXTURE_COUNT)
			_play_chat_event()
		KEY_BRACKETLEFT:
			_texture_index = wrapi(_texture_index - 1, 0, ChatLinePanel.CHAT_TEXTURE_COUNT)
			_play_chat_event()
		KEY_RIGHT:
			_color_index = wrapi(_color_index + 1, 0, COLORS.size())
			_play_chat_event()
		KEY_LEFT:
			_color_index = wrapi(_color_index - 1, 0, COLORS.size())
			_play_chat_event()
		KEY_UP:
			if _scale_index < SCALES.size():
				_scale_index += 1
				_play_chat_event()
		KEY_DOWN:
			if _scale_index > 0:
				_scale_index -= 1
				_play_chat_event()
		KEY_Z:
			_squished = not _squished
			_play_chat_event()


## Configures the chat window's appearance based on the user's input.
func _play_chat_event() -> void:
	var creature_def := CreatureDef.new()
	creature_def.creature_name = NAMES[_name_index]
	PlayerData.creature_library.set_creature_def("lorum", creature_def)
	
	var chat_event := ChatEvent.new()
	chat_event.who = "lorum"
	chat_event.text = TEXTS[_text_index]
	chat_event.chat_theme_def = _get_chat_theme_def()
	chat_event.nametag_side = _nametag_side
	$ChatFrame.play_chat_event(chat_event, _squished)


## Generates a new accent definition generated based on the user's input.
func _get_chat_theme_def() -> Dictionary:
	return {
		"accent_texture": _texture_index,
		"accent_scale": SCALES[clamp(_scale_index, 0, SCALES.size() - 1)],
		"accent_swapped": _accent_swapped,
		"color": COLORS[clamp(_color_index, 0, COLORS.size() - 1)],
		"dark": _dark
	}
