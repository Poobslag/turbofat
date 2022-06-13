extends Node
## Shows off the tutorial message UI.
##
## Keys:
## 	[0-9]: Prints a message; 1 = short, 0 = long
## 	[shift+0-9]: Enqueues a message; 1 = short, 0 = long
## 	[O]: Prints a message in a big font
## 	[H]: Hides the message after a short delay
## 	[F]: Flashes the screen

const TEXTS := [
	"Oh my,/ you're not supposed to know how to do that!\n\n" \
			+ "...But yes,/ box clears earn you five times as much money./" \
			+ " Maybe more than that if you're clever.",
	"Clear a row by filling it with blocks.",
	"Hold soft drop to squish a piece through a narrow gap.",
	"Build a snack box by arranging two pieces into a square.",
	"Well done!\n\nSnack boxes earn ¥15 if you clear all three lines.",
	"Now let's try it for real!/ Serve these creatures and try to earn ¥100.",
	"Well done!\n\nLine clears earn ¥1./ Maybe more if you can build a combo.",
	"Well done!\n\nSquish moves can help you out of a jam./ They're also good for certain boxes.",
	"Welcome to Turbo Fat!/ You seem to already be familiar with this sort of game,/ so let's dive right in.",
	"Oh my,/ you're not supposed to know how to do that!\n\n...But yes,/ squish moves can help you out of a jam.",
]

## a tutorial level id to demo, like 'tutorial/basic_0'
export (String) var level_id: String = LevelLibrary.BEGINNER_TUTORIAL

onready var _tutorial_hud: TutorialHud = $Level/Hud/Center/TutorialHud

func _ready() -> void:
	var level_settings := LevelSettings.new()
	level_settings.load_from_resource(level_id)
	level_settings.other.start_level = ""
	CurrentLevel.start_level(level_settings)
	_tutorial_hud.replace_tutorial_module()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			if Input.is_key_pressed(KEY_SHIFT):
				_tutorial_hud.enqueue_message(TEXTS[Utils.key_num(event)])
			else:
				_tutorial_hud.set_message(TEXTS[Utils.key_num(event)])
		KEY_O:
			_tutorial_hud.set_big_message("O/H/,/// M/Y/!/!/!")
		KEY_F:
			_tutorial_hud.flash_for_level_change()
		KEY_H:
			_tutorial_hud.enqueue_pop_out()
