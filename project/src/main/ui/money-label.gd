class_name MoneyLabel
extends Control
## Shows the player's money.
##
## Money can be shown in an compact form like '17.2 b' or an expanded form like '17,213,529,312'.

## 'true' if the money should be shown in a compact form like '17.2 b' to save on space.
@export (bool) var compact: bool: set = set_compact

## Amount of money shown by this label. Might differ from the player's actual money during animations.
var shown_money: int

func _ready() -> void:
	PlayerData.connect("money_changed", Callable(self, "on_PlayerData_money_changed"))
	set_shown_money(PlayerData.money)


func on_PlayerData_money_changed(value: int) -> void:
	set_shown_money(value)


func set_compact(new_compact: bool) -> void:
	compact = new_compact
	set_shown_money(PlayerData.money)


## Updates the label to show the player's current money.
##
## Negative money is displayed as 0 to avoid UI oddities ($-300)
func set_shown_money(new_money: int) -> void:
	shown_money = new_money
	if compact:
		$Label.text = StringUtils.compact(max(0, shown_money))
	else:
		$Label.text = StringUtils.comma_sep(max(0, shown_money))
