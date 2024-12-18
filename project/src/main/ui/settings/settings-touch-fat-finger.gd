extends Control
## UI control for adjusting the touchscreen fat finger setting.
##
## The fat finger setting decides how easy it is to mash two buttons with one finger.

const VALUES := [0.00, 0.50, 0.66, 0.83, 1.00]

onready var _option_button := $OptionButton

func _ready() -> void:
	_option_button.add_item(tr("Off"))
	_option_button.add_item(tr("Slim"))
	_option_button.add_item(tr("Plump"))
	_option_button.add_item(tr("Pudge"))
	_option_button.add_item(tr("Chonk"))
	_option_button.selected = Utils.find_closest(VALUES, SystemData.touch_settings.fat_finger)


func _on_OptionButton_item_selected(id: int) -> void:
	SystemData.touch_settings.fat_finger = VALUES[id]
	SystemData.has_unsaved_changes = true
