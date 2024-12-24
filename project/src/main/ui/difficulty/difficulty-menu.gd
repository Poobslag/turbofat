extends Control
## Menu which lets the player select their difficulty and enable helpers.

## The button for 'Normal Mode' which is focused if the player's settings are in an unusual state
onready var _normal_difficulty_button := $DropPanel/VBoxContainer/Difficulty/Buttons/Button2

onready var _hold_piece_checkbox := $DropPanel/VBoxContainer/Helpers/HBoxContainer/HoldPiecePanel/CheckBox
onready var _line_piece_checkbox := $DropPanel/VBoxContainer/Helpers/HBoxContainer/LinePiecePanel/CheckBox

## Conditionally shows a 'Customize your difficulty!' message if the menu is forced upon the player
onready var _tip_label := $TipLabel

func _ready() -> void:
	PlayerData.difficulty.connect("speed_changed", self, "_on_DifficultyData_speed_changed")
	
	_focus_difficulty_button()
	_assign_focus_neighbours()

	if SystemData.misc_settings.show_difficulty_menu:
		_tip_label.visible = true
		SystemData.misc_settings.show_difficulty_menu = false
		SystemData.has_unsaved_changes = true


## Returns:
## 	The button representing the difficulty stored in the player's settings.
func _chosen_difficulty_button() -> DifficultyButton:
	if not is_inside_tree():
		return null
	var chosen_difficulty_button: DifficultyButton
	
	# find the chosen difficulty button
	for difficulty_button in get_tree().get_nodes_in_group("difficulty_buttons"):
		if difficulty_button.is_button_difficulty_chosen():
			chosen_difficulty_button = difficulty_button
			break
	
	return chosen_difficulty_button


## Focuses the button representing the difficulty stored in the player's settings.
func _focus_difficulty_button() -> void:
	var button_to_focus := _chosen_difficulty_button()
	if not button_to_focus:
		button_to_focus = _normal_difficulty_button
	
	# select the chosen difficulty button
	button_to_focus.grab_focus()


## Assigns the focus neighbors based on the chosen difficulty.
##
## Navigating up from the helpers section should select the current difficulty, not the closest difficulty button.
func _assign_focus_neighbours() -> void:
	# determine the difficulty button to focus
	var button_to_focus := _chosen_difficulty_button()
	if not button_to_focus:
		button_to_focus = _normal_difficulty_button
	
	# assign the difficulty button as a focus neighbor
	_hold_piece_checkbox.focus_neighbour_top = button_to_focus.get_path()
	_line_piece_checkbox.focus_neighbour_top = button_to_focus.get_path()


func _on_DifficultyData_speed_changed(_value: int) -> void:
	_assign_focus_neighbours()


func _on_OkButton_pressed() -> void:
	if SystemData.has_unsaved_changes:
		# Save the 'show_difficulty_menu' setting
		SystemSave.save_system_data()
	SceneTransition.pop_trail({SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})
