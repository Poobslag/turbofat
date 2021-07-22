extends HBoxContainer
"""
UI control for toggling the creature detail level.
"""

onready var _option_button: OptionButton = $OptionButton

func _ready() -> void:
	_option_button.add_item(tr("Low"))
	_option_button.add_item(tr("High"))
	_option_button.selected = SystemData.graphics_settings.creature_detail
	SystemData.graphics_settings.connect(
			"creature_detail_changed", self, "_on_GraphicsSettings_creature_detail_changed")


func _on_OptionButton_item_selected(_index: int) -> void:
	SystemData.graphics_settings.creature_detail = _index


"""
When the player changes the detail levels, we add an asterisk.

This asterisk directs them to a warning explaining that the settings won't take effect immediately.
"""
func _on_GraphicsSettings_creature_detail_changed(_value: int) -> void:
	$Label.text = $Label.text.trim_suffix("*") + "*"
