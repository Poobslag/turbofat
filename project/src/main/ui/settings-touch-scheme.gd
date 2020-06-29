extends Control
"""
UI control for adjusting the touchscreen control scheme.

The control scheme decides which buttons appear where.
"""

func _ready() -> void:
	$OptionButton.add_item("Easy Console")
	$OptionButton.add_item("Easy Desktop")
	$OptionButton.add_item("Ambi Console")
	$OptionButton.add_item("Ambi Desktop")
	$OptionButton.add_item("Loco Console")
	$OptionButton.add_item("Loco Desktop")
	$OptionButton.selected = PlayerData.touch_settings.scheme


func _on_OptionButton_item_selected(id: int) -> void:
	PlayerData.touch_settings.scheme = id
