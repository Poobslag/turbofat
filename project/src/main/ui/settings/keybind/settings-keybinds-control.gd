extends VBoxContainer
## UI control which lets the player view and update the game's keybinds.

onready var _tab_container: TabContainer = get_parent()


func _ready() -> void:
	$Presets/Guideline.connect("pressed", self, "_on_Guideline_pressed")
	$Presets/Wasd.connect("pressed", self, "_on_Wasd_pressed")
	$Presets/Custom.connect("pressed", self, "_on_Custom_pressed")
	_custom_control("ResetToDefault").connect("pressed", self, "_on_ResetToDefault_pressed")
	SystemData.gameplay_settings.connect("hold_piece_changed", self, "_on_GameplaySettings_hold_piece_changed")
	InputManager.connect("input_mode_changed", self, "_on_InputManager_input_mode_changed")
	
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
			if InputManager.input_mode == InputManager.KEYBOARD_MOUSE:
				_assign_guideline_keyboard_values()
			elif InputManager.input_mode == InputManager.JOYPAD:
				_assign_guideline_joypad_values()
		KeybindSettings.WASD:
			$PresetScrollContainer.visible = true
			if InputManager.input_mode == InputManager.KEYBOARD_MOUSE:
				_assign_wasd_keyboard_values()
			elif InputManager.input_mode == InputManager.JOYPAD:
				_assign_wasd_joypad_values()
		KeybindSettings.CUSTOM:
			$CustomScrollContainer.visible = true
			_custom_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece


## Assigns the standard preset keyboard values which do not change between Guideline and WASD
func _assign_preset_keyboard_values() -> void:
	_preset_control("Retry").keybind_values = [tr("R")]
	_preset_control("Menu").keybind_values = [tr("Escape")]
	_preset_control("MoveInMenus").keybind_values = [tr("Arrows"), tr("WASD")]
	_preset_control("ConfirmInMenus").keybind_values = [tr("Space")]
	_preset_control("BackInMenus").keybind_values = [tr("Escape")]
	_preset_control("NextTabInMenus").keybind_values = [tr("X")]
	_preset_control("PrevTabInMenus").keybind_values = [tr("Z")]
	_preset_control("RewindText").keybind_values = [tr("Shift")]


## Updates all controls within the 'Presets' scroll container with values for the 'Guideline' preset.
func _assign_guideline_keyboard_values() -> void:
	_assign_preset_keyboard_values()
	_preset_control("MovePiece").keybind_values = [tr("Left"), tr("Right"), tr("Kp 4"), tr("Kp 6")]
	_preset_control("SoftDrop").keybind_values = [tr("Down"), tr("Kp 2")]
	if SystemData.gameplay_settings.hold_piece:
		_preset_control("HardDrop").keybind_values = [tr("Space"), tr("Up"), tr("Kp 8")]
	else:
		_preset_control("HardDrop").keybind_values = [tr("Space"), tr("Up"), tr("Kp 8"), tr("Shift")]
	_preset_control("RotatePiece").keybind_values = [tr("Z"), tr("X"), tr("Kp 7"), tr("Kp 9")]
	_preset_control("SwapHoldPiece").keybind_values = [tr("Shift"), tr("C"), tr("Kp 0")]
	_preset_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece


## Updates all controls within the 'Presets' scroll container with values for the 'WASD' preset.
func _assign_wasd_keyboard_values() -> void:
	_assign_preset_keyboard_values()
	_preset_control("MovePiece").keybind_values = [tr("A"), tr("D"), tr("Kp 4"), tr("Kp 6")]
	_preset_control("SoftDrop").keybind_values = [tr("S"), tr("Kp 8")]
	if SystemData.gameplay_settings.hold_piece:
		_preset_control("HardDrop").keybind_values = [tr("W"), tr("Kp 5")]
	else:
		_preset_control("HardDrop").keybind_values = [tr("W"), tr("Kp 5"), tr("Kp Enter")]
	_preset_control("RotatePiece").keybind_values = [tr("Left"), tr("Right"), tr("Kp 7"), tr("Kp 9")]
	_preset_control("SwapHoldPiece").keybind_values = [tr("Shift"), tr("Kp Enter")]
	_preset_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece


## Assigns the standard preset joypad values which do not change between Guideline and WASD
func _assign_preset_joypad_values() -> void:
	_preset_control("Retry").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_VIEW]
	_preset_control("Menu").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_MENU]
	_preset_control("MoveInMenus").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_DPAD]
	_preset_control("ConfirmInMenus").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_A]
	_preset_control("BackInMenus").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_B]
	_preset_control("NextTabInMenus").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_RB]
	_preset_control("PrevTabInMenus").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_LB]
	_preset_control("RewindText").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_X]


