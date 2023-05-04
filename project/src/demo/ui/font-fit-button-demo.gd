extends Node
## Keys:
## 	[0-9]: Change the button's text.

const CHOICES := [
	"+",
	"!?",
	"Yes",
	"Maybe?",
	"Yes indeed",
	"Well, alright",
	"Is this ethical?",
	"That's what you think!",
	"Hey, don't steal my thunder!",
	"This is not a productive line of discussion.",
]

@onready var _button := $Button

func _input(event: InputEvent) -> void:
	match Utils.key_keycode(event):
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			_button.text = CHOICES[Utils.key_num(event)]
			_button.pick_largest_font_size()
