extends Control
"""
Shows popup dialogs for the level editor.
"""

onready var _level_editor: LevelEditor = get_parent()

func _on_OpenResourceDialog_file_selected(path: String) -> void:
	_level_editor.load_scenario(path)


func _on_OpenFileDialog_file_selected(path: String) -> void:
	_level_editor.load_scenario(path)


func _on_SaveDialog_file_selected(path: String) -> void:
	_level_editor.save_scenario(path)


func _on_OpenFile_pressed() -> void:
	$OpenFileDialog.popup_centered()


func _on_OpenResource_pressed() -> void:
	$OpenResourceDialog.popup_centered()


func _on_Save_pressed() -> void:
	var file_root := StringUtils.sanitize_file_root(_level_editor.scenario_name.text)
	$SaveDialog.current_file = ScenarioSettings.scenario_filename(file_root)
	$SaveDialog.popup_centered()
