extends Control
"""
Shows popup dialogs for the level editor.
"""

onready var _level_editor: LevelEditor = get_parent()

func _show_save_load_not_supported_error() -> void:
	$Error.dialog_text = "Saving/loading files isn't supported over the web. Sorry!"
	$Error.popup_centered()


func _on_OpenResource_file_selected(path: String) -> void:
	_level_editor.load_level(path)


func _on_OpenFile_file_selected(path: String) -> void:
	_level_editor.load_level(path)


func _on_Save_file_selected(path: String) -> void:
	_level_editor.save_level(path)


func _on_OpenFile_pressed() -> void:
	if OS.has_feature("web"):
		_show_save_load_not_supported_error()
		return
	
	Utils.assign_default_dialog_path($OpenFile, "res://assets/main/puzzle/levels/")
	$OpenFile.popup_centered()


func _on_OpenResource_pressed() -> void:
	$OpenResource.popup_centered()


func _on_Save_pressed() -> void:
	if OS.has_feature("web"):
		_show_save_load_not_supported_error()
		return
	
	Utils.assign_default_dialog_path($Save, "res://assets/main/puzzle/levels/")
	var file_root := StringUtils.sanitize_file_root(_level_editor.level_name.text)
	$Save.current_file = LevelSettings.level_filename(file_root)
	$Save.popup_centered()
