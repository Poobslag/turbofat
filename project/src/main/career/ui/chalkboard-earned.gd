extends MarginContainer
## A label which shows the player's daily earnings when the player finishes career mode.

onready var _value_label := $HBoxContainer/Label3

func _ready() -> void:
	_value_label.text = StringUtils.format_money(min(PlayerData.career.daily_earnings, 999999))
