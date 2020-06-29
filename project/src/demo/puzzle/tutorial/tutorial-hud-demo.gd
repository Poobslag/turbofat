extends Control
"""
Shows off the tutorial message UI.

Keys:
	[0-9]: Prints a message; 1 = short, 0 = long
	[O]: Prints a message in a big font
	[H]: Hides the message after a short delay
	[shift+H]: Hides the message immediately
"""

const TEXTS := [
	"Oh my,/ you're not supposed to know how to do that!\n\n..." \
			+ "But yes,/ snack boxes earn $15 when you clear them./ Maybe more if you're clever.",
	"Clear a row by filling it with blocks.",
	"Hold soft drop to squish a piece through a narrow gap.",
	"Build a snack box by arranging two pieces into a square.",
	"Well done!\n\nSnack boxes earn $15 if you clear all three lines.",
	"Now let's try it for real!/ Serve these creatures and try to earn $100.",
	"Well done!\n\nLine clears earn $1./ Maybe more if you can build a combo.",
	"Well done!\n\nSquish moves can help you out of a jam./ They're also good for certain boxes.",
	"Welcome to Turbo Fat!/ You seem to already be familiar with this sort of game,/ so let's dive right in.",
	"Oh my,/ you're not supposed to know how to do that!\n\n...But yes,/ squish moves can help you out of a jam.",
]

onready var _tutorial_hud: TutorialHud = $Scenario/Hud/TutorialHud
onready var _tutorial_message: TutorialMessage = $Scenario/Hud/TutorialHud/Message

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var settings := ScenarioSettings.new()
	settings.load_from_resource("tutorial-beginner-0")
	Scenario.start_scenario(settings)
	$Scenario.init_milestone_hud()
	_tutorial_hud.refresh()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			_tutorial_hud.append_message(TEXTS[Utils.key_num(event)])
		KEY_O:
			_tutorial_hud.append_big_message("O/H/,/// M/Y/!/!/!")
		KEY_H:
			if Input.is_key_pressed(KEY_SHIFT):
				_tutorial_message.set_pop_out_timer(0.01)
			else:
				_tutorial_message.set_pop_out_timer(3.0)
