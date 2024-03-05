extends Node
## Demonstrates a unique cutscene where the player and Fat Sensei crowd surf on a cheering crowd.
##
## Keys:
## 	Space: Restart the cutscene.

## Number of seconds the demo has been running, shown on the time label
var _total_time := 0.0

onready var _director: CrowdSurfDirector = $ViewportContainer/Viewport/Cutscene/Environment/CrowdSurfDirector
onready var _time_label := $TimeLabel

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_SPACE:
			_total_time = 0.0
			_director.play()


func _process(delta: float) -> void:
	_total_time += delta
	# warning-ignore:integer_division
	_time_label.text = "%01d:%02d.%02d" % [
			int(_total_time) / 60, int(_total_time) % 60, 100*(_total_time - int(_total_time))]
