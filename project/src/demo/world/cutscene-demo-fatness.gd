extends HBoxContainer
## UI control for editing the global 'forced_fatness' field.

func _ready() -> void:
	if PlayerData.creature_library.forced_fatness:
		$CheckBox.pressed = true
		$HSlider.value = PlayerData.creature_library.forced_fatness
	else:
		$CheckBox.pressed = false
		$HSlider.value = 10.0
	
	_refresh()


## Updates the UI controls and the global 'forced_fatness' field.
func _refresh() -> void:
	$HSlider.editable = $CheckBox.pressed
	$Value.text = "%.1f" % [$HSlider.value] if $HSlider.editable else "-"
	
	PlayerData.creature_library.forced_fatness = $HSlider.value if $CheckBox.pressed else 0.0


func _on_CheckBox_pressed() -> void:
	_refresh()


func _on_HSlider_value_changed(_value: float) -> void:
	_refresh()
