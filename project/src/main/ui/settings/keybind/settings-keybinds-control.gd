extends VBoxContainer
## UI control which lets the player view and update the game's keybinds.

func _ready() -> void:
	$Presets/Guideline.connect("pressed", self, "_on_Guideline_pressed")
	$Presets/Wasd.connect("pressed", self, "_on_Wasd_pressed")
	$Presets/Custom.connect("pressed", self, "_on_Custom_pressed")
	$CustomScrollContainer/CenterContainer/VBoxContainer/ResetToDefault \
			.connect("pressed", self, "_on_ResetToDefault_pressed")
	SystemData.gameplay_settings.connect("hold_piece_changed", self, "_on_GameplaySettings_hold_piece_changed")
	
	match SystemData.keybind_settings.preset:
		KeybindSettings.GUIDELINE: $Presets/Guideline.pressed = true
		KeybindSettings.WASD: $Presets/Wasd.pressed = true
		KeybindSettings.CUSTOM: $Presets/Custom.pressed = true
	
	_refresh_keybind_labels()


## Updates the UI controls to reflect the currently selected preset.
##
## The 'WASD' and 'Guideline' presets reuse the same UI controls and change the label contents.
##
## The 'Custom' preset swaps in different UI controls because it's interactive.
func _refresh_keybind_labels() -> void:
	$PresetScrollContainer.visible = false
	$CustomScrollContainer.visible = false
	
	# Workaround for Godot #42224 (https://github.com/godotengine/godot/issues/42224). The following match statement
	# does not work unless this field is explicitly cast to an int
	var preset: int = SystemData.keybind_settings.preset
	
	match preset:
		KeybindSettings.GUIDELINE:
			$PresetScrollContainer.visible = true
			$PresetScrollContainer/CenterContainer/VBoxContainer/MovePiece.keybind_value \
					= tr("Left, Right, Kp 4, Kp 6")
			$PresetScrollContainer/CenterContainer/VBoxContainer/SoftDrop.keybind_value \
					= tr("Down, Kp 2")
			if SystemData.gameplay_settings.hold_piece:
				$PresetScrollContainer/CenterContainer/VBoxContainer/HardDrop.keybind_value \
						= tr("Space, Up, Kp 8")
			else:
				$PresetScrollContainer/CenterContainer/VBoxContainer/HardDrop.keybind_value \
						= tr("Space, Up, Kp 8, Shift")
			$PresetScrollContainer/CenterContainer/VBoxContainer/RotatePiece.keybind_value \
					= tr("Z, X, Kp 7, Kp 9")
			$PresetScrollContainer/CenterContainer/VBoxContainer/SwapHoldPiece.keybind_value \
					= tr("Shift, C, Kp 0")
			$PresetScrollContainer/CenterContainer/VBoxContainer/SwapHoldPiece.visible \
					= SystemData.gameplay_settings.hold_piece
		KeybindSettings.WASD:
			$PresetScrollContainer.visible = true
			$PresetScrollContainer/CenterContainer/VBoxContainer/MovePiece.keybind_value \
					= tr("A, D, Kp 4, Kp 6")
			$PresetScrollContainer/CenterContainer/VBoxContainer/SoftDrop.keybind_value \
					= tr("S, Kp 8")
			if SystemData.gameplay_settings.hold_piece:
				$PresetScrollContainer/CenterContainer/VBoxContainer/HardDrop.keybind_value \
						= tr("W, Kp 5")
			else:
				$PresetScrollContainer/CenterContainer/VBoxContainer/HardDrop.keybind_value \
						= tr("W, Kp 5, Kp Enter")
			$PresetScrollContainer/CenterContainer/VBoxContainer/RotatePiece.keybind_value \
					= tr("Left, Right, Kp 7, Kp 9")
			$PresetScrollContainer/CenterContainer/VBoxContainer/SwapHoldPiece.keybind_value \
					= tr("Shift, Kp Enter")
			$PresetScrollContainer/CenterContainer/VBoxContainer/SwapHoldPiece.visible \
					= SystemData.gameplay_settings.hold_piece
		KeybindSettings.CUSTOM:
			$CustomScrollContainer.visible = true
			$CustomScrollContainer/CenterContainer/VBoxContainer/SwapHoldPiece.visible \
					= SystemData.gameplay_settings.hold_piece


func _on_Guideline_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.GUIDELINE
	_refresh_keybind_labels()


func _on_Wasd_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.WASD
	_refresh_keybind_labels()


func _on_Custom_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
	_refresh_keybind_labels()


## When the player toggles the hold piece setting, we hide/show the swap hold piece keybind config.
##
## We don't want to confuse players by letting them set a 'Swap Hold Piece' key which doesn't work because they didn't
## enable the cheat.
func _on_GameplaySettings_hold_piece_changed(_value: bool) -> void:
	_refresh_keybind_labels()


func _on_ResetToDefault_pressed() -> void:
	SystemData.keybind_settings.restore_default_custom_keybinds()
