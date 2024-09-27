extends Control
## Dialogs for the RankOutlierDemo.

onready var _error_dialog := $Error

func show_error(text: String) -> void:
	_error_dialog.dialog_text = text
	_error_dialog.popup_centered()
