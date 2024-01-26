extends Node
## Demo which shows off the interactive scrolling credits.
##
## Keys:
## 	[Q]: Add a short line.
## 	[W,E]: Add an indented line.
## 	[A]: Add a "Proudly made with godot" line.
## 	[S]: Add a centered "Turbo Fat" line.
## 	[Z]: Show a wall of text.
## 	[Keypad 7,8,9]: Move the credits to the left, top, or right position and hide the header.
## 	[Keypad 1,2,3]: Move the credits to the left, bottom, or right position and show the header.
## 	[Shift]: Hold to speed up the credits.

## Number of seconds the demo has been running, shown on the time label
var _total_time := 0.0

onready var _scroll := $CreditsScroll
onready var _time_label := $TimeLabel

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q:
			_scroll.add_line("Ohiefosob fujesa nuf:")
		KEY_W:
			_scroll.add_indent_line("\"Girico rimipiv otutaj eyedibec ge re atadey\" by Girico")
		KEY_E:
			_scroll.add_indent_line("\"Regaceg bason\" by Yicimel Hose")
		KEY_A:
			_scroll.add_godot_line()
		KEY_S:
			_scroll.add_turbo_fat_line()
		KEY_Z:
			_scroll.show_wall_of_text("#player# mowesi #sensei# riveniv sitasot mer se na. Pa cedike nu ruciber"
					+ " natud bir tasucel taf setomud. Gateb ehaseti se dag rip repelie teqitit. Kotep wesesan nime"
					+ " padun: Ra taroki semet re se ko nutole motaca.", 10.0)
		KEY_KP_7:
			_scroll.credits_position = Credits.CreditsPosition.TOP_LEFT
		KEY_KP_8:
			_scroll.credits_position = Credits.CreditsPosition.CENTER_TOP
		KEY_KP_9:
			_scroll.credits_position = Credits.CreditsPosition.TOP_RIGHT
		KEY_KP_1:
			_scroll.credits_position = Credits.CreditsPosition.BOTTOM_LEFT
		KEY_KP_2:
			_scroll.credits_position = Credits.CreditsPosition.CENTER_BOTTOM
		KEY_KP_3:
			_scroll.credits_position = Credits.CreditsPosition.BOTTOM_RIGHT
	
	if event is InputEventKey and event.scancode == KEY_SHIFT and not event.is_echo():
		if event.is_pressed():
			Engine.time_scale = 20.0
		else:
			Engine.time_scale = 1.0


func _physics_process(delta: float) -> void:
	_total_time += delta
	# warning-ignore:integer_division
	var result := "%01d:%02d.%02d" % [int(_total_time) / 60, int(_total_time) % 60, 100*(_total_time - int(_total_time))]
	_time_label.text = result
	
