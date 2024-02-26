extends Node
## Demonstrates a unique cutscene where the player and Fat Sensei walk through a cheering crowd.
##
## Keys:
## 	[Q,W,E,R]: Restart the cutscene with 10, 5, 3 or 1 second until the player is tossed into the air.
## 	[=/-]: Change the number of bouncing crowd members.

## Number of seconds the demo has been running, shown on the time label
var _total_time := 0.0

onready var _director: CrowdWalkDirector = $ViewportContainer/Viewport/Cutscene/Environment/CrowdWalkDirector
onready var _time_label := $TimeLabel

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_EQUAL:
			_director.bouncing_crowd_percent = clamp(_director.bouncing_crowd_percent + 0.1, 0.0, 1.0)
		KEY_MINUS:
			_director.bouncing_crowd_percent = clamp(_director.bouncing_crowd_percent - 0.1, 0.0, 1.0)
		KEY_Q:
			restart_cutscene(10)
		KEY_W:
			restart_cutscene(5)
		KEY_E:
			restart_cutscene(3)
		KEY_R:
			restart_cutscene(1)


func _process(delta: float) -> void:
	_total_time += delta
	# warning-ignore:integer_division
	_time_label.text = "%01d:%02d.%02d" % [
			int(_total_time) / 60, int(_total_time) % 60, 100*(_total_time - int(_total_time))]


func restart_cutscene(time_until_launch: float) -> void:
	_total_time = 0.0
	_director.play(time_until_launch)
