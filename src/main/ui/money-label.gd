class_name MoneyLabel
extends Label

const SUFFIXES := ["", " k", " m", " b", " t"]

func _ready() -> void:
	text = format_money(PlayerData.money)
	PlayerData.connect("money_changed", self, "on_PlayerData_money_changed")


func on_PlayerData_money_changed(money: int) -> void:
	text = format_money(PlayerData.money)


"""
Formats the player's money like '5,982 k'.

The resulting string is always seven or fewer characters, allowing for a compact UI.
"""
static func format_money(money: int) -> String:
	var suffix_index := 0
	var suffix: String = ""
	var prefix: String = ""
	
	# negative money is displayed as 0, to avoid UI oddities ($-300)
	var money_int := 0 if money < 0 else money
	
	# determine suffix, such as ' b' in the number '5,982 b'
	while money_int > 9999:
		suffix_index += 1
		if suffix_index >= SUFFIXES.size():
			money_int = 9999
			break
		suffix = SUFFIXES[suffix_index]
		money_int /= 1000
	
	var result: String
	if money_int >= 1000:
		result = "%s,%03d%s" % [money_int / 1000, money_int % 1000, suffix]
	else:
		result = "%d%s" % [money_int, suffix]
	return result
