extends VBoxContainer
"""
A UI control which lets the player view and update the game's keybinds.
"""

func _ready() -> void:
	$Presets/Guideline.connect("pressed", self, "_on_Guideline_pressed")
	$Presets/Wasd.connect("pressed", self, "_on_Wasd_pressed")
	$Presets/Custom.connect("pressed", self, "_on_Custom_pressed")
	$CustomScrollContainer/VBoxContainer/ResetToDefault.connect("pressed", self, "_on_ResetToDefault_pressed")
	
	match SystemData.keybind_settings.preset:
		KeybindSettings.GUIDELINE: $Presets/Guideline.pressed = true
		KeybindSettings.WASD: $Presets/Wasd.pressed = true
		KeybindSettings.CUSTOM: $Presets/Custom.pressed = true
	
	_refresh_keybind_labels()


"""
Updates the UI controls to reflect the currently selected preset.

The 'WASD' and 'Guideline' presets reuse the same UI controls and change the label contents.

The 'Custom' preset swaps in different UI controls because it's interactive.
"""
func _refresh_keybind_labels() -> void:
	$PresetScrollContainer.visible = false
	$CustomScrollContainer.visible = false
	
	# Workaround for Godot #42224 (https://github.com/godotengine/godot/issues/42224)
	# The following match statement does not work unless this field is explicitly cast to an int
	var preset: int = SystemData.keybind_settings.preset
	
	match preset:
		KeybindSettings.GUIDELINE:
			$PresetScrollContainer.visible = true
			$PresetScrollContainer/VBoxContainer/MovePiece.keybind_value = tr("Left, Right, Numpad4/6")
			$PresetScrollContainer/VBoxContainer/SoftDrop.keybind_value = tr("Down, Numpad2")
			$PresetScrollContainer/VBoxContainer/HardDrop.keybind_value = tr("Space, Up, Shift, Numpad8")
			$PresetScrollContainer/VBoxContainer/RotatePiece.keybind_value = tr("Z, X, Numpad7/9")
		KeybindSettings.WASD:
			$PresetScrollContainer.visible = true
			$PresetScrollContainer/VBoxContainer/MovePiece.keybind_value = tr("A, D, Numpad4/6")
			$PresetScrollContainer/VBoxContainer/SoftDrop.keybind_value = tr("Down, S, Numpad8")
			$PresetScrollContainer/VBoxContainer/HardDrop.keybind_value = tr("Up, Space, W, Numpad5")
			$PresetScrollContainer/VBoxContainer/RotatePiece.keybind_value = tr("Left, Right, Numpad7/9")
		KeybindSettings.CUSTOM:
			$CustomScrollContainer.visible = true


func _on_Guideline_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.GUIDELINE
	_refresh_keybind_labels()


func _on_Wasd_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.WASD
	_refresh_keybind_labels()


func _on_Custom_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
	_refresh_keybind_labels()


func _on_ResetToDefault_pressed() -> void:
	SystemData.keybind_settings.restore_default_custom_keybinds()