## Updates all controls within the 'Presets' scroll container with values for joypad presets.
##
## The 'Guideline' and 'WASD' presets both have the same joypad mappings.
func _assign_guideline_joypad_values() -> void:
	_assign_preset_joypad_values()
	_preset_control("MovePiece").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_DPAD_LEFT, KeybindSettings.XBOX_IMAGE_DPAD_RIGHT]
	_preset_control("SoftDrop").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_DPAD_DOWN, KeybindSettings.XBOX_IMAGE_B]
	if SystemData.gameplay_settings.hold_piece:
		_preset_control("HardDrop").keybind_values = \
				[KeybindSettings.XBOX_IMAGE_DPAD_UP, KeybindSettings.XBOX_IMAGE_Y]
	else:
		_preset_control("HardDrop").keybind_values = \
				[KeybindSettings.XBOX_IMAGE_DPAD_UP, KeybindSettings.XBOX_IMAGE_Y,
				KeybindSettings.XBOX_IMAGE_LB, KeybindSettings.XBOX_IMAGE_RB]
	_preset_control("RotatePiece").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_X, KeybindSettings.XBOX_IMAGE_A]
	_preset_control("SwapHoldPiece").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_LB, KeybindSettings.XBOX_IMAGE_RB]
	_preset_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece


## Updates all controls within the 'Presets' scroll container with values for joypad presets.
##
## The 'Guideline' and 'WASD' presets both have the same joypad mappings.
func _assign_wasd_joypad_values() -> void:
	_assign_preset_joypad_values()
	_preset_control("MovePiece").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_DPAD_LEFT, KeybindSettings.XBOX_IMAGE_DPAD_RIGHT]
	_preset_control("SoftDrop").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_DPAD_DOWN, KeybindSettings.XBOX_IMAGE_X]
	if SystemData.gameplay_settings.hold_piece:
		_preset_control("HardDrop").keybind_values = \
				[KeybindSettings.XBOX_IMAGE_DPAD_UP, KeybindSettings.XBOX_IMAGE_Y]
	else:
		_preset_control("HardDrop").keybind_values = \
				[KeybindSettings.XBOX_IMAGE_DPAD_UP, KeybindSettings.XBOX_IMAGE_Y,
				KeybindSettings.XBOX_IMAGE_LB, KeybindSettings.XBOX_IMAGE_RB]
	_preset_control("RotatePiece").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_A, KeybindSettings.XBOX_IMAGE_B]
	_preset_control("SwapHoldPiece").keybind_values = \
			[KeybindSettings.XBOX_IMAGE_LB, KeybindSettings.XBOX_IMAGE_RB]
	_preset_control("SwapHoldPiece").visible = SystemData.gameplay_settings.hold_piece


## Assigns the TabContainer's bottom focus neighbor to the pressed preset button.
func _refresh_focus_neighbours() -> void:
	var pressed_preset_button: Button
	for preset_button in [$Presets/Guideline, $Presets/Wasd, $Presets/Custom]:
		if preset_button.pressed:
			pressed_preset_button = preset_button
			break
	if pressed_preset_button:
		_tab_container.focus_neighbour_bottom = _tab_container.get_path_to(pressed_preset_button)


func _on_Guideline_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.GUIDELINE
	SystemData.has_unsaved_changes = true
	_refresh_keybind_labels()
	_refresh_focus_neighbours()


func _on_Wasd_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.WASD
	SystemData.has_unsaved_changes = true
	_refresh_keybind_labels()
	_refresh_focus_neighbours()


func _on_Custom_pressed() -> void:
	SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
	SystemData.has_unsaved_changes = true
	_refresh_keybind_labels()
	_refresh_focus_neighbours()


## When the player toggles the hold piece setting, we hide/show the swap hold piece keybind config.
##
## We don't want to confuse players by letting them set a 'Swap Hold Piece' key which doesn't work because they didn't
## enable the cheat.
func _on_GameplaySettings_hold_piece_changed(_value: bool) -> void:
	_refresh_keybind_labels()


func _on_ResetToDefault_pressed() -> void:
	SystemData.keybind_settings.restore_default_custom_keybinds()


func _on_InputManager_input_mode_changed() -> void:
	_refresh_keybind_labels()


func _on_TabInputEnabler_focus_neighbours_refreshed(current_tab: int) -> void:
	var this_tab: int = _tab_container.get_children().find(self)
	if current_tab == this_tab:
		_refresh_focus_neighbours()
