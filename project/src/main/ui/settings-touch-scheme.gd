extends Control
"""
UI control for adjusting the touchscreen control scheme.

The control scheme decides which buttons appear where.
"""

func _ready() -> void:
	$OptionButton.add_item(tr("Easy Console"))
	$OptionButton.add_item(tr("Easy Desktop"))
	$OptionButton.add_item(tr("Ambi Console"))
	$OptionButton.add_item(tr("Ambi Desktop"))
	$OptionButton.add_item(tr("Loco Console"))
	$OptionButton.add_item(tr("Loco Desktop"))
	$OptionButton.selected = SystemData.touch_settings.scheme


func _on_OptionButton_item_selected(id: int) -> void:
	SystemData.touch_settings.scheme = id
