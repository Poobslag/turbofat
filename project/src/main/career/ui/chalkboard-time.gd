extends MarginContainer
## Label which shows the player's daily seconds played when the player finishes career mode.

onready var _value_label := $HBoxContainer/Label3

func _ready() -> void:
	_value_label.text = StringUtils.format_duration(min(PlayerData.career.daily_seconds_played, 5999)) # 99:59
