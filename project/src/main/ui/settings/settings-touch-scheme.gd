extends Control
## UI control for adjusting the touchscreen control scheme.
##
## The control scheme decides which buttons appear where.

onready var _option_button := $OptionButton

func _ready() -> void:
	_option_button.add_item(tr("Easy Console"))
	_option_button.add_item(tr("Easy Desktop"))
	_option_button.add_item(tr("Ambi Console"))
	_option_button.add_item(tr("Ambi Desktop"))
	_option_button.add_item(tr("Loco Console"))
	_option_button.add_item(tr("Loco Desktop"))
	_option_button.selected = SystemData.touch_settings.scheme


func _on_OptionButton_item_selected(id: int) -> void:
	SystemData.touch_settings.scheme = id
