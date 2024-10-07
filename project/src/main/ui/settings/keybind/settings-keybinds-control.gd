extends VBoxContainer
## UI control which lets the player view and update the game's keybinds.

func _ready() -> void:
	$Presets/Guideline.connect("pressed", self, "_on_Guideline_pressed")
	$Presets/Wasd.connect("pressed", self, "_on_Wasd_pressed")
	$Presets/Custom.connect("pressed", self, "_on_Custom_pressed")
	_custom_control("ResetToDefault").connect("pressed", self, "_on_ResetToDefault_pressed")
	SystemData.gameplay_settings.connect("hold_piece_changed", self, "_on_GameplaySettings_hold_piece_changed")
	
	match SystemData.keybind_settings.preset:
		KeybindSettings.GUIDELINE: $Presets/Guideline.pressed = true
		KeybindSettings.WASD: $Presets/Wasd.pressed = true
		KeybindSettings.CUSTOM: $Presets/Custom.pressed = true
	
	_refresh_keybind_labels()


## Returns a control within the 'Presets' scroll container.
func _preset_control(path: String) -> Control:
	return $PresetScrollContainer/CenterContainer/VBoxContainer.get_node(path) as Control


## Returns a control within the 'Custom' scroll container.
func _custom_control(path: String) -> Control:
	return $CustomScrollContainer/CenterContainer/VBoxContainer.get_node(path) as Control


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
			_preset_control("MovePiece").keybind_value = tr("Left, Right, Kp 4, Kp 6")
			_preset_control("SoftDrop").keybind_value = tr("Down, Kp 2")
			if SystemData.gameplay_settings.hold_piece:
				_preset_control("HardDrop").keybind_value = tr("Space, Up, Kp 8")
			else:
				_preset_control("HardDrop").keybind_value = tr("Space, Up, Kp 8, Shift")
			_preset_control("RotatePiece").keybind_value = tr("Z, X, Kp 7, Kp 9")
			_preset_control("SwapHoldPiece").keybind_value = tr("Shift, C, Kp 0")
			_preset_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece
		KeybindSettings.WASD:
			$PresetScrollContainer.visible = true
			_preset_control("MovePiece").keybind_value = tr("A, D, Kp 4, Kp 6")
			_preset_control("SoftDrop").keybind_value = tr("S, Kp 8")
			if SystemData.gameplay_settings.hold_piece:
				_preset_control("HardDrop").keybind_value = tr("W, Kp 5")
			else:
				_preset_control("HardDrop").keybind_value = tr("W, Kp 5, Kp Enter")
			_preset_control("RotatePiece").keybind_value = tr("Left, Right, Kp 7, Kp 9")
			_preset_control("SwapHoldPiece").keybind_value = tr("Shift, Kp Enter")
			_preset_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece
		KeybindSettings.CUSTOM:
			$CustomScrollContainer.visible = true
			_custom_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece


func _on_Guideline_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.GUIDELINE
	SystemData.has_unsaved_changes = true
	_refresh_keybind_labels()


func _on_Wasd_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.WASD
	SystemData.has_unsaved_changes = true
	_refresh_keybind_labels()


func _on_Custom_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
	SystemData.has_unsaved_changes = true
	_refresh_keybind_labels()


## When the player toggles the hold piece setting, we hide/show the swap hold piece keybind config.
##
## We don't want to confuse players by letting them set a 'Swap Hold Piece' key which doesn't work because they didn't
## enable the cheat.
func _on_GameplaySettings_hold_piece_changed(_value: bool) -> void:
	_refresh_keybind_labels()


func _on_ResetToDefault_pressed() -> void:
	SystemData.keybind_settings.restore_default_custom_keybinds()
