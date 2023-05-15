extends Node

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
	"This is not a productive line of discussion.",
]

@onready var _label := $ColorRect/Label

func _input(event: InputEvent) -> void:
	match Utils.key_keycode(event):
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			_label.text = CHOICES[Utils.key_num(event)]
			_label.pick_largest_font()
