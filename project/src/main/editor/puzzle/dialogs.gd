extends Control
## Shows popup dialogs for the level editor.

export (NodePath) var level_editor_path: NodePath

onready var _level_editor: LevelEditor = get_node(level_editor_path)

onready var _open_file_dialog := $OpenFile
onready var _open_resource_dialog := $OpenResource
onready var _save_dialog := $Save

func _ready() -> void:
	# Assign default dialog paths. These path properties were removed in Godot 3.5 in 2022 as a security precaution
	# and can no longer be assigned in the Godot editor, so we assign them here. See Godot #29674
	# (https://github.com/godotengine/godot/issues/29674)
	_open_file_dialog.current_dir = "/"
	_open_file_dialog.current_file = "509e7c82-9399-425a-9f15-9370c2b3de8b"
	_open_file_dialog.current_path = "/509e7c82-9399-425a-9f15-9370c2b3de8b"
	
	_open_resource_dialog.current_dir = "res://assets/main/puzzle/levels"
	_open_resource_dialog.current_path = "res://assets/main/puzzle/levels/"
	
	_save_dialog.current_dir = "/"
	_save_dialog.current_file = "509e7c82-9399-425a-9f15-9370c2b3de8b"
	_save_dialog.current_path = "/509e7c82-9399-425a-9f15-9370c2b3de8b"


func _show_save_load_not_supported_error() -> void:
	$Error.dialog_text = "Saving/loading files isn't supported over the web. Sorry!"
	$Error.popup_centered()


func _preserve_file_dialog_path(dialog: FileDialog) -> void:
	for other_dialog in [_open_file_dialog, _open_resource_dialog, _save_dialog]:
		other_dialog.current_file = dialog.current_file
		
		if other_dialog.access == FileDialog.ACCESS_RESOURCES and dialog.access == FileDialog.ACCESS_FILESYSTEM:
			# localize the path when switching from file to resource dialogs
			other_dialog.current_path = ProjectSettings.localize_path(dialog.current_path)
		elif other_dialog.access == FileDialog.ACCESS_FILESYSTEM and dialog.access == FileDialog.ACCESS_RESOURCES:
			# globalize the path when switching from resource to file dialogs
			other_dialog.current_path = ProjectSettings.globalize_path(dialog.current_path)
		else:
			other_dialog.current_path = dialog.current_path


func _on_OpenResource_file_selected(path: String) -> void:
	_level_editor.load_level(path)
	_preserve_file_dialog_path(_open_resource_dialog)


func _on_OpenFile_file_selected(path: String) -> void:
	_level_editor.load_level(path)
	_preserve_file_dialog_path(_open_file_dialog)


func _on_Save_file_selected(path: String) -> void:
	_level_editor.save_level(path)
	_preserve_file_dialog_path(_save_dialog)


func _on_OpenFile_pressed() -> void:
	if OS.has_feature("web"):
		_show_save_load_not_supported_error()
		return
	
	Utils.assign_default_dialog_path(_open_file_dialog, "res://assets/main/puzzle/levels/practice/")
	_open_file_dialog.popup_centered()


func _on_OpenResource_pressed() -> void:
	_open_resource_dialog.popup_centered()
	Utils.assign_default_dialog_path(_open_resource_dialog, "res://assets/main/puzzle/levels/practice/")
	_open_resource_dialog.popup_centered()


func _on_Save_pressed() -> void:
	if OS.has_feature("web"):
		_show_save_load_not_supported_error()
		return
	
	Utils.assign_default_dialog_path(_save_dialog, "res://assets/main/puzzle/levels/practice/")
	_save_dialog.popup_centered()
	if not _save_dialog.current_file:
		# We assign a sensible filename based on the current level, like "level_512". Unfortunately, this filename is
		# replaced if a .json file is selected, which almost always happens immediately
		var raw_level_id := StringUtils.substring_after_last(_level_editor.level_id_label.text, "/")
		_save_dialog.current_file = "%s.json" % [raw_level_id]
