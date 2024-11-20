extends Panel
## UI control for adding line pieces to all levels

onready var _check_box := $CheckBox

func _ready() -> void:
	PlayerData.difficulty.connect("line_piece_changed", self, "_on_DifficultyData_line_piece_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = PlayerData.difficulty.line_piece


func _on_CheckBox_toggled(_button_pressed: bool) -> void:
	PlayerData.difficulty.line_piece = _check_box.pressed
	PlayerSave.schedule_save()


func _on_DifficultyData_line_piece_changed(_value: bool) -> void:
	_refresh()
