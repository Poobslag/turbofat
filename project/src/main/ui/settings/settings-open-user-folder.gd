extends HBoxContainer
## UI component for opening the user data folder.
##
## The user data folder has all their save data. Accessing this folder is useful when backing up their data or
## changing PCs.

onready var _button := $Button

func _ready() -> void:
	if OS.has_feature("web") or OS.has_feature("mobile"):
		_button.disabled = true


func _on_Button_pressed() -> void:
	OS.shell_open(OS.get_user_data_dir())
