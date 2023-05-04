extends Node
## Demonstrates the 'frying pans UI' which shows the player's lives.

@onready var _frying_pans_ui := $FryingPansUi

## UI control for the remaining frying pans
@onready var _remaining_control: SpinBox = $Remaining/HBoxContainer/SpinBox

## UI control for the maximum number of frying pans
@onready var _max_control: SpinBox = $Max/HBoxContainer/SpinBox

## UI control for whether or not the frying pans are gold
@onready var _gold_control: CheckBox = $Gold

func _ready() -> void:
	_frying_pans_ui.pans_remaining = _remaining_control.value
	_frying_pans_ui.pans_max = _max_control.value
	_frying_pans_ui.gold = _gold_control.button_pressed


func _on_RemainingSpinBox_value_changed(value: float) -> void:
	_frying_pans_ui.pans_remaining = value


func _on_TotalSpinBox_value_changed(value: float) -> void:
	_frying_pans_ui.pans_max = value


func _on_Gold_toggled(button_pressed: bool) -> void:
	_frying_pans_ui.gold = button_pressed
