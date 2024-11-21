extends Panel
## UI control for enabling the hold piece

onready var _check_box := $CheckBox

func _ready() -> void:
	PlayerData.difficulty.connect("hold_piece_changed", self, "_on_DifficultyData_hold_piece_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = PlayerData.difficulty.hold_piece


func _on_CheckBox_toggled(_button_pressed: bool) -> void:
	PlayerData.difficulty.hold_piece = _check_box.pressed
	PlayerSave.schedule_save()


func _on_DifficultyData_hold_piece_changed(_value: bool) -> void:
	_refresh()
