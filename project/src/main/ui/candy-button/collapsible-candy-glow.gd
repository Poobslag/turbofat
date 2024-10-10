extends "res://src/main/ui/candy-button/candy-glow.gd"
## Fixed-size candy glow for collapsible candy buttons.
##
## The candy glow size is calculated based on the candy button size, which causes problems if the button changes
## sizes. This script uses a fixed-size glow instead.


func get_button_size() -> Vector2:
	return Vector2(80, 64)
