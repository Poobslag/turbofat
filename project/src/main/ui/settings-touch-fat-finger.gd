extends Control
"""
UI control for adjusting the touchscreen fat finger setting.

The fat finger setting decides how easy it is to mash two buttons with one finger.
"""

const VALUES := [0.00, 0.50, 0.66, 0.83, 1.00]

func _ready() -> void:
	$OptionButton.add_item(tr("Off"))
	$OptionButton.add_item(tr("Slim"))
	$OptionButton.add_item(tr("Plump"))
	$OptionButton.add_item(tr("Pudge"))
	$OptionButton.add_item(tr("Chonk"))
	$OptionButton.selected = Utils.find_closest(VALUES, PlayerData.touch_settings.scheme)


func _on_OptionButton_item_selected(id: int) -> void:
	PlayerData.touch_settings.fat_finger = VALUES[id]
