class_name MoneyLabel
extends Label

func _ready() -> void:
	# negative money is displayed as 0, to avoid UI oddities ($-300)
	text = Global.compact(max(0, PlayerData.money))
	PlayerData.connect("money_changed", self, "on_PlayerData_money_changed")


func on_PlayerData_money_changed(money: int) -> void:
	text = Global.compact(max(0, PlayerData.money))
