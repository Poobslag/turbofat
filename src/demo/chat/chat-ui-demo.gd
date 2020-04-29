extends Control
"""
A demo which lets you test the chat UI by flipping through pages of dialog.

Keys:
	[0-9]: Changes sentence length; 1 = short, 9 = long, 0 = longest
	[Control + 0-9]: Changes response length; 1 = short, 9 = long, 0 = longest
	[Q, W, E]: Shows questions with more and more options.
	[A]: Shows a dialog line with no choices.
"""

const FRUITS := [
	"Apple", "Apricot", "Banana", "Cantaloupe", "Cherry", "Grape", "Grapefruit", "Guava", "Lemon", "Lime", "Orange",
	"Mandarin", "Mango", "Melon", "Papaya", "Peach", "Pear", "Pineapple", "Plantain", "Plum", "Tangerine", "Watermelon"
]

const SENTENCES := [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et",
	"Lorem",
	"Lorem ipsum dolor",
	"Lorem ipsum dolor sit amet",
	"Lorem ipsum dolor sit amet, consectetur",
	"Lorem ipsum dolor sit amet, consectetur adipiscing",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt",
]

const CHOICES := [
	"Are you kidding me? That's not even close to what I said!",
	"!?",
	"Yes",
	"Maybe?",
	"Yes indeed",
	"Well, alright",
	"Is this ethical?",
	"That's what you think!",
	"Hey, don't steal my thunder!",
	"This is not a productive line of discussion."
]

var _chat_library := ChatLibrary.new()
var _filename: String
var _text_override := ""
var _choice_override := ""

func _ready() -> void:
	InteractableManager.add_accent_def("Lorum", {})
	_play_chat_tree("dialog-unbranched")


func _input(event: InputEvent) -> void:
	match Global.key_scancode(event):
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			if Input.is_key_pressed(KEY_CONTROL):
				_choice_override = CHOICES[Global.key_num(event)]
			else:
				_text_override = SENTENCES[Global.key_num(event)]
			_play_chat_tree()
		KEY_Q:
			_text_override = ""
			_play_chat_tree("dialog-choices2")
		KEY_W:
			_text_override = ""
			_play_chat_tree("dialog-choices3")
		KEY_E:
			_text_override = ""
			_play_chat_tree("dialog-choices7")
		KEY_A:
			_text_override = ""
			_play_chat_tree("dialog-unbranched")


func _play_chat_tree(filename: String = "") -> void:
	if filename:
		_filename = filename
	var chat_tree := _chat_library.load_chat_events_from_file("res://src/demo/chat/%s.json" % _filename)
	if _text_override:
		chat_tree.get_event().text = _text_override
	if _choice_override:
		for i in range(chat_tree.get_event().link_texts.size()):
			chat_tree.get_event().link_texts[i] = _choice_override
	$ChatUi.play_chat_tree(chat_tree)
