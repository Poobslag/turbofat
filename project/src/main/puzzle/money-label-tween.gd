extends Tween
"""
Tween which shows/hides the money label which appears after a puzzle.
"""

const DURATION := 0.1

onready var _money_label := $"../MoneyLabel"

func show_money() -> void:
	remove_all()
	interpolate_property(_money_label, "rect_position:y", _money_label.rect_position.y, 0, DURATION)
	start()


func hide_money() -> void:
	remove_all()
	interpolate_property(_money_label, "rect_position:y", _money_label.rect_position.y, -32.0, DURATION)
	start()
