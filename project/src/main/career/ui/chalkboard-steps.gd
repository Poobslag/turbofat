extends MarginContainer
## Label which shows the player's daily steps when the player finishes career mode.

onready var _value_label := $HBoxContainer/Label3

func _ready() -> void:
	_value_label.text = StringUtils.comma_sep(min(PlayerData.career.steps, 99999))
